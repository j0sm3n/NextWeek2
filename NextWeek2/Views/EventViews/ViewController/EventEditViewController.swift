//
//  EventEditViewController.swift
//  NextWeek2
//
//  Created by Jose Antonio Mendoza on 4/5/25.
//

import EventKit
import EventKitUI
import SwiftUI

struct EventEditViewController: UIViewControllerRepresentable {
    @Environment(\.dismiss) var dismiss
    typealias UIViewControllerType = EKEventEditViewController
    
    @Binding var event: EKEvent?
    let eventStore: EKEventStore
    
    /// Create an event edit view controller, then configure it with the specified event and event store.
    func makeUIViewController(context: UIViewControllerRepresentableContext<EventEditViewController>) -> EKEventEditViewController {
        let controller = EKEventEditViewController()
        controller.eventStore = eventStore
        if let event {
            controller.event = event
        }
        controller.editViewDelegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: EKEventEditViewController, context: UIViewControllerRepresentableContext<EventEditViewController>) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, EKEventEditViewDelegate {
        var parent: EventEditViewController
        
        init(_ controller: EventEditViewController) {
            self.parent = controller
        }
        
        func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
            parent.dismiss()
        }
    }
}
