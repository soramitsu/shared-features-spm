//
//  HistoryServiceAssemblyTests.swift
//  
//
//  Created by Soramitsu on 19.03.2024.
//

import XCTest
import SSFModels

@testable import SSFIndexers

final class HistoryServiceAssemblyTests: BaseHistoryServiceTestCase {

    func testSubqueryAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .subquery)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is SubqueryHistoryService)
    }
    
    func testSubsquidAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .subsquid)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is SubsquidHistoryService)
    }
    
    func testGiantsquidAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .giantsquid)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is GiantsquidHistoryService)
    }
    
    func testSoraAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .sora)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is SoraSubsquidHistoryService)
    }
    
    func testEtherscanAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .etherscan)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is EtherscanHistoryService)
    }
    
    func testOklinkAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .oklink)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is OklinkHistoryService)
    }
    
    func testReefAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .reef)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is ReefSubsquidHistoryService)
    }
    
    func testZetaAssemblyBuild() async throws {
        let chainAsset = chainAsset(with: .zeta)
        let servie = try await HistoryServiceAssembly.createService(for: chainAsset)
        
        XCTAssertTrue(servie is ZetaHistoryService)
    }
    
    // MARK: - Private methods
    
    private func chainAsset(
        with blockExplorerType: BlockExplorerType
    ) -> ChainAsset {
        chainAsset(
            blockExplorerType: blockExplorerType,
            assetSymbol: "",
            precision: 1,
            ethereumType: nil,
            contractaddress: nil
        )
    }
}
