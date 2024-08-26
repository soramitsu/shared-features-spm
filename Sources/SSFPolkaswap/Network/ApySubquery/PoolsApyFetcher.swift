import Foundation
import SSFModels
import SSFNetwork

public enum PoolsApyFetcherError: Error {
    case noBlockExplorer
}

public protocol PoolsApyFetcher {
    func fetch(poolIds: [String]) async throws -> [PoolApyInfo]
    func subscribe(poolIds: [String]) async throws
        -> AsyncThrowingStream<[CachedNetworkResponse<PoolApyInfo>], Swift.Error>
}

final class PoolsApyFetcherDefault: PoolsApyFetcher {
    private let url: URL?

    init(url: URL?) {
        self.url = url
    }

    func fetch(poolIds: [String]) async throws -> [PoolApyInfo] {
        var apyInfos: [PoolApyInfo] = []
        var cursor = ""
        var allApyInfosFetched = false

        while !allApyInfosFetched {
            let response = try await loadNewApyInfos(poolIds: poolIds, cursor: cursor)
            apyInfos = apyInfos + response.nodes
            allApyInfosFetched = response.pageInfo.hasNextPage.or(false) == false
            cursor = response.pageInfo.endCursor.or("")
        }

        return apyInfos
    }

    func subscribe(poolIds: [String]) async throws
        -> AsyncThrowingStream<[CachedNetworkResponse<PoolApyInfo>], Error>
    {
        AsyncThrowingStream<[CachedNetworkResponse<PoolApyInfo>], Error> { continuation in
            Task {
                var apyInfos: [CachedNetworkResponse<PoolApyInfo>] = []
                var cursor: String = ""
                var allApyInfosFetched: Bool = false

                let stream = try await subscribeNewApyInfos(poolIds: poolIds, cursor: cursor)

                for try await newApyInfosPage in stream {
                    let newApyInfos = newApyInfosPage.value?.nodes
                        .compactMap { CachedNetworkResponse(
                            value: $0,
                            type: newApyInfosPage.type
                        ) }
                    apyInfos = apyInfos + newApyInfos.or([])
                    allApyInfosFetched = (newApyInfosPage.value?.pageInfo.hasNextPage)
                        .or(false) == false
                    cursor = (newApyInfosPage.value?.pageInfo.endCursor).or("")

                    if allApyInfosFetched {
                        continuation.yield(apyInfos)
                    }
                }

                continuation.yield(apyInfos)
            }
        }
    }

    private func subscribeNewApyInfos(
        poolIds: [String],
        cursor: String
    ) async throws -> AsyncThrowingStream<CachedNetworkResponse<SoraSubqueryApyInfoPage>, Error> {
        return AsyncThrowingStream<
            CachedNetworkResponse<SoraSubqueryApyInfoPage>,
            Swift.Error
        > { continuation in
            Task {
                guard let url else {
                    throw PoolsApyFetcherError.noBlockExplorer
                }

                let request = try GraphQLRequest(
                    baseURL: url,
                    query: queryString(poolIds: poolIds, cursor: cursor)
                )
                let worker = NetworkWorkerImpl()
                let stream: AsyncThrowingStream<
                    CachedNetworkResponse<GraphQLResponse<SoraSubqueryApyInfoResponse>>,
                    Error
                > = await worker.performRequest(with: request, withCacheOptions: .onAll)

                for try await poolsApy in stream {
                    guard let value = poolsApy.value else {
                        return
                    }

                    switch value {
                    case let .data(apys):
                        let response = CachedNetworkResponse(
                            value: apys.entities,
                            type: poolsApy.type
                        )
                        continuation.yield(response)
                    case let .errors(error):
                        continuation.yield(with: .failure(error))
                    }
                }
            }
        }
    }

    private func loadNewApyInfos(
        poolIds: [String],
        cursor: String
    ) async throws -> SoraSubqueryApyInfoPage {
        guard let url else {
            throw PoolsApyFetcherError.noBlockExplorer
        }

        let request = try GraphQLRequest(
            baseURL: url,
            query: queryString(poolIds: poolIds, cursor: cursor)
        )
        let worker = NetworkWorkerImpl()
        let response: GraphQLResponse<SoraSubqueryApyInfoResponse> = try await worker
            .performRequest(with: request)

        switch response {
        case let .data(data):
            return data.entities
        case let .errors(error):
            throw error
        }
    }

    private func queryString(poolIds: [String], cursor: String) -> String {
        """
         query
                                 PoolsApyQuery {
                                     entities: poolXYKs(
                                       first: 100
                                       after: "\(cursor)" ,
                                       filter: {id: {in: \(poolIds.sorted()) }}) {
                                           nodes {
                                             id strategicBonusApy
                                           }
                                           pageInfo {
                                             hasNextPage endCursor
                                           }
                                     }
                                 }
        """
    }
}
