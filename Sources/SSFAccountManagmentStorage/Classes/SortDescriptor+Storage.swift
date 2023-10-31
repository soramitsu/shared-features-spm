import Foundation

extension NSSortDescriptor {
    public static var accountsByOrder: NSSortDescriptor {
        NSSortDescriptor(key: #keyPath(CDMetaAccount.order), ascending: true)
    }
}
