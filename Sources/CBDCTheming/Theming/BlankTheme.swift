//
//  BlankTheme.swift
//  cbdc
//
//  Created by Nikolai Zhukov on 3/29/24.
//  Copyright © 2024 Soramitsu. All rights reserved.
//

import UIKit

struct BlankTheme: Theme {
    let spacing = Spacing(
        _2XS: 2,
        _XS: 4,
        _S: 8,
        _SM: 12,
        _M: 16,
        _L: 24,
        _XL: 32,
        _2XL: 40,
        _3XL: 48,
        _4XL: 56,
        _5XL: 64,
        inset: UIEdgeInsets(offset: 16))

    let borderRadius = BorderRadius(_XS: 12, _S: 12, _M: 12, _ML: 12, _L: 12)

    var colors: Colors {
        Colors(
            accent: accentColor,
            background: backgroundColors,
            foreground: foregroundColors,
            state: stateColors,
            aliasSurfaceElevated: Asset.Colors.aliasSurfaceElevated.color,
            iOSDefaultSearchField: Asset.Colors.iosDefaultSearchField.color,
            iOSMaterialsChrome: Asset.Colors.iosMaterialsChrome.color)
    }

    // MARK: - Private Properties

    private let accentColor = Colors.Accent(
        primary: Asset.Colors.Accent.primary.color,
        primaryContainer: Asset.Colors.Accent.primaryContainer.color,
        secondary: Asset.Colors.Accent.secondary.color,
        secondaryContainer: Asset.Colors.Accent.secondaryContainer.color,
        teritary: Asset.Colors.Accent.teritary.color,
        teritaryContainer: Asset.Colors.Accent.teritaryContainer.color)

    private let backgroundColors = Colors.Background(
        page: Asset.Colors.Bg.page.color,
        surface: Asset.Colors.Bg.surface.color,
        surfaceVariant: Asset.Colors.Bg.surfaceVariant.color,
        surfaceInverted: Asset.Colors.Bg.surfaceInverted.color)

    private let foregroundColors = Colors.Foreground(
        primary: Asset.Colors.Fg.primary.color,
        secondary: Asset.Colors.Fg.secondary.color,
        inverted: Asset.Colors.Fg.inverted.color,
        outline: Asset.Colors.Fg.outline.color)

    private let stateColors = Colors.State(
        pressedDefault: Asset.Colors.State.pressedDefault.color,
        pressedAccentPrimary: Asset.Colors.State.pressedAccentPrimary.color,
        pressedAccentSecondary: Asset.Colors.State.pressedAccentSecondary.color,
        pressedAccentTeritary: Asset.Colors.State.pressedAccentTeritary.color,
        pressedAccentInverted: Asset.Colors.State.pressedAccentInverted.color,
        disabledBG: Asset.Colors.State.disabledBG.color,
        disabledFG: Asset.Colors.State.disabledFG.color
    )
}
