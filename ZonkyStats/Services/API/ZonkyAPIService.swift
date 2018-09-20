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
    func getLoans()
}

/// Concrete class for creating api calls to server
class ZonkyAPIService: APIService, ZonkyAPIServicing {
    
    private static let baseURL = URL(string: "https://api.zonky.cz/")!
    override func resourceURL(for path: String) -> URL {
        return ZonkyAPIService.baseURL.appendingPathComponent(path)
    }
    
    func getLoans() {
        _ = network.request("/loans/marketplace", method: .get, parameters: [:], encoding: URLEncoding.default, headers: nil).subscribe(onNext: { data, error in })
    }
}
