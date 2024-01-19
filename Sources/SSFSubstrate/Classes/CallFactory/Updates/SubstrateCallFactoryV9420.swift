//import Foundation
//import BigInt
//import SSFUtils
//import SSFModels
//
//class SubstrateCallFactoryV9420: SubstrateCallFactoryV9390 {
//    override func defaultTransfer(to receiver: AccountId, amount: BigUInt) -> any RuntimeCallable {
//        let args = TransferCall(dest: .accoundId(receiver), value: amount, currencyId: nil)
//        let path: SubstrateCallPath = .transferAllowDeath
//        return RuntimeCall(
//            moduleName: path.moduleName,
//            callName: path.callName,
//            args: args
//        )
//    }
//}
