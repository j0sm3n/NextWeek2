//
//  URL+Extension.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import Foundation

extension URL: @retroactive Identifiable {
    public var id: URL { return self }
}
