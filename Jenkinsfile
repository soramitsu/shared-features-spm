@Library('jenkins-library@duty-27.03.2024/update_ios_pipeline') _

// Job properties
def jobParams = [
  booleanParam(defaultValue: false, description: 'push to the dev profile', name: 'prDeployment'),
  booleanParam(defaultValue: false, description: 'allow quality gate', name: 'sonarQualityGate'),
]

def pipeline = new org.ios.AppPipeline(
    steps: this,
    sonar: true,
    sonarProjectName: 'shared-features-spm',
    sonarProjectKey: 'sora:shared-features-spm',
    appTests: false,
    disableUpdatePods: true,
    disableInstallPods: true,
    jobParams: jobParams,
    label: "mac-sora",
    dojoProductType: 'sora'
)

pipeline.runPipeline()
