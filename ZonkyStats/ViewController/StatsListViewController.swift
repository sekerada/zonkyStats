//
//  StatsListViewController.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import UIKit
import PKHUD

protocol DetailFlowProtocol {
    func didTapSwitchToDetail(statistics: Statistics, chartData: [(Date, Int)])
}

class StatsListViewController: UITableViewController {

    let viewModel: StatsListViewModelling
    var detailFlowDelegate: DetailFlowProtocol?

    init(viewModel: StatsListViewModelling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupBindings() {
        _ = viewModel.statsList.asObservable().subscribe(onNext: { [unowned self] data in
            self.tableView.reloadData()
        })
        _ = viewModel.isRefreshing.asObservable().subscribe(onNext: { value in
            if value {
                HUD.show(HUDContentType.progress)
            } else {
                HUD.hide()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.tableFooterView = UIView()
        navigationItem.title = viewModel.navigationTitle
        setupBindings()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.statsList.value.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) 
        cell.textLabel?.text = viewModel.statsList.value[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate = detailFlowDelegate else { return }
        viewModel.loadStatsDetail(statistics: viewModel.statsList.value[indexPath.row]) { [unowned self] data in
            guard let data = data else { HUD.flash(HUDContentType.error); return }
            delegate.didTapSwitchToDetail(statistics: self.viewModel.statsList.value[indexPath.row], chartData: data)
        }
    }
}
