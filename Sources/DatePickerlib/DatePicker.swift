//
//  DatePicker.swift
//  DatePickerlib
//
//  Created by M Arman on 3/28/22.
//


import UIKit

public class DatePicker {
    public class func show(_ bundle: DatePickerBundle, on controller: UIViewController) {
        let picker = DatePickerController.init()
        picker.bundle = bundle
        
        picker.modalTransitionStyle = .crossDissolve
        picker.modalPresentationStyle = .overCurrentContext
        
        controller.present(picker, animated: true, completion: nil)
    }
}

public enum DatePickerType {
    case DateTime
    case DateOnly
    case TimeOnly
}

public struct DatePickerBundle {
    public init(minDate: Date? = nil,
                maxDate: Date? = nil,
                date: Date = Date(),
                pickerType: DatePickerType = .DateTime,
                title: String,
                cancelButtonText: String = "CANCEL",
                doneButtonText: String = "DONE",
                cancelCallback: @escaping ()->Void,
                doneCallback: @escaping (_ newDate: Date)->Void) {
        if let minDate = minDate {
            self.minDate = minDate
        }
        if let maxDate = maxDate {
            self.maxDate = maxDate
        }
        
        self.pickerType = pickerType
        self.date = date
        self.title = title
        self.cancelCallback = cancelCallback
        self.doneCallback = doneCallback
        self.cancelButtonText = cancelButtonText
        self.doneButtonText = doneButtonText
    }
    
    public var minDate: Date = Date.prepare(day: 1, month: 1, year: 1900) ?? Date()
    public var maxDate: Date = Date.prepare(day: 31, month: 12, year: 2100, hour: 23, minute: 59, second: 59) ?? Date()
    
    public var pickerType: DatePickerType = .DateTime
    
    public var date: Date
    
    public var title: String
    public var cancelButtonText: String
    public var doneButtonText: String
    public var cancelCallback: ()->Void
    public var doneCallback: (_ newDate: Date)->Void
}

extension Date {
    static func prepare(day: Int = 1, month: Int = 1, year: Int = 1900, hour: Int = 0, minute: Int = 0, second: Int = 0, timeZone: TimeZone? = TimeZone.init(secondsFromGMT: 0)) -> Date? {
        var dateComponents = DateComponents.init()
        dateComponents.day = day
        dateComponents.month = month
        dateComponents.year = year
        dateComponents.timeZone = timeZone
        dateComponents.hour = hour
        dateComponents.minute = minute
        dateComponents.second = second
        if let date = Calendar.init(identifier: .gregorian).date(from: dateComponents) {
            return date
        } else {
            return nil
        }
    }
    
