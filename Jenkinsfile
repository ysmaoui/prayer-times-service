#!/usr/bin/env groovy

node{
    def app
    def dockerImageTag = "ysmaoui/prayer-times-service"
    try{
        stage("preparation"){
            cleanWs()
            checkout scm
        }

        stage("lint"){
            sh """
            python3 -m flake8 --exclude praytimes.py
            git ls-files --exclude='Dockerfile*' --ignored | xargs hadolint
            """
        }

        stage("build"){
            app = docker.build(dockerImageTag)
        }
        stage("test"){
            try{
                docker.image(dockerImageTag).withRun("-p 8888:80") { c->
                    sh 'curl localhost:8888'
                }

            }catch(e){
                throw e
            }
            finally{
                sh """
                docker ps
                """
            }
        }
        if( env.BRANCH_NAME.startsWith("release/") || env.BRANCH_NAME.startsWith("deployment")){
            stage("Upload Docker image"){
                docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials'){
                    env.APP_VERSION="${env.BRANCH_NAME}".substring(8)
                    app.push("${env.APP_VERSION}")
                    app.push("latest")
                }
            }

            withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDENTIALS', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                stage("setup Cluster"){
                    sh """
                    aws sts get-caller-identity
                    aws eks --region us-west-2 update-kubeconfig --name k8s-cluster
                    kubectl get nodes
                    """
                }
                stage("deploy"){
                    sh """
                    pwd
                    ls -la
                    export APP_VERSION=7
                    bash ./deployment_config/bg_deploy.sh
                    """
                }
            }
        }
    }
    catch(e){
        throw e
    }
    finally{
        cleanWs()

        sh """
        docker rmi $dockerImageTag
        docker images
        """
    }
}
