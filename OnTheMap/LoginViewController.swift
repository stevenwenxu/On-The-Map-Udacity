//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate, FBSDKLoginButtonDelegate {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var facebookLoginButton: FBSDKLoginButton!

	var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	// - MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		let tapGesture = UITapGestureRecognizer(target: self, action: "viewDidTap")
		self.emailTextField.delegate = self
		self.passwordTextField.delegate = self
		self.view.addGestureRecognizer(tapGesture)
		self.facebookLoginButton.delegate = self
		self.facebookLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if let id = NSUserDefaults.standardUserDefaults().valueForKey("udacitySessionId") as? String {
			self.appDelegate.sessionId = id
			self.storeUserInfo()
			self.performSegueWithIdentifier("loggedIn", sender: nil)
		}
	}

	// - MARK: Events

	@IBAction func signUpDidPress() {
		UIApplication.sharedApplication().openURL(NSURL(string: APIConstants.signUpUdacity)!)
	}


	func viewDidTap() {
		self.view.endEditing(true)
	}
	
	@IBAction func loginDidTap() {
		self.logIn(nil)
		self.view.endEditing(true)
	}

	func logIn(facebookToken: String?) {
		let request = NSMutableURLRequest(URL: NSURL(string: APIConstants.API_SESSION)!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		if let token = facebookToken {
			request.HTTPBody = "{\"facebook_mobile\": {\"access_token\": \"\(token)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
		} else {
			request.HTTPBody = "{\"udacity\": {\"username\": \"\(self.emailTextField.text!)\", \"password\": \"\(self.passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
		}

		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			if let error = error {
				dispatch_async(dispatch_get_main_queue()) {
					let alert = UIAlertController(title: "Error", message: "Log in failed\n\(error.localizedDescription)", preferredStyle: .Alert)
					let action = UIAlertAction(title: "Okay", style: .Default, handler: nil)
					alert.addAction(action)
					self.presentViewController(alert, animated: true, completion: nil)
				}
				return
			}
			let data = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
			var json: AnyObject
			do {
				json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			} catch {
				print("Something happened")
				return
			}
			if let statusCode = json["status"] as? Int {
				if statusCode != 200 {
					print("Something happened: \(json as? NSDictionary)")
					dispatch_async(dispatch_get_main_queue()) {
						let alert = UIAlertController(title: "Error logging in", message: json["error"] as? String, preferredStyle: .Alert)
						alert.addAction(UIAlertAction(title: "Okay", style: .Default, handler: nil))
						self.presentViewController(alert, animated: true, completion: nil)
					}
				}
			}
			if let session = json["session"] as? NSDictionary {
				if let id = session["id"] as? String {
					self.appDelegate.sessionId = id
					self.storeUserInfo()
					dispatch_async(dispatch_get_main_queue()) {
						self.performSegueWithIdentifier("loggedIn", sender: nil)
					}
				}
			}
		}
		task.resume()
	}

	func storeUserInfo() {
		let request = NSMutableURLRequest(URL: NSURL(string: APIConstants.UDACITY_ME)!)
		request.HTTPMethod = "GET"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			if let error = error {
				print(error)
			}
			let data = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
			var obj: AnyObject
			do {
				obj = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			} catch {
				print("Something happened")
				return
			}
			if let userDict = obj["user"] as? NSDictionary {
				self.appDelegate.thisStudent.objectId = ""
				self.appDelegate.thisStudent.uniqueKey = userDict["key"] as! String
				self.appDelegate.thisStudent.firstName = userDict["first_name"] as! String
				self.appDelegate.thisStudent.lastName = userDict["last_name"] as! String
				self.appDelegate.thisStudent.mapString =  ""
				self.appDelegate.thisStudent.mediaUrl = ""
				self.appDelegate.thisStudent.latitude = 0.0
				self.appDelegate.thisStudent.longitude = 0.0
			}
		}
		task.resume()
	}

	// - MARK: UITextFieldDelegate
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		if textField == self.emailTextField {
			self.passwordTextField.becomeFirstResponder()
		} else if textField == self.passwordTextField {
			textField.resignFirstResponder()
			self.logIn(nil)
		}
		return false
	}

	// - MARK: FBSDKLoginButtonDelegate
	func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
		if let error = error {
			print(error.localizedDescription)
		}
		if let result = result {
			if result.isCancelled {
				print("Facebook login is cancelled")
			} else if let token = result.token {
				self.logIn(token.tokenString)
			}
		}
	}

	func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
		print("Logged out of facebook")
	}

	func loginButtonWillLogin(loginButton: FBSDKLoginButton!) -> Bool {
		return true
	}
}

