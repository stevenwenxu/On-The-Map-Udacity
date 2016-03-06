//
//  MapTableViewController.swift
//  OnTheMap
//
//  Created by Steven Xu on 2016-03-06.
//  Copyright © 2016 Steven Xu. All rights reserved.
//

import UIKit

class MapTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

	var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		tableView.rowHeight = UITableViewAutomaticDimension
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
		return self.appDelegate.students.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentTableViewCell
		let student = self.appDelegate.students[indexPath.row]
		cell.label.text = student.firstName + " " + student.lastName
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		let student = self.appDelegate.students[indexPath.row]
		if let url = NSURL(string: student.mediaUrl) {
			UIApplication.sharedApplication().openURL(url)
		}

	}
}