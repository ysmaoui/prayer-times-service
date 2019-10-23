#!/bin/bash -xe

main(){

    # get deployed service role
    DEPLOYED_ROLE=$(kubectl get services -l app=prayertimes -o jsonpath="{.items[*].spec.selector.role}")
    export DEPLOYED_ROLE

    if [[ -z "$DEPLOYED_ROLE" ]]
    then
        # no service is deployed, deploy blue
        export TARGET_ROLE="blue"
        export APP_VERSION="${APP_VERSION}"
        envsubst < deployment_config/deployment.yml | kubectl apply -f -
        envsubst < deployment_config/service.yml | kubectl apply -f -

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
        fi

        # list running pods
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName

        # deploy second role
        envsubst < deployment_config/deployment.yml | kubectl apply -f -

        kubectl rollout status deployment "prayertimes-deployment-${TARGET_ROLE}"

        # list running pods
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName


        # test with test_service

        # if tests successful switch service to new deployment
        envsubst < deployment_config/service.yml | kubectl apply -f -
        # delete old deployment
        kubectl delete deployment "prayertimes-deployment-${DEPLOYED_ROLE}"

        sleep 2
        # list running pods
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName

    fi
}


main