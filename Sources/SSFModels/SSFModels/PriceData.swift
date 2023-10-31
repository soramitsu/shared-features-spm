import Foundation

public struct PriceData: Codable, Equatable {
    public let priceId: String
    public let price: String
    public let fiatDayChange: Decimal?
    
    public init(priceId: String, price: String, fiatDayChange: Decimal?) {
        self.priceId = priceId
        self.price = price
        self.fiatDayChange = fiatDayChange
    }
}
