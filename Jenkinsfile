#!/usr/bin/env groovy


node{

    stage("checkout"){
        checkout scm
    }

    stage("lint"){
        sh """
        python3 -m flake8 --exclude praytimes.py
        git ls-files --exclude='Dockerfile*' --ignored | xargs hadolint
        """
    }
}