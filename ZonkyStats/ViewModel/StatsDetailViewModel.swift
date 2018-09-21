//
//  StatsDetailViewModel.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation
import RxSwift

protocol StatsDetailViewModelling {
    func refreshStatsData()
    var statistics: Statistics { get }
    var navigationTitle: String { get }
    var timeRangeOptions: [TimeRange] { get }
    var selectedTimeRange: Variable<TimeRange> { get }
    var timeRangeTitle: Variable<String> { get }
    var isRefreshing: Variable<Bool> { get }
}

class StatsDetailViewModel: StatsDetailViewModelling {
    
    var statistics: Statistics
    var navigationTitle: String
    let apiService: ZonkyAPIServicing
    var timeRangeOptions: [TimeRange]
    let dateFormatter = DateFormatter()
    let calendar = Calendar(identifier: .gregorian)
    let date = Date()
    lazy var selectedTimeRange: Variable<TimeRange> = {
        return Variable<TimeRange>(TimeRange(title: "posledních 12 měsíců", startTime: self.firstDayInMonth(numberOfMonths: -12)!))
    }()
    var timeRangeTitle: Variable<String> = Variable<String>("")

    
    init(statistics: Statistics, apiService: ZonkyAPIServicing) {
        self.statistics = statistics
        self.navigationTitle = statistics.name
        self.apiService = apiService
        self.timeRangeOptions = [TimeRange]()
        timeRangeTitle.value = "Pro statistiku níže jsou vybraná data za období: \(self.selectedTimeRange.value.startTime)."
    }
    
    func refreshStatsData() {
        
    }
    
    //Hard coded time ranges based on web version
    func loadTimeRangeOptions() {
        var timeRangeOptions = [TimeRange]()
        timeRangeOptions.append(TimeRange(title: "tento měsíc", startTime: firstDayInMonth(numberOfMonths: 0) ?? date))
        timeRangeOptions.append(TimeRange(title: "minulý měsíc", startTime: firstDayInMonth(numberOfMonths: -1) ?? date))
        timeRangeOptions.append(TimeRange(title: "poslední 3 měsíce", startTime: firstDayInMonth(numberOfMonths: -3) ?? date))
        timeRangeOptions.append(TimeRange(title: "posledních 6 měsíců", startTime: firstDayInMonth(numberOfMonths: -6) ?? date))
        timeRangeOptions.append(TimeRange(title: "posledních 12 měsíců", startTime: firstDayInMonth(numberOfMonths: -12) ?? date))
        timeRangeOptions.append(TimeRange(title: "rok 2016", startTime: dateFormatter.date(from: "2016-01-01")!))
        timeRangeOptions.append(TimeRange(title: "rok 2017", startTime: dateFormatter.date(from: "2017-01-01")!))
        timeRangeOptions.append(TimeRange(title: "od počátku věků", startTime: dateFormatter.date(from: "2015-04-01")!))
    }
    
    

    func firstDayInMonth(numberOfMonths: Int ) -> Date? {
        //Use negative number to retrieve previous month or 0 to retrieve actual month
        dateFormatter.dateFormat =  "yyyy-MM-dd"
        let components = calendar.dateComponents([.year, .month, .day], from: Calendar.current.date(byAdding: .month, value: numberOfMonths, to: date)!)
        guard let year = components.year, let month = components.month, let startDate = dateFormatter.date(from: "\(year)-\(month)-01") else { return nil }
        return startDate
    }
    
}







