//
//  DateManager.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 21.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation

class DateManager {
    
    let dateFormatter = DateFormatter()
    let calendar = Calendar(identifier: .gregorian)
    static let current = DateManager()
    private let defaultDateFormat = "yyyy-MM-dd"
    var timeRanges: [TimeRange]!
    var defaultTimeRange: TimeRange!
    
    init() {
        dateFormatter.dateFormat = defaultDateFormat
        timeRanges = loadTimeRangeOptions()
        defaultTimeRange = TimeRange(title: "posledních 12 měsíců", startTime: firstDayInMonth(numberOfMonths: -12))
    }
    
    func firstDayInMonth(from date: Date = Date(), numberOfMonths: Int ) -> Date {
        //Use negative number to retrieve previous month or 0 to retrieve actual month
        let components = calendar.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .month, value: numberOfMonths, to: date)!)
        guard let year = components.year, let month = components.month, let startDate = dateFormatter.date(from: "\(year)-\(month)-01") else { return date }
        return startDate
    }
    
    func statisticalDateFormat(from date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM"
        let statisticalDate = dateFormatter.string(from: date)
        dateFormatter.dateFormat = defaultDateFormat
        return statisticalDate
    }
    
    func stringDate(from date: Date) -> String {
        dateFormatter.dateFormat = defaultDateFormat
        return dateFormatter.string(from:date)
    }
    
    // Function used to retrieve specific time frames 
    func getTimeFrames(from timeRange: TimeRange = DateManager.current.defaultTimeRange) -> [Date] {
        var timeFrames = [Date]()
        var time = timeRange.startTime
        while time <= timeRange.endTime {
            timeFrames.append(time)
            let nextMonths = firstDayInMonth(from: time, numberOfMonths: 1)
            time = nextMonths
        }
        return timeFrames
    }
    
    func loadTimeRangeOptions() -> [TimeRange] {
        var timeRangeOptions = [TimeRange]()
        timeRangeOptions.append(TimeRange(title: "tento měsíc", startTime: firstDayInMonth(numberOfMonths: 0)))
        timeRangeOptions.append(TimeRange(title: "minulý měsíc", startTime: firstDayInMonth(numberOfMonths: -1)))
        timeRangeOptions.append(TimeRange(title: "poslední 3 měsíce", startTime: firstDayInMonth(numberOfMonths: -3)))
        timeRangeOptions.append(TimeRange(title: "posledních 6 měsíců", startTime: firstDayInMonth(numberOfMonths: -6)))
        timeRangeOptions.append(TimeRange(title: "posledních 12 měsíců", startTime: firstDayInMonth(numberOfMonths: -12)))
        timeRangeOptions.append(TimeRange(title: "rok 2016", startTime: dateFormatter.date(from: "2016-01-01")!, endTime: dateFormatter.date(from: "2016-12-31")!))
        timeRangeOptions.append(TimeRange(title: "rok 2017", startTime: dateFormatter.date(from: "2017-01-01")!, endTime: dateFormatter.date(from: "2017-12-31")!))
        timeRangeOptions.append(TimeRange(title: "od počátku věků", startTime: dateFormatter.date(from: "2015-04-01")!))
        return timeRangeOptions
    }
    
    func graphFormattedDates(from dates: [Date]) -> [String] {
        var formattedDates = [String]()
        for date in dates {
            dateFormatter.dateFormat = "yyyy-MM"
            formattedDates.append(dateFormatter.string(from: date))
        }
        dateFormatter.dateFormat = defaultDateFormat
        return formattedDates
    }
}
