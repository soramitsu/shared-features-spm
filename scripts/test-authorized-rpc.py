#!/usr/bin/env python3
"""Compile byte-identical production RPC sources in a narrow macOS test package.

No production checkout or resolved dependency is changed. App/device integration
still requires the full pinned iOS package and distribution builds.
"""
import argparse
import hashlib
import json
import re
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

parser = argparse.ArgumentParser()
parser.add_argument('--output-dir', type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parents[1]
out = args.output_dir or Path(tempfile.mkdtemp(prefix='fearless-rpc-tests-'))
if args.output_dir:
    out.mkdir(parents=True, exist_ok=False)
network = root / 'Sources/SSFUtils/SSFUtils/Classes/Network'
common = root / 'Sources/SSFUtils/SSFUtils/Classes/Common'
source_map = {
    'SSFUtils': [network / p for p in ['JSONRPCEngine.swift', 'JSONRPCOperation.swift', 'JSONRPCInfo.swift',
        'JSONRPCData.swift', 'Health.swift', 'ReconnectionStrategy.swift', 'RPCMethod.swift',
        'WebSocketEngine.swift', 'WebSocketEngine+Protocol.swift', 'WebSocketEngine+Delegate.swift',
        'Reachability/ReachabilityManager.swift']] + [common / p for p in ['Scheduler.swift','ReaderWriterLock.swift','Logger.swift']],
    'SSFModels': [root / 'Sources/SSFModels/SSFModels/Constants.swift'],
    'RobinHood': [root / 'Sources/RobinHood/Classes/Operations/Base/BaseOperation.swift']
}
package_source = (root / 'Package.swift').read_bytes()
match = re.search(r'\.package\(url: "https://github.com/soramitsu/fearless-starscream", \.revision\("([0-9a-f]{40})"\)\)', package_source.decode())
if not match:
    sys.exit('Shipping Starscream dependency must have an exact source revision')
starscream_revision = match.group(1)
hashes = {'Package.swift': hashlib.sha256(package_source).hexdigest()}
for module, sources in source_map.items():
    target = out / 'Sources' / module
    target.mkdir(parents=True)
    for source in sources:
        data = source.read_bytes()
        (target / source.name).write_bytes(data)
        hashes[str(source.relative_to(root))] = hashlib.sha256(data).hexdigest()
shutil.copytree(root / 'Tests/AuthorizedRPC', out / 'Tests/AuthorizedRPCTests')
harness_manifest = '''// swift-tools-version:5.2
import PackageDescription
let package = Package(name: "FearlessRPCContract", platforms: [.macOS(.v10_14)], dependencies: [
    .package(url: "https://github.com/soramitsu/fearless-starscream", .revision("b6ef58590241babdb4fe52e916a02c9e2b749e3d")),
    .package(url: "https://github.com/ashleymills/Reachability.swift", .revision("21d1dc412cfecbe6e34f1f4c4eb88d3f912654a6"))
], targets: [
    .target(name: "SSFModels"), .target(name: "RobinHood"),
    .target(name: "SSFUtils", dependencies: ["SSFModels", "RobinHood", .product(name: "Starscream", package: "fearless-starscream"), .product(name: "Reachability", package: "Reachability.swift")]),
    .testTarget(name: "AuthorizedRPCTests", dependencies: ["SSFUtils", "RobinHood", .product(name: "Starscream", package: "fearless-starscream")])
])
'''
(out / 'Package.swift').write_text(harness_manifest.replace('b6ef58590241babdb4fe52e916a02c9e2b749e3d', starscream_revision))
(out / 'source-sha256.json').write_text(json.dumps(hashes, indent=2) + '\n')
result = subprocess.run(['swift', 'test', '--package-path', str(out)], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
(out / 'test.log').write_text(result.stdout)
sys.stdout.write(result.stdout)
for source, digest in hashes.items():
    if hashlib.sha256((root / source).read_bytes()).hexdigest() != digest:
        sys.exit('Production source changed while contract tests ran: ' + source)
if result.returncode:
    sys.exit(result.returncode)
passed = re.findall(r"^Test Case (.+) passed \(", result.stdout, re.MULTILINE)
if len(passed) != 21 or len(set(passed)) != 21 or re.search(r"^Test Case .+ (?:failed|skipped) \(", result.stdout, re.MULTILINE):
    sys.exit('Expected exactly 21 distinct passing XCTest cases, no skips')
print('PASS: 21 distinct cases; production source and dependency revision bound')
print('Contract evidence:', out)
