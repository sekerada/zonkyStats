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
    func chartDataAggregateValue() -> Int
    var statistics: Statistics { get }
    var navigationTitle: String { get }
    var timeRangeOptions: [TimeRange] { get }
    var selectedTimeRange: Variable<TimeRange> { get }
    var lastLoadedTimeRange: TimeRange { get }
    var timeRangeTitle: Variable<String> { get }
    var isRefreshing: Variable<Bool> { get }
    var chartData: Variable<[(Date,Int)]> { get }
}

class StatsDetailViewModel: StatsDetailViewModelling {
    
    var statistics: Statistics
    var navigationTitle: String
    let apiService: ZonkyAPIServicing
    var timeRangeOptions: [TimeRange]
    var chartData: Variable<[(Date, Int)]>
    var selectedTimeRange: Variable<TimeRange>
    var lastLoadedTimeRange: TimeRange
    var timeRangeTitle: Variable<String> = Variable<String>("")
    var isRefreshing: Variable<Bool> = Variable<Bool>(false)
    
    init(statistics: Statistics, chartData: [(Date,Int)], apiService: ZonkyAPIServicing) {
        self.statistics = statistics
        self.navigationTitle = statistics.name
        self.apiService = apiService
        self.timeRangeOptions = DateManager.current.loadTimeRangeOptions()
        self.selectedTimeRange = Variable<TimeRange>(DateManager.current.defaultTimeRange)
        self.chartData = Variable<[(Date,Int)]>(chartData)
        self.lastLoadedTimeRange = DateManager.current.defaultTimeRange
    }
    
    func refreshStatsData() {
        if lastLoadedTimeRange.title == selectedTimeRange.value.title {
            return
        } else {
            isRefreshing.value = true
            apiService.loadStatsDetail(for: selectedTimeRange.value, statistics: statistics) { [unowned self] data in
                self.isRefreshing.value = false;
                guard let data = data else { self.selectedTimeRange.value = self.lastLoadedTimeRange; return }
                
                self.lastLoadedTimeRange = self.selectedTimeRange.value
                self.chartData.value = data
            }
        }
    }
    
    func chartDataAggregateValue() -> Int {
        var aggregate = 0
        chartData.value.forEach( { aggregate += $0.1})
        return aggregate
    }
    
}







