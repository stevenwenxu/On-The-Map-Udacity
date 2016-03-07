//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import Foundation

struct APIConstants {
	static let apiURL = "https://api.parse.com/1/classes/StudentLocation"
	static let appID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	static let APIKEY = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
}

struct StudentLocation {
	var objectId: String?
	let uniqueKey: String
	let firstName: String
	let lastName: String
	var mapString: String
	var mediaUrl: String
	var latitude: Double
	var longitude: Double
}