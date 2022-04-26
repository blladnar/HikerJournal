//
//  Post.swift
//  HikerJournal
//
//  Created by Randall Brown on 4/20/22.
//

import CoreLocation
import SwiftUI
import PhotosUI
import UIKit

enum Tag: String, CaseIterable {
    case newMexico = "New Mexico"
    case colorado = "Colorado"
    case wyoming = "Wyoming"
    case montana = "Montana"
    case other = "Other"
}

struct FinishedPost: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let author: String
    let date = Date()
    let mile: Int?
    let tag: Tag
    let location: CLLocation?
    let headerImage: URL
    let photosURLs: [URL]
    let images: [UIImage]

    var postURL: URL {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        var fileName = dateFormatter.string(from: Date())
        fileName += "-"
        fileName += title.replacingOccurrences(of: " ", with: "-")
        fileName += ".markdown"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try! bodyText.write(to: url, atomically: true, encoding: .utf8)

        return url
    }

    static let metersToFeet = 3.28084

    var bodyText: String {
        var body = "---\n"
        body += "layout: post\n"
        body += "title: \(title)\n"
        if let subtitle = subtitle {
            body += "subtitle: \(subtitle)\n"
        }
        body += "author: \(author)\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        body += "date: \(dateFormatter.string(from: date))\n"
        body += "background: /img/\(Self.headerNameWith(title: title))\n"
        if let mile = mile {
            body += "mile: \(mile)\n"
        }
        body += "tag: \(tag.rawValue)\n"
        if let location = location {
            body += "latitude: \(location.coordinate.latitude)\n"
            body += "longitude: \(location.coordinate.longitude)\n"
            body += "altitude: \(Int(location.altitude * Self.metersToFeet))\n"
        }
        body += "---\n"

        for photoURL in photosURLs {
            body += "<img src=\"/img/\(photoURL.lastPathComponent)\" class=\"img-fluid\">\n"
        }

        return body
    }

    static func headerNameWith(title: String) -> String {
        title.replacingOccurrences(of: " ", with: "-") + "Header.jpg"
    }

    var headerURL: URL {
        headerImage
    }
}

class Post: NSObject, ObservableObject {
    @Published var title: String = ""
    @Published var subtitle: String = ""
    @Published var author: String = "Randall"
    @Published var mile = ""
    @Published var location: CLLocation?
    @Published var tag: Tag?
    @Published var date = Date()
    @Published var headerImage: Image?
    @Published var error: Error?
    @Published var showError = false
    @Published var showHeaderPicker = false
    @Published var headerImageResults: [PHPickerResult] = []
    @Published var showPhotosPicker = false
    @Published var photosResults: [PHPickerResult] = []
    @Published var finishedPost: FinishedPost?

    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        locationManager.requestWhenInUseAuthorization()
    }

    func reset() {
        title = ""
        subtitle = ""
        author = "Randall"
        mile = ""
        location = nil
        tag = nil
        date = Date()
        headerImage = nil
        error = nil
        showError = false
        showHeaderPicker = false
        headerImageResults = []
        showPhotosPicker = false
        photosResults = []
        finishedPost = nil
        locationManager.requestLocation()
    }

    func done() {
        guard !headerImageResults.isEmpty else {
            error = PostError(reason: "No Header Image")
            showError = true
            return
        }

        let itemProviders = headerImageResults.map(\.itemProvider)
        if let provider = itemProviders.first, provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    self.handleHeaderImageLoad(with: image as? UIImage)
                }
            }
        }
    }

    func handleHeaderImageLoad(with header: UIImage?) {
        guard let header = header else {
            error = PostError(reason: "No Header Image")
            return
        }
        guard !title.isEmpty else {
            error = PostError(reason: "No Title")
            showError = true
            return
        }

        guard let tag = self.tag else {
            error = PostError(reason: "No Tag")
            showError = true
            return
        }

        let headerURL = FileManager.default.temporaryDirectory.appendingPathComponent(FinishedPost.headerNameWith(title: title))
        let imageData = header.scaleAndRotateImage(maxSize: header.size.width * 0.5).jpegData(compressionQuality: 0.5)
        
        try! imageData?.write(to: headerURL)


        let itemProviders = photosResults.map(\.itemProvider).enumerated()
        let group = DispatchGroup()
        var photoURLs: [URL] = []
        var images: [UIImage] = [header]

        for (index, provider) in itemProviders {
            if provider.canLoadObject(ofClass: UIImage.self) {
                group.enter()
                provider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        let photoURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(self.title)\(index).jpg")
                        let imageData = image.scaleAndRotateImage(maxSize: image.size.width * 0.5).jpegData(compressionQuality: 0.5)
                        try! imageData?.write(to: photoURL)
                        photoURLs.append(photoURL)
                        images.append(image)
                    }
                    group.leave()
                }
            }
        }

        group.wait()

        finishedPost = FinishedPost(title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                    subtitle: subtitle.trimmingCharacters(in: .whitespacesAndNewlines),
                                    author: author.trimmingCharacters(in: .whitespacesAndNewlines),
                                    mile: Int(mile),
                                    tag: tag,
                                    location: location,
                                    headerImage: headerURL,
                                    photosURLs: photoURLs,
                                    images: images)
        
    }

}



struct PostError: Error, CustomStringConvertible, LocalizedError {
    let reason: String

    var description: String {
        reason
    }

    var errorDescription: String? {
        reason
    }
}

extension Post: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations)
        guard let location = locations.last else {
            return
        }

        self.location = location
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed", error)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        locationManager.requestLocation()
    }
}

extension Post: FinishedPostPresenter {
    func donePosting() {
        self.finishedPost = nil
    }
}
