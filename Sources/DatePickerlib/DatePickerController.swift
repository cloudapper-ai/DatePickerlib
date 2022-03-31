//
//  DatePickerController.swift
//  DatePickerlib
//
//  Created by M Arman on 3/28/22.
//


import UIKit

class DatePickerController: UIViewController {
    internal var bundle: DatePickerBundle = .init(title: "SELECT DATE", cancelCallback: { }, doneCallback: { _ in })

    override func viewDidLoad() {
        super.viewDidLoad()
        let pickerArea: UIView = {
            let view: UIView = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .white
            view.isUserInteractionEnabled = true
            view.layer.cornerRadius = 8
            view.clipsToBounds = true
            return view

        }()

        let emptyArea: UIView = {
            let view: UIView = UIView(frame: .zero)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            view.isUserInteractionEnabled = true
            return view
        }()

        view.backgroundColor = .lightGray.withAlphaComponent(0.35)
        view.addSubview(emptyArea)
        view.addSubview(pickerArea)

        let pickerHeight: CGFloat
        switch bundle.pickerType {
        case .DateTime:
            pickerHeight = 420
            break
        case .DateOnly:
            pickerHeight = 372
            break
        case .TimeOnly:
            pickerHeight = 100
            break
        }

        NSLayoutConstraint.activate([
            emptyArea.leftAnchor.constraint(equalTo: view.leftAnchor),
            emptyArea.rightAnchor.constraint(equalTo: view.rightAnchor),
            emptyArea.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            emptyArea.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor),
            pickerArea.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pickerArea.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            pickerArea.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: UIDevice.current.userInterfaceIdiom == .pad ? 0.5 : 1.0),
            pickerArea.heightAnchor.constraint(equalToConstant: pickerHeight),
        ])

        let openViewTapped = UITapGestureRecognizer(target: self, action: #selector(tapOnOpenView))

        emptyArea.addGestureRecognizer(openViewTapped)

        let toolbar: DatePickerTitlebar = {
            let toolbar = DatePickerTitlebar(frame: .zero)
            toolbar.translatesAutoresizingMaskIntoConstraints = false

            return toolbar
        }()
        
        let dateController = DateComponentController.get(bundle.date)
        let timeControl: TimeComponentView = {
            let control = TimeComponentView(frame: .zero)
            control.translatesAutoresizingMaskIntoConstraints = false

            return control
        }()
        timeControl.bind(bundle.date, { [weak self] oldDate in
            guard let self = self else { return }
            TimePickerController.show(currentDate: oldDate, anchorView: timeControl, callback: { newTime in
                print("New time: \(newTime)")
                timeControl.update(newTime)
            }, on: self)
        })

        toolbar.bind(title: bundle.title, cancelButtonSetup: (bundle.cancelButtonText, { [weak self] in
            self?.dismiss(animated: true, completion: { [weak self] in
                self?.bundle.cancelCallback()
            })
        }), doneButtonSetup: (bundle.doneButtonText, { [weak self] in
            self?.dismiss(animated: true, completion: { [weak self] in
                let date = dateController.dateComponent.selectedDate
                let day = date.day()
                let month = date.month()
                let year = date.year()
                
                let time = timeControl.date
                let hour = time.hour()
                let minute = time.minute()
                
                self?.bundle.doneCallback(Date.prepare(day: day, month: month, year: year, hour: hour, minute: minute, second: 0)?.utc() ?? self?.bundle.date ?? Date())
            })

        }))

        pickerArea.addSubview(toolbar)

        NSLayoutConstraint.activate([
            toolbar.leftAnchor.constraint(equalTo: pickerArea.leftAnchor),
            toolbar.rightAnchor.constraint(equalTo: pickerArea.rightAnchor),
            toolbar.topAnchor.constraint(equalTo: pickerArea.topAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 40),
        ])
        var topView: UIView = toolbar
        if bundle.pickerType == .TimeOnly || bundle.pickerType == .DateTime {
            pickerArea.addSubview(timeControl)

            NSLayoutConstraint.activate([
                timeControl.rightAnchor.constraint(equalTo: pickerArea.rightAnchor, constant: -16),
                timeControl.topAnchor.constraint(equalTo: topView.bottomAnchor, constant: 8),
                timeControl.heightAnchor.constraint(equalToConstant: 32),
            ])
            topView = timeControl
        }

        if bundle.pickerType == .DateTime || bundle.pickerType == .DateOnly {
            let pager: UIPageViewController = {
                let vc = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)

                return vc
            }()

            addChild(pager)
            pickerArea.addSubview(pager.view)
            pager.view.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                pager.view.leftAnchor.constraint(equalTo: pickerArea.leftAnchor),
                pager.view.rightAnchor.constraint(equalTo: pickerArea.rightAnchor),
                pager.view.topAnchor.constraint(equalTo: topView.bottomAnchor),
                pager.view.bottomAnchor.constraint(equalTo: pickerArea.bottomAnchor),
            ])
            pager.didMove(toParent: self)
            // TODO: work on moving the pages in either direction
            pager.setViewControllers([dateController], direction: .forward, animated: true, completion: nil)
        } else {
            NSLayoutConstraint.activate([
                topView.bottomAnchor.constraint(equalTo: pickerArea.bottomAnchor, constant: -16),
            ])
        }
    }

    @objc func tapOnOpenView() {
        dismiss(animated: true, completion: { [weak self] in
            self?.bundle.cancelCallback()
        })
    }
}

