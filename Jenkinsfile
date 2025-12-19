pipeline {
    agent { dockerfile true }

    parameters {
        gitParameter branchFilter: 'origin/(.*)', defaultValue: 'scarthgap', selectedValue: 'DEFAULT', name: 'BRANCH', type: 'PT_BRANCH', description: 'branch to build'
        choice choices: ['raspberrypi5', 'raspberrypi4-64', 'qemux86-64' ], description: 'select machine', name: 'MACHINE'
        choice choices: ['satobox-base-image'], description: 'select image', name: 'IMAGE'
        choice choices: ['no', 'yes'], description: 'clean workspace', name: 'CLEAN'
        choice choices: ['no', 'yes'], description: 'build sdk', name: 'SDK'
    }

    stages {

        stage('Setup') {
            steps {
                sh "git describe --tags --always --dirty"
            }
        }

        stage('Clean') {
            when {
                expression { params.CLEAN == 'yes' }
            }
            steps {
               sh "git clean -fdx"
            }
        }

        stage('Build-Image') {
            steps {
                sh "KAS_MACHINE=${params.MACHINE} KAS_TARGET=${params.IMAGE} kas build --force-checkout --update kas-satobox.yml"
                archiveArtifacts artifacts: "build/tmp/deploy/images/${params.MACHINE}/${params.IMAGE}-${params.MACHINE}_*" ,
                                             followSymlinks: true,
                                             fingerprint: true,
                                             onlyIfSuccessful: true
            }
        }

        stage ('Build-SDK') {
            when {
                expression { params.SDK == 'yes' }
            }
            steps {
               sh "KAS_MACHINE=${params.MACHINE} KAS_TARGET=${params.IMAGE} KAS_TASK=populate_sdk kas build kas-satobox.yml"
               archiveArtifacts artifacts: "build/tmp/deploy/sdk/*.sh" , onlyIfSuccessful: true
            }
        }

    }
}
