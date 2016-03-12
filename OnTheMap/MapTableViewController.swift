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
	var refreshControl = UIRefreshControl()
	var searchController: UISearchController?
	var filteredStudents: [StudentLocation] = []

	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.delegate = self
		self.tableView.dataSource = self
		self.tableView.estimatedRowHeight = self.tableView.rowHeight
		self.tableView.rowHeight = UITableViewAutomaticDimension
		self.refreshControl.addTarget(self, action: "tableViewRefreshed:", forControlEvents: .ValueChanged)
		self.tableView.addSubview(self.refreshControl)

		self.searchController = UISearchController(searchResultsController: nil)
		self.searchController!.searchResultsUpdater = self
		if #available(iOS 9.1, *) {
		    self.searchController!.obscuresBackgroundDuringPresentation = false
		} else {
			self.searchController!.dimsBackgroundDuringPresentation = false
		}
		self.searchController!.definesPresentationContext = true
		self.tableView.tableHeaderView = self.searchController!.searchBar
	}

	@IBAction func logOutPressed(sender: UIBarButtonItem) {
		self.appDelegate.sessionId = nil
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func tableViewRefreshed(refreshControl: UIRefreshControl) {
		self.appDelegate.students.removeAll()
		self.tableView.reloadData()
		APIStuff.getStudents {
			dispatch_async(dispatch_get_main_queue()) {
				self.tableView.reloadData()
				refreshControl.endRefreshing()
			}
		}
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

	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if let destVC = segue.destinationViewController as? SingleStudentMapViewController {
			if let index = sender as? NSIndexPath {
				destVC.student = self.appDelegate.students[index.row]
			}
		}
	}

	// MARK: TableViewDelegate
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let controller = self.searchController where controller.active && controller.searchBar.text != "" {
			return self.filteredStudents.count
		}
		return self.appDelegate.students.count
	}

	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("studentCell") as! StudentTableViewCell
		var student: StudentLocation
		if let controller = self.searchController where controller.active && controller.searchBar.text != "" {
			student = self.filteredStudents[indexPath.row]
		} else {
			student = self.appDelegate.students[indexPath.row]
		}
		cell.label.text = student.firstName + " " + student.lastName
		cell.urlLabel.text = student.mediaUrl
		return cell
	}

	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		var student: StudentLocation
		if let controller = self.searchController where controller.active && controller.searchBar.text != "" {
			student = self.filteredStudents[indexPath.row]
		} else {
			student = self.appDelegate.students[indexPath.row]
		}
		if let url = NSURL(string: student.mediaUrl) {
			UIApplication.sharedApplication().openURL(url)
		}
	}

	func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
		if editingStyle == .Delete {
			if let objectId = self.appDelegate.students[indexPath.row].objectId {
				if objectId == self.appDelegate.objectId {
					self.appDelegate.objectId = nil
				}
				self.appDelegate.students.removeAtIndex(indexPath.row)
				APIStuff.deleteEntry(objectId) {
					dispatch_async(dispatch_get_main_queue()) {
						tableView.reloadData()
					}
				}
			}
		}
	}

	func tableView(tableView: UITableView, accessoryButtonTappedForRowWithIndexPath indexPath: NSIndexPath) {
		self.performSegueWithIdentifier("viewStudentOnMap", sender: indexPath)
	}

	func scrollViewDidScroll(scrollView: UIScrollView) {
		self.searchController?.searchBar.resignFirstResponder()
	}

	// MARK: Search
	func filterStudents(searchText: String, scope: String = "All") {
		self.filteredStudents = self.appDelegate.students.filter { student in
			return student.firstName.lowercaseString.containsString(searchText.lowercaseString) || student.lastName.lowercaseString.containsString(searchText.lowercaseString)
		}
		self.tableView.reloadData()
	}

	func updateSearchResultsForSearchController(searchController: UISearchController) {
		self.filterStudents(self.searchController!.searchBar.text!)
	}

}