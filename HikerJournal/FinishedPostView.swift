//
//  FinishedPostView.swift
//  HikerJournal
//
//  Created by Randall Brown on 4/20/22.
//

import SwiftUI

protocol FinishedPostPresenter {
    func donePosting()
}

struct FinishedPostView: View {
    let post: FinishedPost
    let presenter: FinishedPostPresenter

    @State private var showShareBody = false
    @State private var showSharePhotos = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Done") {
                    presenter.donePosting()
                }
            }
            Spacer()
            Text(post.bodyText)
            Spacer()
            Button("Save Body") {
                showShareBody = true
            }
            .padding()
            .frame(width: 200)
            .background(Color.green)
            .foregroundColor(.white)

            Button("Save Photos") {
                showSharePhotos = true
            }
            .padding()
            .frame(width: 200)
            .background(Color.green)
            .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showShareBody) {
            ShareSheet(activityItems: [post.postURL], activities: [], isShowing: $showShareBody)
        }
        .fullScreenCover(isPresented: $showSharePhotos) {
            ShareSheet(activityItems: [post.headerURL] + post.photosURLs, activities: [], isShowing: $showShareBody)
        }
    }
}
