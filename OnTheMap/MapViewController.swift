//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

	var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
	let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	let APIKEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

	let locationURL = NSURL(string: "https://api.parse.com/1/classes/StudentLocation?limit=100")!

	@IBOutlet weak var mapView: MKMapView!
	var annotations: [MKPointAnnotation] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		self.getStudents()
		self.mapView.delegate = self
	}

	// MARK: - events

	@IBAction func logOutPressed(sender: UIBarButtonItem) {
		self.appDelegate.sessionId = nil
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func reloadPressed(sender: UIBarButtonItem) {
		self.mapView.removeAnnotations(self.annotations)
		self.annotations = []
		self.getStudents()
	}

	// MARK: - 
	func getStudents() {
		let request = NSMutableURLRequest(URL: self.locationURL)
		request.addValue(self.appID, forHTTPHeaderField: "X-Parse-Application-Id")
		request.addValue(self.APIKEY, forHTTPHeaderField: "X-Parse-REST-API-Key")
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
						objectId: result["objectId"] as! String,
						uniqueKey: result["uniqueKey"] as! String,
						firstName: result["firstName"] as! String,
						lastName: result["lastName"] as! String,
						mapString: result["mapString"] as! String,
						mediaUrl: result["mediaURL"] as! String,
						latitude: result["latitude"] as! Double,
						longitude: result["longitude"] as! Double))
				}
			}
			dispatch_async(dispatch_get_main_queue()) {
				self.drawAnnotations()
			}

		}
		task.resume()
	}

	func drawAnnotations() {
		for student in self.appDelegate.students {
			let annotation = MKPointAnnotation()
			annotation.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
			annotation.title = "\(student.firstName) \(student.lastName)"
			annotation.subtitle = student.mediaUrl
			self.annotations.append(annotation)
		}
		self.mapView.addAnnotations(self.annotations)
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