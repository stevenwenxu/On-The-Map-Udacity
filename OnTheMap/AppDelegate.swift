//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit

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
	var objectId: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentObjectId")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentObjectId") as! String?
		}
	}
	var uniqueKey: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentUniqueKey")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentUniqueKey") as! String?
		}
	}
	var firstName: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentFirstName")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentFirstName") as! String?
		}
	}
	var lastName: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentLastName")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentLastName") as! String?
		}
	}
	var mapString: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentMapString")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentMapString") as! String?
		}
	}
	var mediaUrl: String? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentMediaUrl")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentMediaUrl") as! String?
		}
	}
	var latitude: Double? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentLatitude")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentLatitude") as! Double?
		}
	}
	var longitude: Double? {
		set {
			NSUserDefaults.standardUserDefaults().setValue(newValue, forKey: "studentLongitude")
		}
		get {
			return NSUserDefaults.standardUserDefaults().valueForKey("studentLongitude") as! Double?
		}
	}

	var students: [StudentLocation] = []

}

