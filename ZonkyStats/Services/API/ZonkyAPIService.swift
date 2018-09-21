//
//  ZonkyAPIService.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift
import Alamofire

protocol ZonkyAPIServicing {
    func getLoanCount(fromDate from: Date, untilDate until: Date) -> Observable<(Int, Error?)>
    func loadStatsDetail(for timeRange: TimeRange?,  statistics: Statistics, completion: @escaping ([(Date, Int)]?) -> Void)
}

/// Concrete class for creating api calls to server
class ZonkyAPIService: APIService, ZonkyAPIServicing {
    
    func getLoanCount(fromDate from: Date, untilDate until: Date) -> Observable<(Int, Error?)> {
        return Observable.create({ [unowned self] observer in
            let from = DateManager.current.stringDate(from: from)
            let until = DateManager.current.stringDate(from: until)
            _ = self.request("loans/marketplace"/*?datePublished__gte=\(from)&datePublished__lt=\(until)"*/, method: .head, parameters: ["datePublished__gte":from,"datePublished__lt":until], headers: [:]).subscribe(onNext: { data, response, error in
                guard let totalHeaderValue = response?.allHeaderFields["x-total"] as? String, let recordCount = Int(totalHeaderValue)
                    else { observer.onNext((0, error)); return }
                observer.onNext((recordCount,nil))
            }, onError: { error in
                observer.onError(error)
            })
            return Disposables.create()
        })
    }

    private static let baseURL = URL(string: "https://api.zonky.cz/")!
    override func resourceURL(for path: String) -> URL {
        return ZonkyAPIService.baseURL.appendingPathComponent(path)
    }
    
    func loadStatsDetail(for timeRange: TimeRange?, statistics: Statistics, completion: @escaping ([(Date, Int)]?) -> Void) {
        let timeFrames = timeRange == nil ? DateManager.current.getTimeFrames() : DateManager.current.getTimeFrames(from: timeRange!)
        var statisticalData = [(Date,Int)]()
        let dispatchGroup = DispatchGroup()
        for index in 0..<timeFrames.count-1 {
            dispatchGroup.enter()
            _ = getLoanCount(fromDate: timeFrames[index], untilDate: timeFrames[index+1]).subscribe(onNext: { count, error in
                if error != nil {
                    completion(nil)
                    dispatchGroup.leave()
                } else {
                    statisticalData.append((timeFrames[index],count))
                    dispatchGroup.leave()
                }
            }, onError: { error in
                dispatchGroup.leave()
            })
        }
        dispatchGroup.notify(queue: DispatchQueue.main) {
            statisticalData = statisticalData.sorted(by: { return $0.0 < $1.0})
            completion(statisticalData)
        }
    }
}
