import RobinHood
import sorawallet
import Foundation

public final class SubqueryApyInfoOperation<ResultType>: BaseOperation<ResultType> {

    private let httpProvider: SoramitsuHttpClientProviderImpl
    private let soraNetworkClient: SoramitsuNetworkClient
    private let subQueryClient: SoraWalletBlockExplorerInfo

    public init(
        commonConfigUrlString: String,
        mobileConfigUrlString: String
    ) {
        let httpProvider = SoramitsuHttpClientProviderImpl()
        let soraNetworkClient = SoramitsuNetworkClient(timeout: 60000, logging: true, provider: httpProvider)
        let provider = SoraRemoteConfigProvider(
            client: soraNetworkClient,
            commonUrl: commonConfigUrlString,
            mobileUrl: mobileConfigUrlString
        )
        let configBuilder = provider.provide()

        self.httpProvider = httpProvider
        self.soraNetworkClient = soraNetworkClient
        self.subQueryClient = SoraWalletBlockExplorerInfo(networkClient: soraNetworkClient, soraRemoteConfigBuilder: configBuilder)

        super.init()
    }

    override public func main() {
        super.main()

        if isCancelled {
            return
        }

        if result != nil {
            return
        }

        let semaphore = DispatchSemaphore(value: 0)

        var optionalCallResult: Result<ResultType, Swift.Error>?

        DispatchQueue.main.async {
            self.subQueryClient.getSpApy(completionHandler: { [self] requestResult, error in

                if let data = requestResult as? ResultType {
                    optionalCallResult = .success(data)
                }

                semaphore.signal()

                result = optionalCallResult
            })
        }

        semaphore.wait()
    }
}
