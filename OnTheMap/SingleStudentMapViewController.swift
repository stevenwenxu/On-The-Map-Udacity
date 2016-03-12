//
//  SingleStudentMapViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-12.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit
import MapKit

class SingleStudentMapViewController: UIViewController {
	@IBOutlet weak var mapView: MKMapView!

	var student: StudentLocation!
	var geocoder = CLGeocoder()

	override func viewDidLoad() {
		super.viewDidLoad()
		let annotation = MKPointAnnotation()
		let coord = CLLocationCoordinate2D(latitude: self.student.latitude, longitude: self.student.longitude)
		annotation.coordinate = coord

		let location = CLLocation(latitude: self.student.latitude, longitude: self.student.longitude)
		self.geocoder.reverseGeocodeLocation(location) { placemarks, error in
			if let error = error {
				print("Cannot reverse geocode location\n\(error.localizedDescription)")
			}
			if placemarks?.count > 0 {
				if let place = placemarks?[0] {
					dispatch_async(dispatch_get_main_queue()) {
						annotation.title = place.name
						self.mapView.showAnnotations([annotation], animated: true)
						self.mapView.selectAnnotation(annotation, animated: true)
					}
				}

			}
		}
	}


}