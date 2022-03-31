# DatePickerlib

This is a simple to use iOS Date time picker.


## Screenshots

<p float="left">
  <img src="https://github.com/cloudapperinc/DatePickerlib/blob/main/Screenshots/1.png" width="20%">
  <img src="https://github.com/cloudapperinc/DatePickerlib/blob/main/Screenshots/2.png" width="20%">
  <img src="https://github.com/cloudapperinc/DatePickerlib/blob/main/Screenshots/3.png" width="20%">
  <img src="https://github.com/cloudapperinc/DatePickerlib/blob/main/Screenshots/4.png" width="20%">
  <img src="https://github.com/cloudapperinc/DatePickerlib/blob/main/Screenshots/5.png" width="20%">
</p>


## Sample codes

1. To open DateTime picker then you can use the following code:
  ```swift
        let date = selectedDate == nil ? Date() : selectedDate!
        DatePicker.show(.init(date: date, pickerType: .DateTime, title: "SELECT DATE TIME", cancelCallback: {
            print("Canceled")
        }, doneCallback: { [weak self] in
            print("Selected date: \($0)")
            self?.tfDatepicker.text = "\($0.toString(format: "MMM dd, yyyy hh:mm aa"))"
            self?.selectedDate = $0
        }), on: self)
  ```
  
Generally these are the data you need to pass

```swift
public struct DatePickerBundle {
    public var date: Date
    public var pickerType: DatePickerType = .DateTime
    public var minDate: Date = Date.prepare(day: 1, month: 1, year: 1900) ?? Date()
    public var maxDate: Date = Date.prepare(day: 31, month: 12, year: 2100, hour: 23, minute: 59, second: 59) ?? Date()
    public var title: String
    public var cancelButtonText: String
    public var doneButtonText: String
    public var cancelCallback: ()->Void
    public var doneCallback: (_ newDate: Date)->Void
}
```
