@Library('jenkins-library@feature/DOPS-3035-setup-ci') _
//Test jenkins
def pipeline = new org.ios.ShareFeature(
  steps: this,
  dojoProductType: "sora-mobile",
  lintCmd: 'cd tools/swiftformat && ./swiftformat --lint ./../../Sources',
  testCmd: "xcodebuild -scheme Modules-Package -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.4' test",
  buildCmd: "xcodebuild -scheme Modules-Package -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.4'",
  sonarProjectKey: "sora:shared-features-spm",
  sonarProjectName: "shared-features-spm"
)

pipeline.runPipeline()
