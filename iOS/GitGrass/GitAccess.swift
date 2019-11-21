//
//  GitAccess.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import Foundation

class GitAccess {
    
    static func getGrass(username: String, callback: @escaping (_ response: String?) -> Void) {
        guard let url = URL(string: "https://github.com/users/\(username)/contributions") else {
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url) { (data, response, error) in
            switch (data, response, error) {
            case (_, _, .some):
                Swift.print(error!.localizedDescription)
            case (.some, .some, _):
                let status = (response as! HTTPURLResponse).statusCode
                if status == 200 {
                    let text = String(data: data!, encoding: String.Encoding.utf8)!
                    callback(text)
                } else {
                    Swift.print("status code: \(status)")
                    callback(nil)
                }
            default: break
            }
        }
        task.resume()
    }
    
}
