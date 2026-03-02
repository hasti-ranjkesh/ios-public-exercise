//
//  AppDelegate.swift
//  Exercise
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	private var appCoordinator: AppCoordinator?
	var window: UIWindow?

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		let window = UIWindow()
		self.window = window
		appCoordinator = AppCoordinator(window: window)
		appCoordinator?.start()
		return true
	}
}
