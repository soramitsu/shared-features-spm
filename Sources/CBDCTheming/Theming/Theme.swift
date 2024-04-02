//
//  Theming.swift
//  cbdc
//
//  Created by Nikolai Zhukov on 3/29/24.
//  Copyright © 2024 Soramitsu. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
struct Spacing {
    let _2XS: CGFloat
    let _XS: CGFloat
    let _S: CGFloat
    let _SM: CGFloat
    let _M: CGFloat
    let _L: CGFloat
    let _XL: CGFloat
    let _2XL: CGFloat
    let _3XL: CGFloat
    let _4XL: CGFloat
    let _5XL: CGFloat

    let inset: UIEdgeInsets
}

struct BorderRadius {
    let _XS: CGFloat
    let _S: CGFloat
    let _M: CGFloat
    let _ML: CGFloat
    let _L: CGFloat
}
// swiftlint:enable identifier_name

struct Colors {
    struct Accent {
        let primary: UIColor
        let primaryContainer: UIColor
        let secondary: UIColor
        let secondaryContainer: UIColor
        let teritary: UIColor
        let teritaryContainer: UIColor
    }

    struct Background {
        let page: UIColor
        let surface: UIColor
        let surfaceVariant: UIColor
        let surfaceInverted: UIColor
    }

    struct Foreground {
        let primary: UIColor
        let secondary: UIColor
        let inverted: UIColor
        let outline: UIColor
    }

    struct State {
        let pressedDefault: UIColor
        let pressedAccentPrimary: UIColor
        let pressedAccentSecondary: UIColor
        let pressedAccentTeritary: UIColor
        let pressedAccentInverted: UIColor

        let disabledBG: UIColor
        let disabledFG: UIColor
    }

    struct Status {
        let success: UIColor
        let successContainer: UIColor
        let warning: UIColor
        let warningContainer: UIColor
        let error: UIColor
        let errorContainer: UIColor
        let info: UIColor
        let infoContainer: UIColor
    }

    struct Constant {
        let white: UIColor
        let black: UIColor
    }

    let accent: Colors.Accent
    let background: Colors.Background
    let foreground: Colors.Foreground
    let state: Colors.State
    let aliasSurfaceElevated: UIColor
    let iOSDefaultSearchField: UIColor
    let iOSMaterialsChrome: UIColor
}

protocol Theme {
    var spacing: Spacing { get }
    var borderRadius: BorderRadius { get }
    var colors: Colors { get }
}

public enum ThemeManager {
    static var theme = BlankTheme()
}

extension UIColor {
    static var theme: Theme { ThemeManager.theme }
}
