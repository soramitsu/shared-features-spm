import Foundation

public struct PriceData: Codable, Equatable {
    public let currencyId: String
    public let priceId: String
    public let price: String
    public let fiatDayChange: Decimal?

    public init(
        currencyId: String,
        priceId: String,
        price: String,
        fiatDayChange: Decimal?
    ) {
        self.currencyId = currencyId
        self.priceId = priceId
        self.price = price
        self.fiatDayChange = fiatDayChange
    }
}
