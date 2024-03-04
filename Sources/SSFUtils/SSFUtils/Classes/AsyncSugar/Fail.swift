import Foundation

public struct Fail<Element, Failure>: AsyncSequence, Sendable, AsyncIteratorProtocol where Failure: Error {
    private let error: Failure
    private var isFinished = false
    
    // MARK: - Constructor
    
    public init(error: Failure) {
        self.error = error
    }
    
    // MARK: - AsyncSequence
    
    public func makeAsyncIterator() -> Self {
        .init(error: self.error)
    }
    
    // MARK: - AsyncIteratorProtocol
    
    public mutating func next() async throws -> Element? {
        defer { self.isFinished = true }
        guard !self.isFinished else { return nil }
        
        throw self.error
    }
}

extension Fail {
    public func finishedAsyncThrowingStream() -> AsyncThrowingStream<Element, Error> where Self: Sendable {
        AsyncThrowingStream(Element.self, bufferingPolicy: .bufferingNewest(1)) { continuation in
            continuation.finish(throwing: error)
        }
    }
}
