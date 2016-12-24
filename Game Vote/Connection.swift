//
//  Connection.swift
//  Game Vote
//
//  Created by Tobias Kreiman on 6/21/16.
//  Copyright © 2016 Tobias Kreiman. All rights reserved.
//

import Foundation

class Connection {
    
    static func isConnectedToInternet() -> Bool {
        do {
            let r = try Reachability.reachabilityForInternetConnection()
            if r.isReachable() {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }

    }
}