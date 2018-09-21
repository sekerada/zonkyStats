//
//  StatsDetailViewController.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import UIKit
import Charts
import SnapKit
import RxSwift
import RxCocoa

class StatsDetailViewController: UIViewController {

    let viewModel: StatsDetailViewModelling
    weak var chartView: BarChartView!
    weak var changeRangeButton: UIButton!
    weak var rangeTextField: UITextField!
    weak var rangeLabel: UILabel!
    weak var doneButton: UIBarButtonItem!
    init(viewModel: StatsDetailViewModelling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        changeRangeButton = UIButton()
        changeRangeButton.titleLabel?.textAlignment = .left
        changeRangeButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        changeRangeButton.setTitle("Zmenit rozsah dat", for: .normal)
        
        rangeLabel = UILabel()
        rangeLabel.textAlignment = .left
        rangeLabel.font = UIFont.systemFont(ofSize: 17)
        rangeLabel.numberOfLines = 0
        rangeLabel.text = "Pro statistiku níže jsou vybraná data za období \(viewModel) až 2018-08-31 (91 dní)."
        
        rangeTextField = UITextField()
        rangeTextField.alpha = 0
        rangeTextField.isEnabled = false
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.doneButton = UIBarButtonItem(title: "Hotovo", style: .done, target: nil, action: nil)
        toolBar.items = [flexibleSeparator,doneButton]
        
        chartView = BarChartView()
        
        let descriptionVStack = UIStackView(arrangedSubviews: [changeRangeButton,rangeLabel, rangeTextField, chartView])
        descriptionVStack.axis = .vertical
        self.view.addSubview(descriptionVStack)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _ = doneButton.rx.tap.asObservable().subscribe(onNext: { [unowned self] tap in
            self.rangeTextField.resignFirstResponder()
            self.viewModel.refreshStatsData()
        })
        
        _ = viewModel.timeRangeTitle.asObservable().subscribe(onNext: { [unowned self] value in
            self.rangeLabel.text = value
        })
    
        _ = changeRangeButton.rx.tap.subscribe(onNext: { [unowned self] tap in
            self.rangeTextField.becomeFirstResponder()
        })
    }
    
    func setupBindings() {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension StatsDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.timeRangeOptions.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return viewModel.timeRangeOptions[row].title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedTimeRange.value = viewModel.timeRangeOptions[row]
    }
}
