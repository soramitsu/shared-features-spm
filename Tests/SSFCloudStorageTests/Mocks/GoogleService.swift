import GoogleAPIClientForRESTCore
import SSFCloudStorage
import GoogleAPIClientForREST_Drive

final class GoogleServiceMock: GoogleService {
    var ticket: GoogleServiceTicketMock?

    func executeQuery(_ queryObj: GTLRQueryProtocol, completionHandler: @escaping (GoogleServiceTicket?, Any?, Error?) -> Void) -> GoogleServiceTicket? {
        ticket = GoogleServiceTicketMock()
        completionHandler(ticket, "Mocked Result", nil)
        return ticket
    }
    
    func set(authorizer: GTMFetcherAuthorizationProtocol?) {}
}
