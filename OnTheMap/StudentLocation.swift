//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit

struct StudentLocation {
	var objectId: String?
	var uniqueKey: String
	var firstName: String
	var lastName: String
	var mapString: String
	var mediaUrl: String
	var latitude: Double
	var longitude: Double
}

struct APIConstants {
	static let API_URL = "https://api.parse.com/1/classes/StudentLocation"
	static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	static let APIKEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	static let signUpUdacity = "https://www.udacity.com/account/auth#!/signup"
	static let API_SESSION = "https://www.udacity.com/api/session"
	static let UDACITY_ME = "https://www.udacity.com/api/users/me"
}

class APIStuff {
	static let appDelegate = (UIApplication.sharedApplication().delegate) as! AppDelegate

	class func getStudents(callback: (() -> ())?) {
		let request = NSMutableURLRequest(URL: NSURL(string: APIConstants.API_URL + "?limit=100")!)
		request.addValue(APIConstants.appID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(APIConstants.APIKEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			if let error = error {
				print(error.localizedDescription)
			}
			var json: AnyObject
			do {
				json = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
			} catch {
				print("Something happened")
				return
			}
			if let results = json["results"] as? NSArray {
				results.forEach {
					let result = $0 as! NSDictionary
					self.appDelegate.students.append(StudentLocation(
						objectId: result["objectId"] as? String,
						uniqueKey: result["uniqueKey"] as! String,
						firstName: result["firstName"] as! String,
						lastName: result["lastName"] as! String,
						mapString: result["mapString"] as! String,
						mediaUrl: result["mediaURL"] as! String,
						latitude: result["latitude"] as! Double,
						longitude: result["longitude"] as! Double))
				}
				callback?()
			}
		}
		task.resume()
	}

	class func postLocation(callback: ((success: Bool, message: String?) -> ())?) {
		var url: String
		var method: String
		if let objectId = self.appDelegate.thisStudent.objectId where objectId != "" {
			url = APIConstants.API_URL + "/\(objectId)"
			method = "PUT"
		} else {
			url = APIConstants.API_URL
			method = "POST"
		}
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = method
		request.addValue(APIConstants.appID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(APIConstants.APIKEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		request.HTTPBody = "{\"uniqueKey\": \"\(self.appDelegate.thisStudent.uniqueKey)\", \"firstName\": \"\(self.appDelegate.thisStudent.firstName)\", \"lastName\": \"\(self.appDelegate.thisStudent.lastName)\",\"mapString\": \"\(self.appDelegate.thisStudent.mapString)\", \"mediaURL\": \"\(self.appDelegate.thisStudent.mediaUrl)\",\"latitude\": \(self.appDelegate.thisStudent.latitude), \"longitude\": \(self.appDelegate.thisStudent.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)

		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			if let error = error {
				print(error.localizedDescription)
			}
			var obj: AnyObject
			do {
				obj = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
			} catch {
				print("Something happened here")
				return
			}
			print(obj as? NSDictionary)
			if let objectId = obj["objectId"] as? String {
				self.appDelegate.thisStudent.objectId = objectId
			} else if let error = obj["error"] as? String {
				callback?(success: false, message: error)
			}
			callback?(success: true, message: nil)
		}
		task.resume()
	}

	class func deleteEntry(objectId: String, callback: (() -> ())?) {
		let url = APIConstants.API_URL + "/\(objectId)"
		let request = NSMutableURLRequest(URL: NSURL(string: url)!)
		request.HTTPMethod = "DELETE"
		request.addValue(APIConstants.appID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(APIConstants.APIKEY, forHTTPHeaderField: "X-Parse-REST-API-Key")

		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			if let error = error {
				print(error.localizedDescription)
			}
			var obj: AnyObject
			do {
				obj = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments)
			} catch {
				print("Something happened here")
				return
			}
			print(obj as? NSDictionary)
			callback?()
		}
		task.resume()
	}

}