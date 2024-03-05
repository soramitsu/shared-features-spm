@Library('jenkins-library@feature/DOPS-3035') _
//Test jenkins
def pipeline = new org.ios.ShareFeature(
  steps: this,
  dojoProductType: "sora-mobile",
  lintCmd: 'cd tools/swiftformat && ./swiftformat --lint ./../../Sources',
  testCmd: "xcodebuild -scheme Modules-Package -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0' test",
  buildCmd: "xcodebuild -scheme Modules-Package -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'",
  sonarProjectKey: "sora:shared-features-spm",
  sonarProjectName: "shared-features-spm"
)

pipeline.runPipeline()
