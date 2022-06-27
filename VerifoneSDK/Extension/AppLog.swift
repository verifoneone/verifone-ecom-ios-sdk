//
//  AppLog.swift
//  VerifoneSDK
//
//  Created by Oraz Atakishiyev on 21.10.2021.
//

import os
class AppLog {
    static func log(_ message: StaticString, log: OSLog = .default, type: OSLogType = .default, _ args: CVarArg...) {
        os_log(message, log: uiLogObject, type: .default, args)
    }
}
