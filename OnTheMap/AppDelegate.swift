//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	var sessionId: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "udacitySessionId")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("udacitySessionId") as! String?
		}
	}

	var uniqueKeyThatPostedLocation: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "udacityUniqueKey")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("udacityUniqueKey") as! String?
		}
	}

	var thisStudent = StudentLocation(
		objectId: "",
		uniqueKey: "",
		firstName: "",
		lastName: "",
		mapString: "",
		mediaUrl: "",
		latitude: 0.0,
		longitude: 0.0)

	var students: [StudentLocation] = []

	let fbLoginManager = FBSDKLoginManager()

	func applicationDidBecomeActive(application: UIApplication) {
		FBSDKAppEvents.activateApp()
	}

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
		FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
		let _ = FBSDKLoginButton()
		return true
	}

	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
		return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
	}

}

