//
//  StringExtensions.swift
//  HopeFM
//
//  Created by Sergey Sadovoi on 15.12.15.
//  Copyright © 2016 Hope Media Group Ukraine. All rights reserved.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: NSBundle.mainBundle(), value: "", comment: "")
    }
}
