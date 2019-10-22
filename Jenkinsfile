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
        if( env.BRANCH_NAME.startsWith("release/")){
            stage("Upload Docker image"){
                docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials'){
                    app.push("${env.BUILD_NUMBER}")
                    app.push("latest")
                }
            }

            stage("deploy"){
                sh """
                echo deploying to k8s cluster
                """
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
