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
        let statsListViewModel = StatsListViewModel()
        let statsListViewController = StatsListViewController(viewModel: statsListViewModel)
        navigationController.viewControllers = [statsListViewController]
    }
}

extension MainFlowViewController: DetailFlowProtocol {
    func didTapSwitchToDetail(statistics: Statistics) {
        let detailViewModel = StatsDetailViewModel()
        let statsDetailController = StatsDetailViewController(viewModel: detailViewModel)
        navigationController.pushViewController(statsDetailController, animated: true)
    }
}

