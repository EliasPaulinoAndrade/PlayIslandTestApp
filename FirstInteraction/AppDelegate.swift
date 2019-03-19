//
//  AppDelegate.swift
//  FirstInteraction
//
//  Created by Elias Paulino on 15/03/19.
//  Copyright © 2019 Elias Paulino. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    static let slots: [PieceSlot] = [
        PieceSlot.init(pieceType: .clockTower, quantity: 2, color: .green),
        PieceSlot.init(pieceType: .block1x1, quantity: 2, color: .green),
        PieceSlot.init(pieceType: .block2x1, quantity: 5, color: .blue),
        PieceSlot.init(pieceType: .block3x1, quantity: 3, color: .red),
        PieceSlot.init(pieceType: .block2x2, quantity: 1, color: .pink),
        PieceSlot.init(pieceType: .block2x2, quantity: 1, color: .red),
        PieceSlot.init(pieceType: .arch2x2, quantity: 3, color: .green),
        PieceSlot.init(pieceType: .arch1x1, quantity: 3, color: .green),
        PieceSlot.init(pieceType: .ceil, quantity: 1, color: .green),
        PieceSlot.init(pieceType: .floorSideWalk, quantity: 3, color: .green),
        PieceSlot.init(pieceType: .floorAsphalt, quantity: 3, color: .green)
    ]

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow.init(frame: UIScreen.main.bounds)
        
        let firstController = GameViewController.init()
        
        window?.rootViewController = firstController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

