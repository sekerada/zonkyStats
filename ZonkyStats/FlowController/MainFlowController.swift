//
//  MainFlowController.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation
import UIKit

class MainFlowViewController {
    
    private let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let apiService = ZonkyAPIService(network: Network())
        let statsListViewModel = StatsListViewModel(apiService: apiService)
        let statsListViewController = StatsListViewController(viewModel: statsListViewModel)
        statsListViewController.detailFlowDelegate = self
        navigationController.viewControllers = [statsListViewController]
    }
}

extension MainFlowViewController: DetailFlowProtocol {
    func didTapSwitchToDetail(statistics: Statistics, chartData: [(Date, Int)]) {
        let apiService = ZonkyAPIService(network: Network())
        let detailViewModel = StatsDetailViewModel(statistics: statistics, chartData: chartData, apiService: apiService)
        let statsDetailController = StatsDetailViewController(viewModel: detailViewModel)
        self.navigationController.topViewController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController.pushViewController(statsDetailController, animated: true)
    }
}

