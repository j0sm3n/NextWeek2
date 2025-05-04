//
//  ScheduleView.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 3/5/25.
//

import SwiftUI

struct ScheduleView: View {
    let agent: Agent
    let filename: URL

    var body: some View {
        Text(agent.cf, format: .number)
        Text(filename.lastPathComponent)
    }
}
