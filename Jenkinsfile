library(
  identifier: 'jenkins-shared-library@master',
  retriever: modernSCM(
    [
      $class: 'GitSCMSource',
      remote: 'https://github.com/dhanarab/jenkins-pipeline-library.git'
    ]
  )
)

bitbucketHttpsCredentials = "Bitbucket_Build_AccelByte"
bitbucketCredentialsSsh = "build_account_bitbucket_key"

bitbucketPayload = null
bitbucketCommitHref = null

def getCommitMessageInRange(startCommitHash, endCommitHash) {
  shScript = "git log --oneline " + startCommitHash + "..." +  endCommitHash + " | cat"
  return sh(returnStdout: true, script: shScript)
}

def hasBreakingChangesSymbol(commitMessages) {
  if (commitMessages =~ "(feat|fix|docs|chore)(.*)!:") {
      return true
  }
  return false
}

pipeline {
  agent none
  stages {
    stage('Prepare') {
      agent {
        label "master"
      }
      steps {
        script {
          if (env.BITBUCKET_PAYLOAD) {
            bitbucketPayload = readJSON text: env.BITBUCKET_PAYLOAD
            if (bitbucketPayload.pullrequest) {
              bitbucketCommitHref = bitbucketPayload.pullrequest.source.commit.links.self.href
            }
          }
          if (bitbucketCommitHref) {
            bitbucket.setBuildStatus(bitbucketHttpsCredentials, bitbucketCommitHref, "INPROGRESS", env.JOB_NAME.take(30), "${env.JOB_NAME}-${env.BUILD_NUMBER}", "Jenkins", "${env.BUILD_URL}console")
          }
        }
      }
    }
    stage('Check Proto Breaking Changes') {
      agent {
        label "justice-codegen-sdk"
      }
      steps {
        script {
          commitMessages = getCommitMessageInRange("38f75038fb0f", "c92a4ea8e42e")
          echo 'Commits from pull request'
          echo commitMessages
          if (hasBreakingChangesSymbol(commitMessages)) {
            echo 'This pull request has ! symbol, skip breaking changes checking'
          } else {
            sh 'make breaking -s'
          }
        }
      }
    }
  }
  post {
    success {
      script {
        if (bitbucketCommitHref) {
          bitbucket.setBuildStatus(bitbucketHttpsCredentials, bitbucketCommitHref, "SUCCESSFUL", env.JOB_NAME.take(30), "${env.JOB_NAME}-${env.BUILD_NUMBER}", "Jenkins", "${env.BUILD_URL}console")
        }
      }
    }
    failure {
      script {
        if (bitbucketCommitHref) {
          bitbucket.setBuildStatus(bitbucketHttpsCredentials, bitbucketCommitHref, "FAILED", env.JOB_NAME.take(30), "${env.JOB_NAME}-${env.BUILD_NUMBER}", "Jenkins", "${env.BUILD_URL}console")
        }
      }
    }
  }
}
