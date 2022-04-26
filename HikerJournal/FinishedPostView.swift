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
            ScrollView {
                HStack {
                    Spacer()
                    Text(post.bodyText)
                    Spacer()
                }
            }
            .background(Color.white)
            .padding()
            Spacer()
            photoCarousel
            Button("Save Body") {
                showShareBody = true
            }
            .padding()
            .frame(width: 200)
            .background(darkGreen)
            .foregroundColor(.white)

            Button("Save Photos") {
                showSharePhotos = true
            }
            .padding()
            .frame(width: 200)
            .background(darkGreen)
            .foregroundColor(.white)
            Spacer()
        }
        .padding()
        .background(Color.gray.opacity(0.5).ignoresSafeArea())
        .fullScreenCover(isPresented: $showShareBody) {
            ShareSheet(activityItems: [post.postURL], activities: [], isShowing: $showShareBody)
        }
        .fullScreenCover(isPresented: $showSharePhotos) {
            ShareSheet(activityItems: [post.headerURL] + post.photosURLs, activities: [], isShowing: $showShareBody)
        }
    }

    private var photoCarousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(post.images.enumerated()), id: \.0) { pair in
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: pair.1)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 150)
                        ZStack {
                            Circle()
                                .foregroundColor(Color.white)
                                .frame(width: 30, height: 30)
                            if pair.0 == 0 {
                                Text("H")
                            }
                            else {
                                Text("\(pair.0 - 1)")
                            }
                        }
                        .padding(5)
                    }
                }
            }
        }
    }
}
