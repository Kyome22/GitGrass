//
//  GitAccess.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/19.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Foundation

class GitAccess {
    
    static func getGrass(username: String, callback: @escaping (_ response: String?, _ error: Error?) -> ()) {
        guard let url = URL(string: "https://github.com/users/\(username)/contributions") else {
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url) { (data, response, error) in
            switch (data, response, error) {
            case (_, _, .some):
                callback(nil, error)
            case (.some, .some, _):
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if statusCode == 200 {
                    let text = String(data: data!, encoding: String.Encoding.utf8)!
                    callback(text, nil)
                } else {
                    if var status = httpResponse.allHeaderFields["Status"] as? String {
                        if statusCode == 404 {
                            status = "notFound".localized
                        }
                        let info: [String : Any] = [NSLocalizedDescriptionKey : status]
                        let error = NSError(domain: "GitGrass", code: statusCode, userInfo: info)
                        callback(nil, error)
                    } else {
                        callback(nil, nil)
                    }
                }
            default: break
            }
        }
        task.resume()
    }
    
}
