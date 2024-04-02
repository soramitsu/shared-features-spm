// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

#if os(macOS)
  import AppKit
#elseif os(iOS)
  import UIKit
#elseif os(tvOS) || os(watchOS)
  import UIKit
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif

// Deprecated typealiases
@available(*, deprecated, renamed: "ColorAsset.Color", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetColorTypeAlias = ColorAsset.Color
@available(*, deprecated, renamed: "ImageAsset.Image", message: "This typealias will be removed in SwiftGen 7.0")
public typealias AssetImageTypeAlias = ImageAsset.Image

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Asset Catalogs

// swiftlint:disable identifier_name line_length nesting type_body_length type_name
public enum Asset {
  public enum Colors {
    public enum Accent {
      public static let primary = ColorAsset(name: "Accent/primary")
      public static let primaryContainer = ColorAsset(name: "Accent/primaryContainer")
      public static let secondary = ColorAsset(name: "Accent/secondary")
      public static let secondaryContainer = ColorAsset(name: "Accent/secondaryContainer")
      public static let teritary = ColorAsset(name: "Accent/teritary")
      public static let teritaryContainer = ColorAsset(name: "Accent/teritaryContainer")
    }
    public enum Bg {
      public static let page = ColorAsset(name: "Bg/page")
      public static let surface = ColorAsset(name: "Bg/surface")
      public static let surfaceInverted = ColorAsset(name: "Bg/surfaceInverted")
      public static let surfaceVariant = ColorAsset(name: "Bg/surfaceVariant")
    }
    public enum Constants {
      public static let black = ColorAsset(name: "Constants/black")
      public static let white = ColorAsset(name: "Constants/white")
    }
    public enum Fg {
      public static let inverted = ColorAsset(name: "Fg/inverted")
      public static let outline = ColorAsset(name: "Fg/outline")
      public static let primary = ColorAsset(name: "Fg/primary")
      public static let secondary = ColorAsset(name: "Fg/secondary")
    }
    public enum State {
      public static let disabledBG = ColorAsset(name: "State/disabledBG")
      public static let disabledFG = ColorAsset(name: "State/disabledFG")
      public static let pressedAccentInverted = ColorAsset(name: "State/pressedAccentInverted")
      public static let pressedAccentPrimary = ColorAsset(name: "State/pressedAccentPrimary")
      public static let pressedAccentSecondary = ColorAsset(name: "State/pressedAccentSecondary")
      public static let pressedAccentTeritary = ColorAsset(name: "State/pressedAccentTeritary")
      public static let pressedDefault = ColorAsset(name: "State/pressedDefault")
    }
    public enum Status {
      public static let error = ColorAsset(name: "Status/error")
      public static let errorContainer = ColorAsset(name: "Status/errorContainer")
      public static let info = ColorAsset(name: "Status/info")
      public static let infoContainer = ColorAsset(name: "Status/infoContainer")
      public static let success = ColorAsset(name: "Status/success")
      public static let successContainer = ColorAsset(name: "Status/successContainer")
      public static let warning = ColorAsset(name: "Status/warning")
      public static let warningContainer = ColorAsset(name: "Status/warningContainer")
    }
    public static let aliasSurfaceElevated = ColorAsset(name: "aliasSurfaceElevated")
    public static let iosDefaultSearchField = ColorAsset(name: "iOSDefaultSearchField")
    public static let iosMaterialsChrome = ColorAsset(name: "iOSMaterialsChrome")
  }
  public enum Images {
    public static let _360 = ImageAsset(name: "360")
    public static let exchange = ImageAsset(name: "exchange")
    public static let send = ImageAsset(name: "send")
    public static let faceId = ImageAsset(name: "face_id")
    public static let fingerprint = ImageAsset(name: "fingerprint")
    public static let good = ImageAsset(name: "Good")
    public static let smthWrong = ImageAsset(name: "smth_wrong")
    public static let spinner24 = ImageAsset(name: "spinner_24")
    public static let maintenanceModeDisabled = ImageAsset(name: "maintenance_mode_disabled")
    public static let maintenanceModeEnabled = ImageAsset(name: "maintenance_mode_enabled")
    public static let maintenanceModeHeader = ImageAsset(name: "maintenance_mode_header")
    public static let maintenanceModeInfo = ImageAsset(name: "maintenance_mode_info")
    public static let back = ImageAsset(name: "back")
    public static let closeIcon = ImageAsset(name: "closeIcon")
    public static let folder = ImageAsset(name: "folder")
    public static let arrowsChevronBottom24 = ImageAsset(name: "arrows-chevron-bottom-24")
    public static let basicPlus24 = ImageAsset(name: "basic-plus-24")
    public static let beingVerified = ImageAsset(name: "being-verified")
    public static let copy16 = ImageAsset(name: "copy-16")
    public static let editProfileIcon = ImageAsset(name: "edit-profile-icon")
    public static let kycExample = ImageAsset(name: "kyc-example")
    public static let logoutIcon = ImageAsset(name: "logout-icon")
    public static let lookIcon = ImageAsset(name: "look-icon")
    public static let pencil16 = ImageAsset(name: "pencil-16")
    public static let profileCloseIcon = ImageAsset(name: "profile-close-icon")
    public static let unverifiedIcon = ImageAsset(name: "unverified-icon")
    public static let verificationFailedIcon = ImageAsset(name: "verification-failed-icon")
    public static let verifiedIcon = ImageAsset(name: "verified-icon")
    public static let warning = ImageAsset(name: "Warning")
    public static let arrowRight = ImageAsset(name: "arrow_right")
    public static let arrowsCircleArrowTop24 = ImageAsset(name: "arrows-circle-arrow-top-24")
    public static let arrowsRefreshCcw24 = ImageAsset(name: "arrows-refresh-ccw-24")
    public static let arrowsSwap9024 = ImageAsset(name: "arrows-swap-90-24")
    public static let bank = ImageAsset(name: "bank")
    public static let basicCheckMark24 = ImageAsset(name: "basic-check-mark-24")
    public static let basicClose24 = ImageAsset(name: "basic-close-24")
    public static let basicSettings24 = ImageAsset(name: "basic-settings-24")
    public static let basicStar24 = ImageAsset(name: "basic-star-24")
    public static let basicStarNo24 = ImageAsset(name: "basic-star-no-24")
    public static let basicUser24 = ImageAsset(name: "basic-user-24")
    public static let callOutcoming = ImageAsset(name: "call-outcoming")
    public static let checkmark = ImageAsset(name: "checkmark")
    public static let close = ImageAsset(name: "close")
    public static let dataSending = ImageAsset(name: "data_sending")
    public static let deleteNotification = ImageAsset(name: "delete-notification")
    public static let delete = ImageAsset(name: "delete")
    public static let deleteGrey = ImageAsset(name: "delete_grey")
    public static let deleteUser = ImageAsset(name: "delete_user")
    public static let direction45 = ImageAsset(name: "direction-45")
    public static let done = ImageAsset(name: "done")
    public static let download = ImageAsset(name: "download")
    public static let empty = ImageAsset(name: "empty")
    public static let error = ImageAsset(name: "error")
    public static let externalLink = ImageAsset(name: "external-link")
    public static let eyeNo = ImageAsset(name: "eye-no")
    public static let eye = ImageAsset(name: "eye")
    public static let fail = ImageAsset(name: "fail")
    public static let failed = ImageAsset(name: "failed")
    public static let failure = ImageAsset(name: "failure")
    public static let financeWallet24 = ImageAsset(name: "finance-wallet-24")
    public static let globeLang = ImageAsset(name: "globe-lang")
    public static let help = ImageAsset(name: "help")
    public static let info = ImageAsset(name: "info")
    public static let kycChangeCamera = ImageAsset(name: "kyc-change-camera")
    public static let kycExit = ImageAsset(name: "kyc-exit")
    public static let kycLightningOff = ImageAsset(name: "kyc-lightning-off")
    public static let kycLightningOn = ImageAsset(name: "kyc-lightning-on")
    public static let kycOpenGallery = ImageAsset(name: "kyc-open-gallery")
    public static let kycTakePhoto = ImageAsset(name: "kyc-take-photo")
    public static let kycOnboarding = ImageAsset(name: "kyc_onboarding")
    public static let lang = ImageAsset(name: "lang")
    public static let loading = ImageAsset(name: "loading")
    public static let lock = ImageAsset(name: "lock")
    public static let logout = ImageAsset(name: "logout")
    public static let mail = ImageAsset(name: "mail")
    public static let mainSpinner = ImageAsset(name: "main-spinner")
    public static let messengerIcon = ImageAsset(name: "messenger_icon")
    public static let newReceipt = ImageAsset(name: "new_receipt")
    public static let noNotifications = ImageAsset(name: "no-notifications")
    public static let notfoundPhone = ImageAsset(name: "notfound_phone")
    public static let notificationClose16 = ImageAsset(name: "notification-close-16")
    public static let notificationsNotAllowed = ImageAsset(name: "notifications_not_allowed")
    public static let pending = ImageAsset(name: "pending")
    public static let phone = ImageAsset(name: "phone")
    public static let pin = ImageAsset(name: "pin")
    public static let profileEdit = ImageAsset(name: "profile_edit")
    public static let profileLogout = ImageAsset(name: "profile_logout")
    public static let qrArc = ImageAsset(name: "qrArc")
    public static let qrSettings = ImageAsset(name: "qr_settings")
    public static let readAll = ImageAsset(name: "read-all")
    public static let `right` = ImageAsset(name: "right")
    public static let selectPhone = ImageAsset(name: "select_phone")
    public static let share = ImageAsset(name: "share")
    public static let smallCheckmark = ImageAsset(name: "small_checkmark")
    public static let soraNetworkSmall = ImageAsset(name: "sora_network_small")
    public static let spinner = ImageAsset(name: "spinner")
    public static let success = ImageAsset(name: "success")
    public static let successful = ImageAsset(name: "successful")
    public static let tcIcon = ImageAsset(name: "tc_icon")
    public static let telegramIcon = ImageAsset(name: "telegram_icon")
    public static let transactionDeposit = ImageAsset(name: "transaction-deposit")
    public static let transactionReceive = ImageAsset(name: "transaction-receive")
    public static let transactionSend = ImageAsset(name: "transaction-send")
    public static let transactionCompletedIcon = ImageAsset(name: "transaction_completed_icon")
    public static let transactionFailed = ImageAsset(name: "transaction_failed")
    public static let transactionFailedIcon = ImageAsset(name: "transaction_failed_icon")
    public static let transactionPending = ImageAsset(name: "transaction_pending")
    public static let transactionPendingIcon = ImageAsset(name: "transaction_pending_icon")
    public static let transactionPendingNew = ImageAsset(name: "transaction_pending_new")
    public static let transactionsMain = ImageAsset(name: "transactionsMain")
    public static let user = ImageAsset(name: "user")
    public static let userGuideIcon = ImageAsset(name: "user_guide_icon")
    public static let verification = ImageAsset(name: "verification")
    public static let whatsappIcon = ImageAsset(name: "whatsapp_icon")
    public static let windowHandle = ImageAsset(name: "window_handle")
  }
  public enum CbdcImages {
    public static let calendar16 = ImageAsset(name: "calendar-16")
    public static let callPhone16 = ImageAsset(name: "call-phone-16")
    public static let chunk16 = ImageAsset(name: "chunk-16")
    public static let globe16 = ImageAsset(name: "globe-16")
    public static let verified16 = ImageAsset(name: "verified-16")
    public static let qrScan = ImageAsset(name: "QR_scan")
    public static let depositMain = ImageAsset(name: "depositMain")
    public static let qrCodeMain = ImageAsset(name: "qrCodeMain")
    public static let receiveMain = ImageAsset(name: "receiveMain")
    public static let sendMain = ImageAsset(name: "sendMain")
    public static let background = ImageAsset(name: "background")
    public static let basicClear24 = ImageAsset(name: "basic-clear-24")
    public static let bell = ImageAsset(name: "bell")
    public static let breakwayLine = ImageAsset(name: "breakway_line")
    public static let checkLogo = ImageAsset(name: "check-logo")
    public static let deposit24 = ImageAsset(name: "deposit-24")
    public static let historyEmpty = ImageAsset(name: "history_empty")
    public static let kycClose = ImageAsset(name: "kyc_close")
    public static let launchLogo = ImageAsset(name: "launch_logo")
    public static let launchTitle = ImageAsset(name: "launch_title")
    public static let notificationsAllowed = ImageAsset(name: "notifications_allowed")
    public static let receiptLogo = ImageAsset(name: "receipt_logo")
    public static let receive24 = ImageAsset(name: "receive-24")
    public static let registered = ImageAsset(name: "registered")
    public static let scan24 = ImageAsset(name: "scan-24")
    public static let send24 = ImageAsset(name: "send-24")
    public static let sendBack = ImageAsset(name: "send_back")
    public static let settingsNotificationsDisabled = ImageAsset(name: "settings_notifications_disabled")
    public static let settingsNotificationsEnabled = ImageAsset(name: "settings_notifications_enabled")
    public static let shareQrLogo = ImageAsset(name: "shareQrLogo")
    public static let smallDelete = ImageAsset(name: "small-delete")
    public static let transactionDeposit = ImageAsset(name: "transaction-deposit")
    public static let transactionReceive = ImageAsset(name: "transaction-receive")
    public static let transactionSend = ImageAsset(name: "transaction-send")
    public static let transactionIconBackground = ImageAsset(name: "transaction_icon_background")
    public static let transactionStatusCompleted = ImageAsset(name: "transaction_status_completed")
    public static let transactionStatusFailed = ImageAsset(name: "transaction_status_failed")
    public static let transactionStatusPending = ImageAsset(name: "transaction_status_pending")
    public static let unreadBell = ImageAsset(name: "unread_bell")
  }
}
// swiftlint:enable identifier_name line_length nesting type_body_length type_name

// MARK: - Implementation Details

public final class ColorAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Color = NSColor
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Color = UIColor
  #endif

  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  public private(set) lazy var color: Color = {
    guard let color = Color(asset: self) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }()

  #if os(iOS) || os(tvOS)
  @available(iOS 11.0, tvOS 11.0, *)
  public func color(compatibleWith traitCollection: UITraitCollection) -> Color {
    let bundle = BundleToken.bundle
    guard let color = Color(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load color asset named \(name).")
    }
    return color
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public private(set) lazy var swiftUIColor: SwiftUI.Color = {
    SwiftUI.Color(asset: self)
  }()
  #endif

  fileprivate init(name: String) {
    self.name = name
  }
}

public extension ColorAsset.Color {
  @available(iOS 11.0, tvOS 11.0, watchOS 4.0, macOS 10.13, *)
  convenience init?(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSColor.Name(asset.name), bundle: bundle)
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Color {
  init(asset: ColorAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }
}
#endif

public struct ImageAsset {
  public fileprivate(set) var name: String

  #if os(macOS)
  public typealias Image = NSImage
  #elseif os(iOS) || os(tvOS) || os(watchOS)
  public typealias Image = UIImage
  #endif

  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, macOS 10.7, *)
  public var image: Image {
    let bundle = BundleToken.bundle
    #if os(iOS) || os(tvOS)
    let image = Image(named: name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    let name = NSImage.Name(self.name)
    let image = (bundle == .main) ? NSImage(named: name) : bundle.image(forResource: name)
    #elseif os(watchOS)
    let image = Image(named: name)
    #endif
    guard let result = image else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }

  #if os(iOS) || os(tvOS)
  @available(iOS 8.0, tvOS 9.0, *)
  public func image(compatibleWith traitCollection: UITraitCollection) -> Image {
    let bundle = BundleToken.bundle
    guard let result = Image(named: name, in: bundle, compatibleWith: traitCollection) else {
      fatalError("Unable to load image asset named \(name).")
    }
    return result
  }
  #endif

  #if canImport(SwiftUI)
  @available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
  public var swiftUIImage: SwiftUI.Image {
    SwiftUI.Image(asset: self)
  }
  #endif
}

public extension ImageAsset.Image {
  @available(iOS 8.0, tvOS 9.0, watchOS 2.0, *)
  @available(macOS, deprecated,
    message: "This initializer is unsafe on macOS, please use the ImageAsset.image property")
  convenience init?(asset: ImageAsset) {
    #if os(iOS) || os(tvOS)
    let bundle = BundleToken.bundle
    self.init(named: asset.name, in: bundle, compatibleWith: nil)
    #elseif os(macOS)
    self.init(named: NSImage.Name(asset.name))
    #elseif os(watchOS)
    self.init(named: asset.name)
    #endif
  }
}

#if canImport(SwiftUI)
@available(iOS 13.0, tvOS 13.0, watchOS 6.0, macOS 10.15, *)
public extension SwiftUI.Image {
  init(asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle)
  }

  init(asset: ImageAsset, label: Text) {
    let bundle = BundleToken.bundle
    self.init(asset.name, bundle: bundle, label: label)
  }

  init(decorative asset: ImageAsset) {
    let bundle = BundleToken.bundle
    self.init(decorative: asset.name, bundle: bundle)
  }
}
#endif

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
