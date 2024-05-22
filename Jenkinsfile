@Library('jenkins-library@feature/DOPS-3035-setup-ci') _

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
    jobParams: jobParams,
    disableInstallPods: true,
    statusNotif: false,
    dojoProductType: 'sora-mobile'
)

pipeline.runPipeline('shared-features-spm')
