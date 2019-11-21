//
//  Extensions.swift
//  GitGrass
//
//  Created by Takuto Nakamura on 2019/11/21.
//  Copyright © 2019 Takuto Nakamura. All rights reserved.
//

import UIKit

extension UIColor {
    static func fillColor(_ level: Int, _ isEX: Bool) -> UIColor {
        switch level {
        case 1:  return UIColor(named: isEX ? "exGrass25" : "grass25")!
        case 2:  return UIColor(named: isEX ? "exGrass50" : "grass50")!
        case 3:  return UIColor(named: isEX ? "exGrass75" : "grass75")!
        case 4:  return UIColor(named: isEX ? "exGrass100" : "grass100")!
        default: return UIColor(named: isEX ? "exGrass0" : "grass0")!
        }
    }
}

extension String {
    func trim(_ before: String, _ after: String) -> String {
        let new = self.replacingOccurrences(of: before, with: "")
        return new.replacingOccurrences(of: after, with: "")
    }
}
