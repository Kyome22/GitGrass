//
//  GitAccess.swift
//  GitGrass-iOS
//
//  Created by Takuto Nakamura on 2020/03/22.
//  Copyright 2020 Takuto Nakamura
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation

class GitAccess {
    
    static func getGrass(username: String, callback: @escaping (_ username: String, _ response: String?) -> ()) {
        guard let url = URL(string: "https://github.com/users/\(username)/contributions") else {
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        let task = session.dataTask(with: url) { (data, response, error) in
            switch (data, response, error) {
            case (_, _, .some):
                callback(username, nil)
            case (.some, .some, _):
                let httpResponse = response as! HTTPURLResponse
                let statusCode = httpResponse.statusCode
                if statusCode == 200 {
                    let text = String(data: data!, encoding: String.Encoding.utf8)!
                    callback(username, text)
                } else {
                    callback(username, nil)
                }
            default: break
            }
        }
        task.resume()
    }
    
}
