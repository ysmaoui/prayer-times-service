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
            // sh """
            // docker build -t prayer-times-service .
            // """

            app = docker.build(dockerImageTag)
        }
        stage("test"){
            try{
                // sh """
                // docker run \
                //     --rm -d \
                //     --name prayer-times-service-container \
                //     -p 8888:80 \
                //     prayer-times-service

                // sleep 5

                // curl localhost:8888
                // """

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
