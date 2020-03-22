//
//  ShadowIconView.swift
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

import UIKit

class ShadowIconView: UIView {

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = false
        layer.backgroundColor = UIColor.white.cgColor
        layer.cornerRadius = 20.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 3.0
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 20.0).cgPath
    }

}


class ShadowIcon: UIImageView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        clipsToBounds = true
        layer.cornerRadius = 20.0
    }
}
