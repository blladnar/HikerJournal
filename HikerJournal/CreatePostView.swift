//
//  ContentView.swift
//  HikerJournal
//
//  Created by Randall Brown on 4/20/22.
//

import SwiftUI
import CoreLocation
import PhotosUI

struct CreatePostView: View {
    @StateObject var post = Post()

    var body: some View {
        VStack {
            header
            TextField("Title", text: $post.title)
                .textFieldStyle(.roundedBorder)
            TextField("Subtitle", text: $post.subtitle)
                .textFieldStyle(.roundedBorder)
            TextField("Author", text: $post.author)
                .textFieldStyle(.roundedBorder)
            TextField("Mile", text: $post.mile)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.decimalPad)
            photoRow
                .padding()
            tagSelector
            if let location = post.location {
                locationView(with: location)
            }
            Spacer()
        }
        .padding()
        .alert(post.error?.localizedDescription ?? "Error", isPresented: $post.showError) {
            Button("Okay") {
                post.showError = false
            }
        }
        .fullScreenCover(isPresented: $post.showHeaderPicker) {
            let configuration = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
            PhotoPicker(configuration: configuration,
                        isPresented: $post.showHeaderPicker,
                        results: $post.headerImageResults)
        }
        .fullScreenCover(isPresented: $post.showPhotosPicker) {
            let configuration = { () -> PHPickerConfiguration in
                var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                config.selectionLimit = 0
                return config
            }()
            PhotoPicker(configuration: configuration,
                        isPresented: $post.showPhotosPicker,
                        results: $post.photosResults)
        }
        .fullScreenCover(item: $post.finishedPost) { finishedPost in
            FinishedPostView(post: finishedPost, presenter: post)
        }
    }

    private var photoRow: some View {
        HStack {
            Button("Header Image") {
                post.showHeaderPicker = true
            }
            if !post.headerImageResults.isEmpty {
                Image(systemName: "checkmark.circle")
                    .foregroundColor(.green)
            }

            Spacer()
            Button("Photos") {
                post.showPhotosPicker = true
            }
            if !post.photosResults.isEmpty {
                Text("\(post.photosResults.count)")
            }
        }
    }

    private var header: some View {
        HStack {
            Button("New") {
                post.reset()
            }
            Spacer()
            Button("Done") {
                post.done()
            }
            .padding(.bottom)
        }
    }

    private var tagSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Tag.allCases, id: \.self) { tag in
                    Button(tag.rawValue) {
                        post.tag = tag
                    }
                    .padding()
                    .background(post.tag == tag ? Color.green : Color.gray)
                    .foregroundColor(.white)
                }
            }
        }
    }

    private func locationView(with location: CLLocation) -> some View {
        Text("\(location.coordinate.latitude), \(location.coordinate.longitude)")
    }
}
