//
//  ShareSheet.swift
//  HikerJournal
//
//  Created by Randall Brown on 4/20/22.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let activities: [UIActivity]?
    @Binding var isShowing: Bool

    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)

        controller.completionWithItemsHandler = { (activity, completed, _, _) in
            isShowing = false
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {

    }
}
