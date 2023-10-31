import Foundation
import SSFLogger

protocol Migrating {
    func migrate() throws
}

extension SubstrateStorageMigrator: Migrating {
    func migrate() throws {
        guard requiresMigration() else {
            return
        }

        performMigration()

        Logger.shared.info("Db migration completed")
    }
}
