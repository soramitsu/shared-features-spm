@Library('jenkins-library@feature/DOPS-3035-setup-ci') _

def pipeline = new org.ios.AppPipeline(
    steps: this,
    sonar: true,
    sonarProjectName: 'shared-features-spm',
    sonarProjectKey: 'sora:shared-features-spm',
    appTests: false,
    disableUpdatePods: true,
    disableInstallPods: true,
    statusNotif: false,
    dojoProductType: 'sora-mobile'
)

pipeline.runPipeline()
