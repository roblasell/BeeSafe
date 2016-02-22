//
//  HomeAddressViewController.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/17/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import UIKit

class HomeAddressViewController: UIViewController, UITextFieldDelegate {
    let defaults = NSUserDefaults.standardUserDefaults()

    @IBOutlet weak var zipTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var streetAddressTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        streetAddressTextField.delegate = self
        cityTextField.delegate = self
        stateTextField.delegate = self
        zipTextField.delegate = self
        
        let address = defaults.stringForKey(addressKey)
        let city = defaults.stringForKey(cityKey)
        let state = defaults.stringForKey(stateKey)
        let zip = defaults.stringForKey(zipKey)
        
        streetAddressTextField.text = address
        cityTextField.text = city
        stateTextField.text = state
        zipTextField.text = zip
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        let address = streetAddressTextField.text
        let city = cityTextField.text
        let state = stateTextField.text
        let zip = zipTextField.text
        
        defaults.setObject(address, forKey: addressKey)
        defaults.setObject(city, forKey: cityKey)
        defaults.setObject(state, forKey: stateKey)
        defaults.setObject(zip, forKey: zipKey)
        
        let fullAddress = address! + ", " + city! + ", " + state! + ", " + zip!
        //print(fullAddress)
        defaults.setObject(fullAddress, forKey: fullAddressKey)
        //print(defaults.objectForKey(fullAddressKey))
    }
}
