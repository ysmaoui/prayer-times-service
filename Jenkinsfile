#!/usr/bin/env groovy


node{
    try{
        stage("checkout"){
            checkout scm
        }

        stage("lint"){
            sh """
            python3 -m flake8 --exclude praytimes.py
            git ls-files --exclude='Dockerfile*' --ignored | xargs hadolint
            """
        }

        stage("build"){
            sh """
            docker build -t prayer-times-service .
            """
        }
        stage("test"){
            try{
                sh """
                docker run \
                    --rm -d \
                    --name prayer-times-service-container \
                    -p 8888:80 \
                    prayer-times-service

                sleep 5

                curl localhost:8888
                """
            }catch(e){
                throw e
            }
            finally{
                sh """
                docker ps
                docker stop prayer-times-service-container
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
        docker rmi prayer-times-service
        docker images
        """
    }

}
