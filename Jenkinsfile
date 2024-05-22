@Library('jenkins-library@feature/DOPS-3035') _

def pipeline = new org.ios.AppPipeline(
    steps: this,
    sonar: true,
    sonarProjectName: 'shared-features-spm',
    sonarProjectKey: 'sora:shared-features-spm',
    appTests: false,
    disableUpdatePods: true,
    disableInstallPods: true,
    label: "mac-sora",
    statusNotif: false,
    dojoProductType: 'sora-mobile'
)

pipeline.runPipeline()
