//
//  AppDelegate.swift
//  A Day at Montmartre
//
//  Created by Michael Kühweg on 27.12.17.
//  Copyright © 2017 Michael Kühweg. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?)
        -> Bool {
        // using a pseudo random number generator - and please do NOT produce the same sequence
        // each time the app runs
        let time = UInt32(NSDate().timeIntervalSinceReferenceDate)
        srand48(Int(time))

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        viewController()?.stopApproximation()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        viewController()?.stopApproximation()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        viewController()?.restartApproximatorIfSettingsChanged()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        viewController()?.restartApproximatorIfSettingsChanged()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        viewController()?.stopApproximation()
    }

    private func viewController() -> ViewController? {
        return self.window?.rootViewController as? ViewController
    }

}
