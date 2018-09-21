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
import PKHUD

class StatsDetailViewController: UIViewController {

    let viewModel: StatsDetailViewModelling
    var chartView: BarChartView = BarChartView()
    var changeRangeButton = UIButton()
    var rangeTextField = UITextField()
    var rangeLabel = UILabel()
    var doneButton = UIBarButtonItem()
    let pickerView = UIPickerView()
    
    init(viewModel: StatsDetailViewModelling) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = UIColor.white
        changeRangeButton.contentHorizontalAlignment = .left
        changeRangeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        changeRangeButton.setTitleColor(.blue, for: .normal)
        changeRangeButton.setTitle("Zmenit rozsah dat", for: .normal)
        
        rangeLabel = UILabel()
        rangeLabel.textAlignment = .left
        rangeLabel.font = UIFont.systemFont(ofSize: 17)
        rangeLabel.numberOfLines = 0
        rangeLabel.text = "Pro statistiku níže jsou vybraná data za období: \(viewModel.selectedTimeRange.value.title)"
        
        rangeTextField = UITextField()
        rangeTextField.alpha = 0
        //rangeTextField.isEnabled = false
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
        
        let toolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 44))
        let flexibleSeparator = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        self.doneButton = UIBarButtonItem(title: "Hotovo", style: .done, target: nil, action: nil)
        toolBar.items = [flexibleSeparator,doneButton]
        rangeTextField.inputView = pickerView
        rangeTextField.inputAccessoryView = toolBar
        chartView = BarChartView()
        chartView.noDataText = "K dispozici nejsou žádné data"
        let descriptionVStack = UIStackView(arrangedSubviews: [rangeLabel,changeRangeButton,rangeTextField, chartView])
        descriptionVStack.axis = .vertical
        self.view.addSubview(descriptionVStack)
        descriptionVStack.translatesAutoresizingMaskIntoConstraints = false
        rangeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.topMargin).offset(10)
            make.left.equalTo(view.snp.left).offset(5)
            make.right.equalTo(view.snp.right).offset(-5)
        }
        changeRangeButton.snp.makeConstraints { (make) in
            make.height.equalTo(40)
        }
        chartView.snp.makeConstraints { (make) in
            make.height.equalTo(view.snp.height).multipliedBy(0.5)
        }
        navigationItem.title = viewModel.statistics.name
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        guard let defaultIndex = viewModel.timeRangeOptions.index(where: { $0.title == viewModel.selectedTimeRange.value.title}) else { return }
        pickerView.selectRow(defaultIndex, inComponent: 0, animated: false)
    }
    func setupBindings() {
        _ = doneButton.rx.tap.asObservable().subscribe(onNext: { [unowned self] tap in
            
            self.rangeTextField.resignFirstResponder()
            self.viewModel.refreshStatsData()
        })
        _ = viewModel.selectedTimeRange.asObservable().subscribe(onNext: { [unowned self] value in
            let attributedTitle = NSMutableAttributedString(string: "Pro statistiku níže jsou vybraná data za období: ")
            attributedTitle.append(NSAttributedString(string: "\(value.title)", attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16, weight: .semibold)]))
            self.rangeLabel.attributedText =  attributedTitle
        })
        _ = changeRangeButton.rx.tap.subscribe(onNext: { [unowned self] tap in
            self.rangeTextField.becomeFirstResponder()
        })
        _ = viewModel.isRefreshing.asObservable().subscribe(onNext: { value in
            if value {
                HUD.show(HUDContentType.progress)
            } else {
                HUD.hide()
            }
        })
        _ = viewModel.chartData.asObservable().subscribe(onNext: { [unowned self] value in
            self.renderGraph()
        })
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


//MARK: Graph related methods
extension StatsDetailViewController {
    func renderGraph() {
        print("ChartData.count = \(viewModel.chartData.value.count)")
        if !viewModel.chartData.value.isEmpty {
            var barEntries = [BarChartDataEntry]()
            for index in 0..<viewModel.chartData.value.count {
                let barEntry = BarChartDataEntry(x: Double(index), y: Double(viewModel.chartData.value[index].1))
                barEntries.append(barEntry)
            }
            
            let dataSet = BarChartDataSet(values: barEntries, label: "\(viewModel.statistics.legendDescription)\(viewModel.chartDataAggregateValue())")
            let chartLegend = chartView.legend
            chartLegend.textWidthMax = 100
            chartLegend.enabled = true
            chartLegend.horizontalAlignment = .left
            chartLegend.verticalAlignment = .top
            chartView.chartDescription?.text = ""
            
            dataSet.setColor(NSUIColor.blue)
            
            let formatter = MyAxisFormatter(values: DateManager.current.graphFormattedDates(from: viewModel.chartData.value.map{ $0.0 }))
            print("AxisFormatter.values.count = \(formatter.values.count)")
            let xaxis:XAxis = self.chartView.xAxis
            xaxis.wordWrapEnabled = true
            xaxis.labelPosition = .bottom
            xaxis.valueFormatter = formatter
            xaxis.granularityEnabled = true
            xaxis.granularity = 1
            //xaxis.labelHeight = 1.2
            //xaxis.labelWidth = 0.8
            
            self.chartView.data = BarChartData(dataSet: dataSet)
            
            self.chartView.fitBars = false
            
            switch UIDevice.current.userInterfaceIdiom {
            case .pad:
                switch UIDevice.current.orientation {
                    case .portrait: chartView.setVisibleXRangeMaximum(20)
                    case .landscapeLeft, .landscapeRight: chartView.setVisibleXRangeMaximum(40)
                    default: break
                }
            case .phone:
                switch UIDevice.current.orientation {
                    case .portrait: chartView.setVisibleXRangeMaximum(10)
                    case .landscapeLeft, .landscapeRight: chartView.setVisibleXRangeMaximum(20)
                    default: break
                }
            default: break
            }
            
            chartView.resetZoom()
            chartView.scaleYEnabled = false
            chartView.notifyDataSetChanged()
            chartView.animate(xAxisDuration: 1.5, yAxisDuration: 1.5, easingOption: ChartEasingOption.linear)
        }
    }
}


//Class used to format graph axis
class MyAxisFormatter: IndexAxisValueFormatter {
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return Int(value) < values.count ? values[Int(value)] : ""
    }
    override init(values: [String]) {
        super.init(values: values)
        self.values = values
    }
}


//MARK: PickerView delegate methods
extension StatsDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return viewModel.timeRangeOptions.count
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let timeRange = viewModel.timeRangeOptions[row]
        return timeRange.title
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        viewModel.selectedTimeRange.value = viewModel.timeRangeOptions[row]
    }
}
