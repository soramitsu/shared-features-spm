@testable import GoogleAPIClientForREST_Drive

class GTLRDriveServiceMock: GTLRDriveService {
    
    //MARK: - executeQuery
    
    var executeQueryCallsCount: Int = 0
    var executeQueryCalled: Bool {
        return executeQueryCallsCount > 0
    }
    var executeQueryReceivedArguments: (query: GTLRQueryProtocol, completionHandler: GTLRServiceCompletionHandler?)?
    var executeQueryReceivedInvocations: [(query: GTLRQueryProtocol, completionHandler: GTLRServiceCompletionHandler?)] = []
    
    var executeQueryReturnValue: GTLRServiceTicketProtocol!
    var executeQueryClosure: ((GTLRQueryProtocol, GTLRServiceCompletionHandler?) -> GTLRServiceTicketProtocol)?
    
    
    override func executeQuery(_ query: GTLRQueryProtocol, completionHandler handler: GTLRServiceCompletionHandler? = nil) -> GTLRServiceTicket {
        executeQueryCallsCount += 1
        executeQueryReceivedArguments = (query: query, completionHandler: handler)
        executeQueryReceivedInvocations.append((query: query, completionHandler: handler))
        return executeQueryClosure.map({$0(query, handler)}) ?? executeQueryReturnValue
    }
}
