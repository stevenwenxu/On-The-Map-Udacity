//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {
	@IBOutlet weak var emailTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!

	var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	// - MARK: View Controller Life Cycle
	override func viewDidLoad() {
		super.viewDidLoad()
		let tapGesture = UITapGestureRecognizer(target: self, action: "viewDidTap")
		self.emailTextField.delegate = self
		self.passwordTextField.delegate = self
		self.view.addGestureRecognizer(tapGesture)
	}

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if let id = NSUserDefaults.standardUserDefaults().valueForKey("udacitySessionId") as? String {
			self.appDelegate.sessionId = id
			self.performSegueWithIdentifier("loggedIn", sender: nil)
		}
	}

	// - MARK: Events

	@IBAction func signUpDidPress() {
		UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
	}


	func viewDidTap() {
		self.view.endEditing(true)
	}
	
	@IBAction func loginDidTap() {
		self.logIn()
		self.view.endEditing(true)
	}

	func logIn() {
		let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = "{\"udacity\": {\"username\": \"\(self.emailTextField.text!)\", \"password\": \"\(self.passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)

		let task = NSURLSession.sharedSession().dataTaskWithRequest(request) { data, response, error in
			if let error = error {
				dispatch_async(dispatch_get_main_queue()) {
					let alert = UIAlertView(title: "Error", message: "Log in failed\n\(error.localizedDescription)", delegate: nil, cancelButtonTitle: "OK")
					alert.show()
				}
				return
			}
			let data = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
			var json: AnyObject
			do {
				json = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
			} catch {
				dispatch_async(dispatch_get_main_queue()) {
					let alert = UIAlertView(title: "Error", message: "Something happened", delegate: nil, cancelButtonTitle: "OK")
					alert.show()
				}
				return
			}
			if let statusCode = json["status"] as? Int {
				if statusCode != 200 {
					dispatch_async(dispatch_get_main_queue()) {
						let alert = UIAlertView(title: "Error", message: "Login Failed", delegate: nil, cancelButtonTitle: "OK")
						alert.show()
					}
				}
			}
			if let session = json["session"] as? NSDictionary {
				if let id = session["id"] as? String {
					self.appDelegate.sessionId = id
					dispatch_async(dispatch_get_main_queue()) {
						self.performSegueWithIdentifier("loggedIn", sender: nil)
					}
				}
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
			self.logIn()
		}
		return false
	}
}

