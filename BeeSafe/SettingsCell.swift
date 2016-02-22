//
//  SettingsCell.swift
//  BeeSafe
//
//  Created by Robert Lasell on 2/16/16.
//  Copyright © 2016 Tufts. All rights reserved.
//

import Foundation
import UIKit

struct SettingsCell {
    var title: String?
    var value: String?
    
    init(title: String?, value: String?) {
        self.title = title
        self.value = value
    }
}
