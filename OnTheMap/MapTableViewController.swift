//
//  MapTableViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit

class MapTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {

	var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet weak var tableView: UITableView!
	let searchController = UISearchController(searchResultsController: nil)
	var filteredStudents: [StudentLocation] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.searchController.searchResultsUpdater = self
		self.searchController.dimsBackgroundDuringPresentation = true
		self.searchController.definesPresentationContext = true
		self.tableView.tableHeaderView = self.searchController.searchBar
	}

	@IBAction func logOutPressed(sender: UIBarButtonItem) {
		self.appDelegate.sessionId = nil
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	@IBAction func reloadPressed(sender: UIBarButtonItem) {
		self.tableView.reloadData()
	}

	// MARK: TableViewDelegate
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if self.searchController.active && self.searchController.searchBar.text != "" {
			return self.filteredStudents.count
		}
		return self.appDelegate.students.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentTableViewCell
		var student: StudentLocation
		if self.searchController.active && self.searchController.searchBar.text != "" {
			student = self.filteredStudents[indexPath.row]
		} else {
			student = self.appDelegate.students[indexPath.row]
		}
		cell.label.text = student.firstName + " " + student.lastName
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let student = self.appDelegate.students[indexPath.row]
		if let url = NSURL(string: student.mediaUrl) {
			UIApplication.sharedApplication().openURL(url)
		}
	}

	// MARK: Search
	func filterStudents(searchText: String, scope: String = "All") {
		self.filteredStudents = self.appDelegate.students.filter { student in
			return student.firstName.lowercaseString.containsString(searchText.lowercaseString) || student.lastName.lowercaseString.containsString(searchText.lowercaseString)
		}
		self.tableView.reloadData()
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		self.filterStudents(self.searchController.searchBar.text!)
	}

}