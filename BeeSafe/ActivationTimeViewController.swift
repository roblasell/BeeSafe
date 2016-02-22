//
//  ActivationTimeViewController.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/17/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit

class ActivationTimeViewController: UIViewController {
    let defaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var timePicker: UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        timePicker.date = defaults.objectForKey(timeKey) as! NSDate
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(animated: Bool) {
        defaults.setObject(timePicker.date, forKey: timeKey)
        registerLocal()
        scheduleLocal()
    }
    
    func registerLocal() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
    }
    
    func scheduleLocal() {
        let notification = UILocalNotification()

        var date = timePicker.date
        let timeInterval = floor(date.timeIntervalSinceReferenceDate / 60.0) * 60.0
        date = NSDate(timeIntervalSinceReferenceDate:timeInterval)
        notification.fireDate = date
        //print(date)
        
        notification.repeatInterval = .Day
        notification.alertBody = "Don't forget to BeeSafe! " + String(UnicodeScalar(128029)) + String(UnicodeScalar(128029)) + String(UnicodeScalar(128029))
        notification.alertAction = "Ok"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.userInfo = ["CustomField1": "test"]
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
