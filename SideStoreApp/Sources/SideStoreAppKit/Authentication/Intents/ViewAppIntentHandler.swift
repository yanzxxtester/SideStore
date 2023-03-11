//
//  ViewAppIntentHandler.swift
//  ViewAppIntentHandler
//
//  Created by Riley Testut on 7/10/20.
//  Copyright © 2020 Riley Testut. All rights reserved.
//

import Intents
import SideStoreCore
import os.log

@available(iOS 14, *)
public class ViewAppIntentHandler: NSObject, ViewAppIntentHandling {
    public func provideAppOptionsCollection(for intent: ViewAppIntent, with completion: @escaping (INObjectCollection<App>?, Error?) -> Void) {
        DatabaseManager.shared.start { error in
            if let error = error {
                os_log("Error starting extension: %@", type: .error , error.localizedDescription)
			} else {
				os_log("Started extension: %@", type: .info , intent.debugDescription)
			}

            DatabaseManager.shared.persistentContainer.performBackgroundTask { context in
                let apps = InstalledApp.all(in: context).map { installedApp in
                    App(identifier: installedApp.bundleIdentifier, display: installedApp.name)
                }

                let collection = INObjectCollection(items: apps)
                completion(collection, nil)
            }
        }
    }
}
