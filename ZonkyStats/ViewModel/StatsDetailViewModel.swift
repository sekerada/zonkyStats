//
//  StatsDetailViewModel.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation

protocol StatsDetailViewModelling {
    var statistics: Statistics { get }
    func refreshStatsData()
    var navigationTitle: String { get }
}

class StatsDetailViewModel: StatsDetailViewModelling {
    
    var statistics: Statistics
    var navigationTitle: String
    let apiService: ZonkyAPIServicing
    
    init(statistics: Statistics, apiService: ZonkyAPIServicing) {
        self.statistics = statistics
        self.navigationTitle = statistics.name
        self.apiService = apiService
    }
    
    func refreshStatsData() {
        
    }
}
