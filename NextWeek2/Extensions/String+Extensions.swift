//
//  String+Extensions.swift
//  XLSXParser
//
//  Created by Jose Antonio Mendoza on 20/1/23.
//

import Foundation

extension String {
    var isNumeric: Bool {
        Double(self) != nil
    }
}
