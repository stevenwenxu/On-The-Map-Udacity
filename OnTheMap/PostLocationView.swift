//
//  PostLocationView.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit
import MapKit

class PostLocationView: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var whereLabel: UILabel!
	@IBOutlet var whereLabelHeight: NSLayoutConstraint!
	@IBOutlet weak var locationView: UIView!
	@IBOutlet var locationViewHeight: NSLayoutConstraint!
	@IBOutlet weak var locationMapView: MKMapView!
	@IBOutlet var locationMapViewHeight: NSLayoutConstraint!
	@IBOutlet weak var button: UIButton!
	@IBOutlet weak var textLabel: UILabel!
	@IBOutlet weak var textField: UITextField!
	@IBOutlet var textFieldHeight: NSLayoutConstraint!

	let submitURL = "https://api.parse.com/1/classes/StudentLocation"

	var screenSize = UIScreen.mainScreen().bounds
	var step = 0
	var mapString: String?
	var mediaURL: String?

	var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	override func viewDidLayoutSubviews() {
		// text field
		self.textField.borderStyle = .None
		let bottomLine = CALayer()
		bottomLine.frame = CGRectMake(0.0, self.textFieldHeight.constant - 1, self.textField.frame.width, 1.0)
		bottomLine.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.7).CGColor
		self.textField.layer.addSublayer(bottomLine)

		// button
		self.button.layer.cornerRadius = 5
		self.button.clipsToBounds = true
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		let tapGesture = UITapGestureRecognizer(target: self, action: "viewDidTap")
		self.view.addGestureRecognizer(tapGesture)
		self.textField.delegate = self
		self.setupFirstScreen()
	}

	func viewDidTap() {
		self.view.endEditing(true)
	}

	@IBAction func cancelDidPressed(sender: UIBarButtonItem) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func setupFirstScreen() {
		self.locationMapViewHeight.constant = 0
		self.textLabel.text = "Enter Your Location Here"
		self.button.setTitle("Find on the Map", forState: .Normal)
	}

	func setupSecondScreen() {
		self.view.layoutIfNeeded()
		UIView.animateWithDuration(0.5) {
			self.whereLabelHeight.constant = 0
			self.locationViewHeight.priority = 999
			self.locationMapViewHeight.constant = self.screenSize.height - self.locationViewHeight.constant

			self.textLabel.text = "Enter a Link to Share Here"
			self.button.setTitle("Submit", forState: .Normal)
			self.textField.text = ""
			self.view.layoutIfNeeded()
		}
	}

	@IBAction func buttonTapped() {
		if self.step == 1 {
			self.mediaURL = self.textField.text
			self.submitLocation()
		} else if self.step == 0 {
			let geocoder = CLGeocoder()
			self.mapString = self.textField.text
			geocoder.geocodeAddressString(self.mapString!) { placemarks, error in
				if let error = error {
					print(error.localizedDescription)
				}
				if let placemark = placemarks?.first {
					self.appDelegate.latitude = placemark.location?.coordinate.latitude
					self.appDelegate.longitude = placemark.location?.coordinate.longitude
					self.setupSecondScreen()
					self.locationMapView.showAnnotations([MKPlacemark(placemark: placemark)], animated: true)
					self.step = 1
				}
			}
		}
	}

	func submitLocation() {
		self.appDelegate.mediaUrl = self.mediaURL
		self.appDelegate.mapString = self.mapString

		let request = NSMutableURLRequest(URL: NSURL(string: APIConstants.apiURL)!)
		request.HTTPMethod = "POST"
		request.addValue(APIConstants.appID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(APIConstants.APIKEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")

		request.HTTPBody = "{\"uniqueKey\": \"\(self.appDelegate.uniqueKey!)\", \"firstName\": \"\(self.appDelegate.firstName!)\", \"lastName\": \"\(self.appDelegate.lastName!)\",\"mapString\": \"\(self.appDelegate.mapString!)\", \"mediaURL\": \"\(self.appDelegate.mediaUrl!)\",\"latitude\": \(self.appDelegate.latitude!), \"longitude\": \(self.appDelegate.longitude!)}".dataUsingEncoding(NSUTF8StringEncoding)
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
				self.appDelegate.objectId = objectId
			}

			dispatch_async(dispatch_get_main_queue()) {
				let alert = UIAlertController(title: "Success", message: "You've posted your location", preferredStyle: .Alert)
				let action = UIAlertAction(title: "Okay", style: .Default) { action in
					self.dismissViewControllerAnimated(true, completion: nil)
				}
				alert.addAction(action)
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
		task.resume()
	}

	// MARK: - UITextFieldDelegate
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}
}
