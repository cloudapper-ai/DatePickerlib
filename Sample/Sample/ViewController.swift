//
//  ViewController.swift
//  DateApp
//
//  Created by M Arman on 3/28/22.
//

import UIKit
import DatePickerlib

class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var tfTimeonlyPicker: UITextField!
    @IBOutlet weak var tfDateOnlyPicker: UITextField!
    @IBOutlet weak var tfDatepicker: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tfDatepicker.delegate = self
        tfDateOnlyPicker.delegate = self
        tfTimeonlyPicker.delegate = self
        
        tfDatepicker.placeholder = "Select both date and time"
        tfDateOnlyPicker.placeholder = "Select date"
        tfTimeonlyPicker.placeholder = "Select time"
        
        let tapGesture = UITapGestureRecognizer.init(target: self, action: #selector(onTouchedUpInside))
        tfDatepicker.addGestureRecognizer(tapGesture)
        let tapGestureOnlyTime = UITapGestureRecognizer.init(target: self, action: #selector(onTouchedUpInsideOnlyTime))
        tfTimeonlyPicker.addGestureRecognizer(tapGestureOnlyTime)
        let tapGestureOnlyDate = UITapGestureRecognizer.init(target: self, action: #selector(onTouchedUpInsideOnlyDate))
        tfDateOnlyPicker.addGestureRecognizer(tapGestureOnlyDate)
    }
    
    var selectedDate: Date? = nil
    var selectedDateOnly: Date? = nil
    var selectedTimeOnly: Date? = nil
    
    @objc func onTouchedUpInside() {
        let date = selectedDate == nil ? Date() : selectedDate!
        DatePicker.show(.init(date: date, pickerType: .DateTime, title: "SELECT DATE TIME", cancelCallback: {
            print("Canceled")
        }, doneCallback: { [weak self] in
            print("Selected date: \($0)")
            self?.tfDatepicker.text = "\($0.toString(format: "MMM dd, yyyy hh:mm aa"))"
            self?.selectedDate = $0
        }), on: self)
    }
    
    @objc func onTouchedUpInsideOnlyDate() {
        let date = selectedDateOnly == nil ? Date() : selectedDateOnly!
        DatePicker.show(.init(date: date, pickerType: .DateOnly, title: "SELECT DATE", cancelCallback: {
            print("Canceled")
        }, doneCallback: { [weak self] in
            print("Selected date: \($0)")
            self?.tfDateOnlyPicker.text = "\($0.toString(format: "MMM dd, yyyy"))"
            self?.selectedDateOnly = $0
        }), on: self)
    }
    
    @objc func onTouchedUpInsideOnlyTime() {
        let date = selectedTimeOnly == nil ? Date() : selectedTimeOnly!
        DatePicker.show(.init(date: date, pickerType: .TimeOnly, title: "SELECT TIME", cancelCallback: {
            print("Canceled")
        }, doneCallback: { [weak self] in
            print("Selected date: \($0)")
            self?.tfTimeonlyPicker.text = "\($0.toString(format: "hh:mm aa"))"
            self?.selectedTimeOnly = $0
        }), on: self)
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return false
    }
}

private extension Date {
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "en_US")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.string(from: self)
    }
}

