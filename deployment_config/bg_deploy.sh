#!/bin/bash -xe

main(){

    # get deployed service role
    DEPLOYED_ROLE=$(kubectl get services -l app=tomcat -o jsonpath="{.items[*].spec.selector.role}")
    export DEPLOYED_ROLE

    if [[ -z "$DEPLOYED_ROLE" ]]
    then
        # no service is deployed, deploy blue
        export TARGET_ROLE="blue"
        export APP_VERSION="${APP_VERSION}"
        envsubst < deployment_config/deployment.yml | kubectl apply -f -
        # TODO: deploy service

    else
        if [[ "$DEPLOYED_ROLE" == "blue" ]]
        then
        export TARGET_ROLE="green"

        elif [[ "$DEPLOYED_ROLE" == "green" ]]
        then
        export TARGET_ROLE="blue"

        else
            echo "service role was not recognized: ${DEPLOYED_ROLE}"
            exit 1

        # deploy second role
        envsubst < deployment_config/deployment.yml | kubectl apply -f -
        # test

        # if tests successful switch service to new deployment
        envsubst < deployment_config/service.yml | kubectl apply -f -
        # delete old deployment
        kubectl delete deployment "tomcat-deployment-${DEPLOYED_ROLE}"
        fi
    fi
}


main