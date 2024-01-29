import GoogleAPIClientForRESTCore
import GoogleAPIClientForREST_Drive

public protocol GoogleService {
    func executeQuery(_ queryObj: GTLRQueryProtocol, completionHandler: @escaping (GoogleServiceTicket?, Any?, Error?) -> Void) -> GoogleServiceTicket?
    func set(authorizer: GTMFetcherAuthorizationProtocol?)
}

final class BaseGoogleService: GoogleService {
    private let googleService: GTLRDriveService

    public init(googleService: GTLRDriveService) {
        self.googleService = googleService
    }

    public func executeQuery(_ queryObj: GTLRQueryProtocol, completionHandler: @escaping (GoogleServiceTicket?, Any?, Error?) -> Void) -> GoogleServiceTicket? {
        let ticket: GTLRServiceTicket? = googleService.executeQuery(queryObj) { (gtlrTicket, object, error) in
            completionHandler(BaseGoogleServiceTicket(ticket: gtlrTicket), object, error)
        }
        
        guard let ticket else { return nil }

        return BaseGoogleServiceTicket(ticket: ticket)
    }
    
    public func set(authorizer: GTMFetcherAuthorizationProtocol?) {
        googleService.authorizer = authorizer
    }
}
