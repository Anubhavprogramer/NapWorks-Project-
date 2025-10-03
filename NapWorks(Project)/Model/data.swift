//
//  data.swift
//  NapWorks(Project)
//
//  Created by Anubhav Dubey on 03/10/25.
//

import Foundation
import UIKit

struct UploadedImage: Identifiable {
    let id: String
    let name: String
    let url: String
    let storagePath: String
}

struct IdentifiableImage: Identifiable {
    let id = UUID()
    let image: UIImage
}
