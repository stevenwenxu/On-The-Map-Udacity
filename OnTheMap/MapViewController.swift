//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {

	let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet weak var mapView: MKMapView!
	var annotations: [MKPointAnnotation] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		self.getStudentInfo()
		self.mapView.delegate = self
	}

	// MARK: - events

	@IBAction func logOutPressed(sender: UIBarButtonItem) {
		self.appDelegate.sessionId = nil
		self.appDelegate.fbLoginManager.logOut()
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	@IBAction func reloadPressed(sender: UIBarButtonItem) {
		self.mapView.removeAnnotations(self.annotations)
		self.annotations = []
		self.getStudentInfo()
	}

	@IBAction func uploadPressed(sender: UIBarButtonItem) {

		if let objectId = self.appDelegate.objectId where objectId != "" {
			let alert = UIAlertController(title: nil, message: "You have already posted a location. Would you like to overwrite your current location?", preferredStyle: .Alert)
			let yesAction = UIAlertAction(title: "Overwrite", style: .Default) { _ in
				self.performSegueWithIdentifier("postLocation", sender: nil)
			}
			let noAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: { _ in return })
			alert.addAction(yesAction)
			alert.addAction(noAction)
			self.presentViewController(alert, animated: true, completion: nil)
		} else {
			self.performSegueWithIdentifier("postLocation", sender: nil)
		}
	}

	// MARK: -
	func getStudentInfo() {
		APIStuff.getStudents {
			dispatch_async(dispatch_get_main_queue()) {
				for student in self.appDelegate.students {
					let annotation = MKPointAnnotation()
					annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
					annotation.title = "\(student.firstName) \(student.lastName)"
					annotation.subtitle = student.mediaUrl
					self.annotations.append(annotation)
				}
				self.mapView.addAnnotations(self.annotations)
			}
		}
	}

	// MARK: - MKMapViewDelegate

	func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
		let reuseId = "pin"
		var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
		}
		pinView!.annotation = annotation
		pinView!.canShowCallout = true
		pinView!.pinColor = .Red
		pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
		return pinView
	}

	func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			if let url = view.annotation?.subtitle! {
				UIApplication.sharedApplication().openURL(NSURL(string: url)!)
			}
		}
	}
}