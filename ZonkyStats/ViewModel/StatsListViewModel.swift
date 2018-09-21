//
//  StatsListViewModel.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation
import RxSwift

protocol StatsListViewModelling {
    var statsList: Variable<[Statistics]> { get }
    func loadStatsDetail(statistics: Statistics, completion: @escaping ([(Date,Int)]?) -> Void)
    var navigationTitle: String { get }
    var isRefreshing: Variable<Bool> { get }
}

class StatsListViewModel: StatsListViewModelling {
   
    var isRefreshing: Variable<Bool> = Variable<Bool>(false)
    var navigationTitle: String = "Statistiky Zonky"
    var statsList: Variable<[Statistics]>
    let apiService: ZonkyAPIServicing

    init(apiService: ZonkyAPIServicing) {
        self.apiService = apiService
        self.statsList = Variable<[Statistics]>([])
        loadStatsList()
    }
    
    func loadStatsList() {
        //Hard coded list of statistics, in the future it can be retrieved from server
        let numberOfLoansStats = Statistics(name: "Úvěrů na tržišti", legend: "Počet úvěrů na tržišti celkem: ")
        statsList.value = [numberOfLoansStats]
    }
    func loadStatsDetail(statistics: Statistics, completion: @escaping ([(Date, Int)]?) -> Void) {
        isRefreshing.value = true
        apiService.loadStatsDetail(for: nil, statistics: statistics) { [unowned self] data in
            completion(data)
            self.isRefreshing.value = false
        }
    }
}
