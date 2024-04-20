//
//  URLManager.swift
//  Integradora_5A
//
//  Created by imac on 19/04/24.
//

import UIKit

class URLManager: NSObject {
    static let sharedInstance = URLManager()
       private let baseURL = URL(string: "http://34.227.197.144:8000")!
       
    private override init() {}
       
       func getURL(path: String) -> URL? {
           return URL(string: path, relativeTo: baseURL)
       }
}
