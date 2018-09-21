//
//  Network.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 20.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation
import Alamofire
import Reqres
import RxSwift

struct NetworkError: Error {
    let error: NSError
    let request: URLRequest?
    let response: HTTPURLResponse?
}


protocol Networking {
    func request(_ url: String, method: Alamofire.HTTPMethod, parameters: [String: Any], encoding: ParameterEncoding, headers: [String:String]?) -> Observable<(Data?, HTTPURLResponse?, NetworkError?)>
}


class Network: Networking {
    
    let alamofireManager : SessionManager
    
    init() {
        let configuration = Reqres.defaultSessionConfiguration()
        
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        alamofireManager =  Alamofire.SessionManager(configuration: configuration)
    }
    
    func request(_ url: String, method: HTTPMethod, parameters: [String : Any], encoding: ParameterEncoding = URLEncoding.default, headers: [String : String]?) -> Observable<(Data?,HTTPURLResponse?, NetworkError?)> {
        return Observable.create({ observer in
            self.alamofireManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers).validate().responseJSON(completionHandler: {
                let data = $0.data, response = $0.response, error = $0.error, request = $0.request
                switch (data, error) {
                case (_, .some(let e)): observer.onNext((nil, response, NetworkError(error: e as NSError, request: request, response: response)))
                case (.some(let d), _): observer.onNext((d, response, nil))
                default: break
                }
                observer.onCompleted()
            })
            return Disposables.create()
        })
    }
}
