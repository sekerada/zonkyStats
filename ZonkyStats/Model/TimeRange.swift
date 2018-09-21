//
//  TimeRange.swift
//  ZonkyStats
//
//  Created by Adam Sekeres on 21.9.18.
//  Copyright © 2018 Adam Sekeres. All rights reserved.
//

import Foundation

class TimeRange {
    
    let title: String
    let startTime: Date
    let endTime: Date
    
    init(title:  String, startTime: Date, endTime: Date = Date()) {
        self.title = title
        self.startTime = startTime
        self.endTime = endTime
    }
}
