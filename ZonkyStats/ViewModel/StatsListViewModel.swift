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
    func loadStatsList()
    var navigationTitle: String { get }
}

class StatsListViewModel: StatsListViewModelling {
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
        let numberOfLoansStats = Statistics(name: "Úvěrů na tržišti")
        statsList.value = [numberOfLoansStats]
    }
}
