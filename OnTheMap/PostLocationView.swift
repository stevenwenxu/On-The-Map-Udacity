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
	@IBOutlet weak var navBar: UINavigationBar!
	@IBOutlet weak var navBarHeight: NSLayoutConstraint!

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
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
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
		self.step = 1
		self.view.layoutIfNeeded()
		UIView.animateWithDuration(0.5) {
			self.whereLabelHeight.constant = 0
			self.locationViewHeight.priority = 999
			self.locationMapViewHeight.constant = self.screenSize.height - self.locationViewHeight.constant - self.navBarHeight.constant

			self.navBar.barTintColor = self.locationView.backgroundColor
			self.navBar.topItem?.rightBarButtonItems?.forEach { $0.tintColor = UIColor.whiteColor() }

			self.textLabel.text = "Enter a Link to Share Here"
			self.textField.autocorrectionType = .No
			self.button.setTitle("Submit", forState: .Normal)
			self.textField.text = ""
			self.view.layoutIfNeeded()
		}
	}

	@IBAction func buttonTapped() {
		if self.step == 0 {
			let geocoder = CLGeocoder()
			self.mapString = self.textField.text
			geocoder.geocodeAddressString(self.mapString!) { placemarks, error in
				if let error = error {
					print(error.localizedDescription)
				}
				if let placemark = placemarks?.first {
					self.appDelegate.thisStudent.latitude = placemark.location!.coordinate.latitude
					self.appDelegate.thisStudent.longitude = placemark.location!.coordinate.longitude
					self.setupSecondScreen()
					self.locationMapView.showAnnotations([MKPlacemark(placemark: placemark)], animated: true)
				}
			}
		} else if self.step == 1 {
			self.mediaURL = self.textField.text
			self.submitLocation()
		}
	}

	func submitLocation() {
		self.appDelegate.thisStudent.mediaUrl = self.mediaURL!
		self.appDelegate.thisStudent.mapString = self.mapString!
		APIStuff.postLocation { success, message in
			let title = success ? "Success" : "Error"
			let msg = message ?? "You've posted your location"
			let alert = UIAlertController(title: title, message: msg, preferredStyle: .Alert)
			let action = UIAlertAction(title: "Okay", style: .Default) { action in
				if success {
					dispatch_async(dispatch_get_main_queue()) {
						self.appDelegate.uniqueKeyThatPostedLocation = self.appDelegate.thisStudent.uniqueKey
						self.dismissViewControllerAnimated(true, completion: nil)
					}
				}
			}
			alert.addAction(action)
			dispatch_async(dispatch_get_main_queue()) {
				self.presentViewController(alert, animated: true, completion: nil)
			}
		}
	}

	// MARK: - UITextFieldDelegate
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return false
	}
}