class TimeComponentView: UIView {
    private var button: UIButton = {
        let label: UIButton = .init(type: .system)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.titleLabel?.font = .systemFont(ofSize: 14)
        label.setTitleColor(PRUSIAN_BLUE, for: .normal)

        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(button)

        NSLayoutConstraint.activate([
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            button.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
        backgroundColor = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 0.5)
        layer.cornerRadius = 8
        clipsToBounds = true

        button.addTarget(self, action: #selector(onButtonClicked), for: .touchUpInside)
    }

    @objc func onButtonClicked() {
        request?(date)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var request: ((_ currentDate: Date) -> Void)?
    internal private(set) var date: Date = Date()
    func bind(_ value: Date, _ request: @escaping (_ currentDate: Date) -> Void) {
        date = value
        self.request = request
        UIView.performWithoutAnimation { [weak self] in
            self?.button.setTitle(value.local().toString(format: "hh:mm aa"), for: .normal)
        }
    }
    
    func update(_ value: Date) {
        date = value
        UIView.performWithoutAnimation { [weak self] in
            self?.button.setTitle(value.local().toString(format: "hh:mm aa"), for: .normal)
        }
        
    }
}

class DatePickerTitlebar: UIView {
    private var buttonCancel: UIButton = {
        let cancel = UIButton(type: .system)
        cancel.translatesAutoresizingMaskIntoConstraints = false
        cancel.setTitleColor(.systemBlue, for: .normal)
        cancel.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return cancel
    }()

    private var buttonDone: UIButton = {
        let done = UIButton(type: .system)
        done.translatesAutoresizingMaskIntoConstraints = false
        done.setTitleColor(.systemBlue, for: .normal)
        done.titleLabel?.font = .boldSystemFont(ofSize: 16)
        return done
    }()

    private var label: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center

        label.numberOfLines = 2

        return label
    }()

    private var boundary: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray.withAlphaComponent(0.25)

        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(boundary)
        addSubview(buttonCancel)
        addSubview(buttonDone)
        addSubview(label)

        NSLayoutConstraint.activate([
            boundary.leftAnchor.constraint(equalTo: leftAnchor),
            boundary.rightAnchor.constraint(equalTo: rightAnchor),
            boundary.heightAnchor.constraint(equalToConstant: 1),
            boundary.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonCancel.leftAnchor.constraint(equalTo: leftAnchor, constant: 8),
            buttonCancel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            buttonCancel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            buttonDone.rightAnchor.constraint(equalTo: rightAnchor, constant: -8),
            buttonDone.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            buttonDone.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),

            label.leftAnchor.constraint(equalTo: buttonCancel.rightAnchor),
            label.rightAnchor.constraint(equalTo: buttonDone.leftAnchor),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5), // 4+1 for bottom line height
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var cancelCallback: (() -> Void)?
    private var doneCallback: (() -> Void)?

    func bind(title: String = "SELECT DATE", cancelButtonSetup: (String, () -> Void), doneButtonSetup: (String, () -> Void)) {
        label.text = title
        buttonCancel.setTitle(cancelButtonSetup.0, for: .normal)
        buttonDone.setTitle(doneButtonSetup.0, for: .normal)
        buttonCancel.addTarget(self, action: #selector(onCanceled), for: .touchUpInside)
        buttonDone.addTarget(self, action: #selector(onDone), for: .touchUpInside)
        cancelCallback = cancelButtonSetup.1
        doneCallback = doneButtonSetup.1
    }

    @objc func onCanceled() {
        cancelCallback?()
    }

    @objc func onDone() {
        doneCallback?()
    }
}

class DateComponentController: UIViewController {
    class func get(_ currentDate: Date) -> DateComponentController {
        let vc = DateComponentController()
        vc.dateComponent.updateDateSelection(for: currentDate)
        print("Month: \(currentDate)")
        return vc
    }

    let dateComponent: DateComponent = {
        let com = DateComponent(month: Date())
        com.translatesAutoresizingMaskIntoConstraints = false

        return com
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(dateComponent)
        dateComponent.setChangeMonthYearCallback(callback: { [weak self] date, view in
            guard let self = self else { return }
            YearPickerContorller.show(currentMonth: date.month(), currentYear: date.year(), anchorView: view, callback: { [weak self] newMonth in
                print("New month: \(newMonth)")
                if newMonth.month() == self?.dateComponent.selectedDate.month() {
                    
                }
                self?.dateComponent.updateDateSelection(for: newMonth)
            }, on: self)
        })

        NSLayoutConstraint.activate([
            dateComponent.leftAnchor.constraint(equalTo: view.leftAnchor),
            dateComponent.rightAnchor.constraint(equalTo: view.rightAnchor),
            dateComponent.topAnchor.constraint(equalTo: view.topAnchor),
            dateComponent.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

class DateComponent: UIView, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dateSet.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DateItemCell", for: indexPath) as? DateItemCell else { fatalError("DateItemCell must be registered first") }
        cell.bind(dateSet[indexPath.row])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: collectionView.frame.width / 7.0, height: 40)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CalendarHeader", for: indexPath)
        default: fatalError("Did not register anything for it.")
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: collectionView.frame.width, height: 40)
    }

    internal private(set) var selectedDate: Date = Date()

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let date = dateSet[indexPath.row].date {
            selectedDate = date
            for i in 0 ..< dateSet.count {
                dateSet[i].selected = i == indexPath.row
            }

            collectionView.reloadData()
        }
    }

    private let collectionView: UICollectionView = {
        let flow = UICollectionViewFlowLayout()
        flow.estimatedItemSize = .zero
        flow.minimumLineSpacing = 0
        flow.minimumInteritemSpacing = 0
        let cv = UICollectionView(frame: .zero, collectionViewLayout: flow)
        cv.backgroundView?.backgroundColor = .clear
        cv.backgroundColor = .clear
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsVerticalScrollIndicator = false
        cv.showsHorizontalScrollIndicator = false

        return cv
    }()

    private var myearChangeCallback: ((_ month: Date, _ anchor: UIView) -> Void)?
    private var monthSwitchListener: ((_ isForward: Bool, _ newMonth: Date) -> Void)?

    func setChangeMonthYearCallback(callback: @escaping (_ month: Date, _ anchor: UIView) -> Void) {
        myearChangeCallback = callback
    }

    private func onYearChangeRequested(_ month: Date) {
        myearChangeCallback?(month, mYearButton)
    }

    private lazy var mYearButton: MonthYearButton = {
        let button = MonthYearButton(onYearChangeRequested(_:))
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let leftButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonArrow: UIImage? = UIImage(named: "month_left", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonArrow, for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.tintColor = .systemBlue
        return button
    }()

    private let rightButton: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonArrow: UIImage? = UIImage(named: "month_right", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonArrow, for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.tintColor = .systemBlue
        return button
    }()

    private var dateSet: [DateSet] = []
    private var month: Date = Date()
    convenience init(month: Date) {
        self.init(frame: .zero)
        setup(for: month, selectedDate: month)

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mYearButton)
        addSubview(leftButton)
        addSubview(rightButton)

        addSubview(collectionView)
        NSLayoutConstraint.activate([
            mYearButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            mYearButton.topAnchor.constraint(equalTo: topAnchor),
            mYearButton.heightAnchor.constraint(equalToConstant: 40),
            mYearButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),

            rightButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -16),
            rightButton.topAnchor.constraint(equalTo: topAnchor),
            rightButton.heightAnchor.constraint(equalToConstant: 40),

            leftButton.rightAnchor.constraint(equalTo: rightButton.leftAnchor),
            leftButton.topAnchor.constraint(equalTo: topAnchor),
            leftButton.heightAnchor.constraint(equalToConstant: 40),

            collectionView.leftAnchor.constraint(equalTo: leftAnchor),
            collectionView.rightAnchor.constraint(equalTo: rightAnchor),
            collectionView.topAnchor.constraint(equalTo: mYearButton.bottomAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        collectionView.register(DateItemCell.self, forCellWithReuseIdentifier: "DateItemCell")
        collectionView.register(CalendarHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "CalendarHeader")

        leftButton.addTarget(self, action: #selector(onGoback), for: .touchUpInside)
        rightButton.addTarget(self, action: #selector(onGoforward), for: .touchUpInside)
    }

    func updateDateSelection(for date: Date) {
        setup(for: date, selectedDate: date)
    }

    private func setup(for month: Date, selectedDate: Date) {
        let dateSet = DateSet.generateDataset(for: month, selectedDate: selectedDate)
        self.dateSet = dateSet
        self.month = month
        self.selectedDate = selectedDate
        mYearButton.set(month)
        collectionView.reloadData()
    }

    @objc func onGoback() {
        setup(for: month.startOfMonth().adding(days: -1), selectedDate: selectedDate)
    }

    @objc func onGoforward() {
        setup(for: month.endOfMonth().adding(days: 1), selectedDate: selectedDate)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var minDate: Date = Date.prepare() ?? Date()
    private var maxDate: Date = Date.prepare(day: 31, month: 12, year: 2100, hour: 23, minute: 59, second: 59) ?? Date()
}

class MonthYearButton: UIView {
    private let label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = PRUSIAN_BLUE
        label.textAlignment = .left
        return label
    }()

    private let button: UIButton = {
        let button: UIButton = .init(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let buttonArrow: UIImage? = UIImage(named: "month_picker_right", in: .module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        button.setImage(buttonArrow, for: .normal)
        button.contentEdgeInsets = .init(top: 4, left: 4, bottom: 4, right: 4)
        button.tintColor = .systemBlue
        button.isUserInteractionEnabled = false
        return button
    }()

    private var callback: ((_ month: Date) -> Void)?

    convenience init(_ callback: @escaping (_ month: Date) -> Void) {
        self.init(frame: .zero)
        self.callback = callback
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(label)
        addSubview(button)
        NSLayoutConstraint.activate([
            label.leftAnchor.constraint(equalTo: leftAnchor),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.leftAnchor.constraint(equalTo: label.rightAnchor, constant: 4),
            button.rightAnchor.constraint(lessThanOrEqualTo: rightAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onToucnUpInside))
        addGestureRecognizer(tapGesture)
    }

    @objc func onToucnUpInside() {
        callback?(month)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var month: Date = .init()
    func set(_ month: Date) {
        self.month = month
        label.text = month.local().toString(format: "MMMM yyyy")
    }
}

class CalendarHeader: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        let dateFormatter = DateFormatter()
        dateFormatter.locale = .current
        let symbols = dateFormatter.shortWeekdaySymbols ?? []
        let stackView: UIStackView = {
            let stack = UIStackView(frame: .zero)
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.alignment = .fill
            stack.axis = .horizontal
            stack.distribution = .fillEqually
            return stack
        }()

        addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: leftAnchor),
            stackView.rightAnchor.constraint(equalTo: rightAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        for symbol in symbols {
            let label: UILabel = {
                let label = UILabel(frame: .zero)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.textColor = .lightGray
                label.text = symbol.uppercased()
                label.textAlignment = .center
                label.font = .systemFont(ofSize: 12)
                return label
            }()
            stackView.addArrangedSubview(label)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private let PRUSIAN_BLUE: UIColor = .init(red: 0, green: 0.19, blue: 0.32, alpha: 1)
private let PRUSIAN_BLUE_LIGHTEST: UIColor = .init(red: 0.9, green: 0.97, blue: 1, alpha: 1)
class DateItemCell: UICollectionViewCell {
    private var label: UILabel = {
        let label: UILabel = .init(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = PRUSIAN_BLUE
        label.textAlignment = .center

        return label
    }()

    private var backgroud: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(backgroud)
        backgroud.addSubview(label)

        NSLayoutConstraint.activate([
            backgroud.widthAnchor.constraint(equalTo: contentView.heightAnchor),
            backgroud.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroud.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroud.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            label.leftAnchor.constraint(equalTo: backgroud.leftAnchor),
            label.rightAnchor.constraint(equalTo: backgroud.rightAnchor),
            label.topAnchor.constraint(equalTo: backgroud.topAnchor),
            label.bottomAnchor.constraint(equalTo: backgroud.bottomAnchor),

        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func bind(_ dateSet: DateSet) {
        if let day = dateSet.day, let date = dateSet.date {
            label.text = "\(day)"
            if dateSet.selected {
                label.textColor = PRUSIAN_BLUE
                backgroud.backgroundColor = PRUSIAN_BLUE_LIGHTEST
            } else {
                if date.inSameDay(Date()) {
                    label.textColor = .systemBlue
                } else {
                    label.textColor = PRUSIAN_BLUE
                }
                backgroud.backgroundColor = .clear
            }
        } else {
            label.text = nil
            backgroud.backgroundColor = .clear
        }
    }
}

struct DateSet {
    public let date: Date?
    init(dayInWeek: Int, day: Int? = nil, date: Date? = nil, selected: Bool) {
        self.dayInWeek = dayInWeek
        self.day = day
        self.selected = selected
        self.date = date
    }

    public let dayInWeek: Int
    public let day: Int?
    public var selected: Bool

    static func generateDataset(for currentMonth: Date, selectedDate: Date?) -> [DateSet] {
        let dates = currentMonth.local().allDatesInMonth()
        let selectedDate: Date? = selectedDate?.local()
        var dateSet = [DateSet]()
        // column represents day [SUN, MON, TUE, WED, THU, FRI, SAT]
        var dateIndex: Int = 0
        for _ in 0 ..< 6 {
            for column in 1 ... 7 {
                let currentDate = (dateIndex < dates.count) ? dates[dateIndex] : nil
                if let date = currentDate {
                    if column == date.dayInWeek() {
                        dateSet.append(DateSet(dayInWeek: column, day: dateIndex + 1, date: date, selected: selectedDate == nil ? false : date.inSameDay(selectedDate!)))
                        dateIndex += 1
                    } else {
                        dateSet.append(DateSet(dayInWeek: column, selected: false))
                    }
                } else {
                    dateSet.append(DateSet(dayInWeek: column, selected: false))
                }
            }
        }

        return dateSet
    }
}

public class TimePickerController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return hours.count
        case 1:
            return minutes.count
        default:
            return meridiums.count
        }
    }
    fileprivate func getStringRep(_ component: Int, _ row: Int) -> String {
        var string: String
        switch component {
        case 0:
            string = String(format: "%02d", hours[row])
        case 1:
            string = String(format: "%02d", minutes[row])
        default:
            string = meridiums[row]
        }
        return string
    }
    
    public func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let view = view as? UILabel {
            view.text = getStringRep(component, row)
            return view
        }
        return {
            let label: UILabel = .init(frame: .zero)
            label.font = .systemFont(ofSize: 14)
            label.textColor = PRUSIAN_BLUE
            label.text = getStringRep(component, row)
            label.textAlignment = .center
            return label
        }()
    }
    

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0:
            selectedHour = row
            if selectedHour >= 12 && selectedMeridium == 0 {
                selectedMeridium = 1
                pickerView.selectRow(1, inComponent: 2, animated: true)
            } else if selectedHour < 12 && selectedMeridium == 1 {
                selectedMeridium = 0
                pickerView.selectRow(0, inComponent: 2, animated: true)
            }
            break
        case 1:
            selectedMinute = row
            break
        default:
            selectedMeridium = row
            break
        }
    }

    private var picker: UIPickerView = {
        let view = UIPickerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var hours: [Int] = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12]
    private var minutes: [Int] = Array(0 ... 59)
    private var meridiums: [String] = ["AM", "PM"]
    private var selectedHour: Int = 0
    private var selectedMinute: Int = 0
    private var selectedMeridium: Int = 0

    var callback: ((_ newMonth: Date) -> Void)?

    public class func show(currentDate: Date = Date(), anchorView: UIView, callback: @escaping (_ newMonth: Date) -> Void, on viewController: UIViewController) {
        let vc = TimePickerController()
        vc.selectedHour = currentDate.hour() - 1
        vc.selectedMinute = currentDate.minute()

        vc.callback = callback

        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: vc)
        presentationController.sourceView = anchorView
        presentationController.sourceRect = anchorView.bounds
        presentationController.permittedArrowDirections = [.down, .up, .left]
        viewController.present(vc, animated: true)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.leftAnchor.constraint(equalTo: view.leftAnchor),
            picker.rightAnchor.constraint(equalTo: view.rightAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        picker.delegate = self
        picker.dataSource = self

        picker.selectRow(selectedHour, inComponent: 0, animated: false)
        picker.selectRow(selectedMinute, inComponent: 1, animated: false)
        if selectedHour >= 12 {
            selectedMeridium = 1
            picker.selectRow(1, inComponent: 2, animated: false)
        } else {
            selectedMeridium = 0
            picker.selectRow(0, inComponent: 2, animated: false)
        }
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPreferredContentSizeFromAutolayout()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        var hour: Int
        if selectedMeridium == 0 {
            hour = hours[selectedHour]
        } else {
            hour = 12 + hours[selectedHour]
        }
        let minute: Int = minutes[selectedMinute]
        if hour == 12 { hour = 0 }
        let newDate: Date = Date.prepare(hour: hour, minute: minute) ?? Date()
        callback?(newDate.utc())
    }

    private func setPreferredContentSizeFromAutolayout() {
        let width: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = (UIScreen.main.bounds.width / 5)
        } else {
            width = (UIScreen.main.bounds.width / 2.5)
        }
        let size = CGSize(width: width, height: 140)
        preferredContentSize = size
        popoverPresentationController?
            .presentedViewController
            .preferredContentSize = size
    }
}

class YearPickerContorller: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return months.count
        } else {
            return yearRange.count
        }
    }

    fileprivate func getStringRep(_ component: Int, _ row: Int) -> String {
        if component == 0 {
            return months[row]
        } else {
            return "\(yearRange[row])"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return getStringRep(component, row)
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if let view = view as? UILabel {
            view.text = getStringRep(component, row)
            return view
        }
        return {
            let label: UILabel = .init(frame: .zero)
            label.font = .systemFont(ofSize: 14)
            label.textColor = PRUSIAN_BLUE
            label.text = getStringRep(component, row)
            label.textAlignment = .center
            return label
        }()
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            currentMonth = row + 1
        } else {
            currentYear = yearRange[row]
        }
    }

    private var picker: UIPickerView = {
        let view = UIPickerView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false

        return view
    }()

    var currentMonth: Int = 1
    var months: [String] = []
    var currentYear: Int = 2022
    var yearRange: [Int] = Array(1900 ... 2100)

    var callback: ((_ newMonth: Date) -> Void)?

    class func show(range: [Int]? = nil, currentMonth: Int, currentYear: Int, anchorView: UIView, callback: @escaping (_ newMonth: Date) -> Void, on viewController: UIViewController) {
        let vc = YearPickerContorller()
        if let range = range, range.count > 0 {
            vc.yearRange = range
        }
        vc.currentMonth = currentMonth
        vc.currentYear = currentYear
        vc.callback = callback

        let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: vc)
        presentationController.sourceView = anchorView
        presentationController.sourceRect = anchorView.bounds
        presentationController.permittedArrowDirections = [.down, .up, .left]
        viewController.present(vc, animated: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(picker)

        NSLayoutConstraint.activate([
            picker.leftAnchor.constraint(equalTo: view.leftAnchor),
            picker.rightAnchor.constraint(equalTo: view.rightAnchor),
            picker.topAnchor.constraint(equalTo: view.topAnchor),
            picker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        months = formatter.monthSymbols ?? []

        picker.delegate = self
        picker.dataSource = self

        picker.selectRow(currentMonth - 1, inComponent: 0, animated: false)
        picker.selectRow(currentYear - yearRange[0], inComponent: 1, animated: false)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setPreferredContentSizeFromAutolayout()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        let newDate: Date = Date.prepare(month: currentMonth, year: currentYear) ?? Date()
        callback?(newDate.utc())
    }

    private func setPreferredContentSizeFromAutolayout() {
        let width: CGFloat
        if UIDevice.current.userInterfaceIdiom == .pad {
            width = (UIScreen.main.bounds.width / 5)
        } else {
            width = (UIScreen.main.bounds.width / 2.5)
        }
        let size = CGSize(width: width, height: 140)
        preferredContentSize = size
        popoverPresentationController?
            .presentedViewController
            .preferredContentSize = size
    }
}

private class AlwaysPresentAsPopover: NSObject, UIPopoverPresentationControllerDelegate {
    // `sharedInstance` because the delegate property is weak - the delegate instance needs to be retained.
    private static let sharedInstance = AlwaysPresentAsPopover()

    override private init() {
        super.init()
    }

    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }

    public static func configurePresentation(forController controller: UIViewController) -> UIPopoverPresentationController {
        controller.modalPresentationStyle = .popover
        let presentationController = controller.presentationController as! UIPopoverPresentationController
        presentationController.delegate = AlwaysPresentAsPopover.sharedInstance
        return presentationController
    }
}
