@Library('jenkins-library@feature/DOPS-3035') _
//Test jenkins
def pipeline = new org.ios.ShareFeature(
  steps: this,
  dojoProductType: "sora-mobile",
  lintCmd: 'cd tools/swiftformat && ./swiftformat --lint ./../../Sources',
  buildCmd: "xcodebuild -scheme Modules-Package -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.0'"
)

pipeline.runPipeline()
