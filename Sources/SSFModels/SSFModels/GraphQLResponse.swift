import Foundation

public struct SubqueryErrors: Error, Decodable {
    public struct SubqueryError: Error, Decodable {
        public let message: String
    }

    public let errors: [SubqueryError]
}

public enum GraphQLResponse<D: Decodable>: Decodable {
    case data(_ value: D)
    case errors(_ value: SubqueryErrors)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        let json = try container.decode(JSON.self)

        if let data = json.data {
            let encoded = try JSONEncoder().encode(data)
            let value = try JSONDecoder().decode(D.self, from: encoded)
            self = .data(value)
        } else if let errors = json.errors {
            let encoded = try JSONEncoder().encode(errors)
            let values = try JSONDecoder().decode(
                [SubqueryErrors.SubqueryError].self,
                from: encoded
            )
            self = .errors(SubqueryErrors(errors: values))
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "unexpected value"
            )
        }
    }
}
