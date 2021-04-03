//
//  ConfigurationRepository.swift
//  Relic
//
//  Created by Murat Yakici on 02/04/2021.
//  Copyright © 2021 DX Wave Limited. All rights reserved.
//

import Foundation
import Firebase

class ConfigurationRepository {
    var remoteConfig: RemoteConfig!

    func setup() {
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        #if DEBUG
        settings.minimumFetchInterval = 0
        #endif
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
    }

    func maxNumTasks() -> Int {
        return remoteConfig["max_num_tasks"].numberValue?.intValue ?? 10 //Default
    }

    func stringConfiguration(for key: String) -> String? {
        remoteConfig[key].stringValue
    }

    func booleanConfiguration(for key: String) -> Bool {
        remoteConfig[key].boolValue
    }

    func fetchConfig() {

        remoteConfig.fetch() { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate() { (changed, error) in
                    // ...
                }
            } else {
                print("Config not fetched")
                print("Error: \(error?.localizedDescription ?? "No error available.")")
            }
        }
    }
}
