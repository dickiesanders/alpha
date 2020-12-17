// https://github.com/jenkinsci/kubernetes-plugin
// https://kubernetes.io/docs/reference/kubectl/cheatsheet/

// envVars Environment variables that are applied to ALL containers.
// envVar An environment variable whose value is defined inline.
// secretEnvVar An environment variable whose value is derived from a Kubernetes secret.

// Create this pipeline in Alpha Jenkins Contoller
pipeline {
  agent any
  stages {
    stage('Create') {
      steps {
        sh 'echo Create Application Jenkins Controller via Helm Chart'
        sh './run.sh'
      }
    }
  }
}
