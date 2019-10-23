#!/bin/bash -xe

APP_NAME="prayertimes"

main(){

    print_state

    # get deployed service role
    INITIALLY_DEPLOYED_ROLE=$(kubectl get services -l app=${APP_NAME} -o jsonpath="{.items[*].spec.selector.role}")
    export INITIALLY_DEPLOYED_ROLE

    if [[ -z "$INITIALLY_DEPLOYED_ROLE" ]]
    then

        echo "*****: Initially no service for the app was deployed => deploying initial Blue deployment *****"
        # no service is deployed, deploy blue
        export TARGET_ROLE="blue"
        export APP_VERSION="${APP_VERSION}"
        envsubst < deployment_config/deployment.yml | kubectl apply -f -
        kubectl rollout status deployment "${APP_NAME}-deployment-${TARGET_ROLE}"

        envsubst < deployment_config/service.yml | kubectl apply -f -

        print_state

        service_hostname=$(kubectl get svc ${APP_NAME}-service -o jsonpath="{.status.loadBalancer.ingress[*].hostname}")
        curl -I "$service_hostname"

    else
        if [[ "$INITIALLY_DEPLOYED_ROLE" == "blue" ]]
        then
        export TARGET_ROLE="green"

        elif [[ "$INITIALLY_DEPLOYED_ROLE" == "green" ]]
        then
        export TARGET_ROLE="blue"

        else
            echo "Service role was not recognized: ${INITIALLY_DEPLOYED_ROLE}"
            exit 1
        fi

        # deploy second role
        printf "\nDeploying role: %s" "${TARGET_ROLE}"
        envsubst < deployment_config/deployment.yml | kubectl apply -f -

        printf "\nWaiting for deployment to be done\n"
        kubectl rollout status deployment "${APP_NAME}-deployment-${TARGET_ROLE}"

        print_state

        # TODO:test with test_service

        # if tests successful switch service to new deployment
        printf "\nSwitching service to new deployment\n"
        envsubst < deployment_config/service.yml | kubectl apply -f -

        print_state

        printf "\nTesting the deployed service\n"
        service_hostname=$(kubectl get svc ${APP_NAME}-service -o jsonpath="{.status.loadBalancer.ingress[*].hostname}")
        curl -I "${service_hostname}"


        # delete old deployment
        printf "\nDelete old deployment\n"
        kubectl delete deployment "${APP_NAME}-deployment-${INITIALLY_DEPLOYED_ROLE}"

        # wait for all pods to be deleted
        sleep 5

        print_state
    fi
}


print_state(){

    set +x

    printf "\n\n============ BEGIN: Cluster State description ============\n\n"

    printf "\nLisitng available deployments\n"
    kubectl get deployments -o wide

    printf "\nLisitng available services\n"
    kubectl get services -o wide

    printf "\nLisitng available pods and their nodes\n"
    kubectl get pods -o wide

    printf "\n============ Cluster State description: END ============\n\n\n"

    set -x
}

main
