//
//  LogListViewController.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/20/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit

class LogListViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource {
    let defaults = NSUserDefaults.standardUserDefaults()

    var log:[AnyObject] = [AnyObject]()
    var pickerData = [NSDate]()
    var session = [[AnyObject]]()
    var sessionRow = 0
    
    @IBOutlet weak var sessionPicker: UIPickerView!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var logTable: UITableView!
    @IBOutlet weak var mapButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        log = defaults.arrayForKey(logKey)!
        session = log.last as! [[AnyObject]]

        sessionPicker.delegate = self
        sessionPicker.dataSource = self
        
        for session in log {
            let date = session[Session.Route.rawValue][1][Route.Date.rawValue] as! NSDate
            pickerData.append(date)
        }
        
        logTable.delegate = self
        logTable.dataSource = self
    }
    
    override func viewDidAppear(animated: Bool) {
        sessionPicker.selectRow(log.count - 1, inComponent: 0, animated: true)
        sessionRow = log.count - 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "logToMapSegue") {
            let vc = segue.destinationViewController as! LogMapViewController;
            vc.row = sessionRow
        }
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let date = pickerData[row]
        
        let dayTimePeriodFormatter = NSDateFormatter()
        dayTimePeriodFormatter.dateFormat = "MMMM d, yyyy h:mm a"
        let dateString = dayTimePeriodFormatter.stringFromDate(date)
        
        return dateString
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        session = log[row] as! [[AnyObject]]
        sessionRow = row
        //print(session)
        logTable.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 4
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        if (indexPath.row == 0) { // checkpoints hit
            var pointsHit = 0
            for event in session[Session.Events.rawValue] {
                if event[Events.EventType.rawValue] as! Int == EventType.OnRoute.rawValue {
                    pointsHit++
                }
            }
            
            cell = tableView.dequeueReusableCellWithIdentifier("goodEvent")!
            cell.textLabel?.text = "+" + String(pointsHit)
            cell.detailTextLabel?.text = "Checkpoints Hit"
        } else if (indexPath.row == 1) { // checkpoints missed
            var pointsMissed = 0
            for event in session[Session.Events.rawValue] {
                if event[Events.EventType.rawValue] as! Int == EventType.OffRoute.rawValue {
                    pointsMissed++
                }
            }
            
            cell = tableView.dequeueReusableCellWithIdentifier("badEvent")!
            cell.textLabel?.text = "-" + String(pointsMissed)
            cell.detailTextLabel?.text = "Checkpoints Missed"
        } else if (indexPath.row == 2) { // background events
            var backgroundEvents = 0
            for event in session[Session.Events.rawValue] {
                if event[Events.EventType.rawValue] as! Int == EventType.InBackground.rawValue {
                    backgroundEvents++
                }
            }
            
            cell = tableView.dequeueReusableCellWithIdentifier("badEvent")!
            cell.textLabel?.text = "-" + String(backgroundEvents)
            cell.detailTextLabel?.text = "Other Apps Opened"
        } else { // returned home
            cell = tableView.dequeueReusableCellWithIdentifier("goodEvent")!
            var reachedHome = false
            var homeDate = NSDate()
            
            for event in session[Session.Events.rawValue] {
                if event[Events.EventType.rawValue] as! Int == EventType.Home.rawValue {
                    reachedHome = true
                    homeDate = event[Events.Time.rawValue] as! NSDate
                }
            }
            
            if (reachedHome) {
                let dayTimePeriodFormatter = NSDateFormatter()
                dayTimePeriodFormatter.dateFormat = "h:mm a"
                let dateString = dayTimePeriodFormatter.stringFromDate(homeDate)
                
                cell.textLabel?.text = "+1"
                cell.detailTextLabel?.text = "Got home at " + String(dateString)
            } else {
                cell.textLabel?.text = "+0"
                cell.detailTextLabel?.text = "Never reached home!"
            }
        }
        
        return cell
    }
}