    func adding(hours: Int) -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        return calendar.date(byAdding: .hour, value: hours, to: self) ?? self
    }
    
    func adding(minutes: Int) -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        return calendar.date(byAdding: .minute, value: minutes, to: self) ?? self
    }
    
    func adding(seconds: Int) -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        return calendar.date(byAdding: .second, value: seconds, to: self) ?? self
    }
    
    func adding(days: Int) -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        return calendar.date(byAdding: .day, value: days, to: self) ?? self
    }
    
    func adding(months: Int) -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        return calendar.date(byAdding: .month, value: months, to: self) ?? self
    }
    
    func adding(year: Int) -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        return calendar.date(byAdding: .year, value: year, to: self) ?? self
    }
    
    func startOfWeek() -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        guard let weekStart: Date = calendar.date(from: calendar.dateComponents([  .yearForWeekOfYear, .weekOfYear], from: self)) else { fatalError("invalid date")}
        return weekStart
    }
    
    func endOfWeek() -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        guard let weekStart: Date = calendar.date(from: calendar.dateComponents([  .yearForWeekOfYear, .weekOfYear], from: self)) else { fatalError("invalid date")}
        guard let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) else { fatalError("invalid date") }
        guard let weekEnd = calendar.date(byAdding: .second, value: -1, to: weekEnd) else { fatalError("invalid date") }
        return weekEnd
    }
    
    func startOfMonth() -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        guard let monthStart: Date = calendar.date(from: calendar.dateComponents([  .month, .year], from: self)) else { fatalError("invalid date")}
        
        return monthStart
    }
    
    func endOfMonth() -> Date {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        guard let monthStart: Date = calendar.date(from: calendar.dateComponents([  .month, .year], from: self)) else { fatalError("invalid date")}
        guard let monthNextStart = calendar.date(byAdding: .month, value: 1, to: monthStart) else { fatalError("invalid date") }
        guard let monthEnd = calendar.date(byAdding: .second, value: -1, to: monthNextStart) else { fatalError("invalid date") }
        return monthEnd
    }
    
    func inSameDay(_ newDate: Date) -> Bool {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        let selfComps = calendar.dateComponents([.day, .month, .year], from: self)
        let newComps = calendar.dateComponents([.day, .month, .year], from: newDate)
        return selfComps.day == newComps.day && selfComps.month == newComps.month && selfComps.year == newComps.year
    }
    
    func inSameMonth(_ newDate: Date) -> Bool {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        let selfComps = calendar.dateComponents([.month, .year], from: self)
        let newComps = calendar.dateComponents([.month, .year], from: newDate)
        return selfComps.month == newComps.month && selfComps.year == newComps.year
    }
    
    func allDatesInMonth()->[Date] {
        var dates: [Date] = []
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        let components = DateComponents(hour: 0, minute: 0, second: 0)
        let endOfMonth = endOfMonth()
        calendar.enumerateDates(startingAfter: startOfMonth().adding(seconds: -1), matching: components, matchingPolicy: .strict, using: { date, strict, stop in
            if let date = date, date < endOfMonth {
                dates.append(date)
            } else {
                stop = true
            }
        })
        
        return dates
    }
    
    func local()->Date {
        adding(seconds: TimeZone.current.secondsFromGMT())
    }
    
    func utc()-> Date {
        adding(seconds: -TimeZone.current.secondsFromGMT())
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter.init()
        dateFormatter.locale = Locale.init(identifier: "en_US")
        dateFormatter.dateFormat = format
        dateFormatter.timeZone = TimeZone.init(secondsFromGMT: 0)
        return dateFormatter.string(from: self)
    }
    
    func dayInWeek() -> Int {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = TimeZone.init(secondsFromGMT: 0)!
        let dateComponents = calendar.dateComponents([ .weekday ], from: self)
        return dateComponents.weekday ?? 1
    }
    
    func hour(_ timeZone: TimeZone = TimeZone.init(secondsFromGMT: 0)!)->Int {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dateComponents = calendar.dateComponents([ .hour ], from: self.local())
        return dateComponents.hour ?? 0
    }
    
    func minute(_ timeZone: TimeZone = TimeZone.init(secondsFromGMT: 0)!)->Int {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dateComponents = calendar.dateComponents([ .minute ], from: self.local())
        return dateComponents.minute ?? 0
    }
    
    func month(_ timeZone: TimeZone = TimeZone.init(secondsFromGMT: 0)!)->Int {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dateComponents = calendar.dateComponents([ .month ], from: self.local())
        return dateComponents.month ?? 1
    }
    
    func year(_ timeZone: TimeZone = TimeZone.init(secondsFromGMT: 0)!)->Int {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dateComponents = calendar.dateComponents([ .year ], from: self.local())
        return dateComponents.year ?? 1900
    }
    
    func day(_ timeZone: TimeZone = TimeZone.init(secondsFromGMT: 0)!) -> Int {
        var calendar = Calendar.init(identifier: .gregorian)
        calendar.timeZone = timeZone
        let dateComponents = calendar.dateComponents([ .day ], from: self.local())
        return dateComponents.day ?? 1
    }
}
