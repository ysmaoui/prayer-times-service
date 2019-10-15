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
            pwd
            ls -la
            """
        }
    }
    catch(e){
        throw e
    }
    finally{
        cleanWs()
    }

}
