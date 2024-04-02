//
//  UIEdgeInsets+Extensions.swift
//  cbdc
//
//  Created by Iskander Foatov on 15.09.2020.
//  Copyright © 2020 Soramitsu. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    init(offset: CGFloat) {
        self.init(top: offset, left: offset, bottom: offset, right: offset)
    }

    init(side: CGFloat) {
        self.init(top: 0, left: side, bottom: 0, right: side)
    }
}
