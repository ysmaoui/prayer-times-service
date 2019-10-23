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
        kubectl rollout status deployment "prayertimes-deployment-${TARGET_ROLE}"

        envsubst < deployment_config/service.yml | kubectl apply -f -

        # list running pods
        printf "\nLisitng available pods and their nodes\n"
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName

        printf "\n listing available services\n"
        kubectl get svc -o wide
        service_hostname=$(kubectl get svc prayertimes-service -o jsonpath="{.status.loadBalancer.ingress[*].hostname}")
        curl -I "$service_hostname"

    else
        if [[ "$DEPLOYED_ROLE" == "blue" ]]
        then
        export TARGET_ROLE="green"

        elif [[ "$DEPLOYED_ROLE" == "green" ]]
        then
        export TARGET_ROLE="blue"

        else
            echo "Service role was not recognized: ${DEPLOYED_ROLE}"
            exit 1
        fi

        # list running pods
        printf "\nLisitng available pods and their nodes\n"
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName

        # deploy second role
        printf "\nDeploying role: %s" "${TARGET_ROLE}"
        envsubst < deployment_config/deployment.yml | kubectl apply -f -

        printf "\nWaiting for deployment to be done\n"
        kubectl rollout status deployment "prayertimes-deployment-${TARGET_ROLE}"

        printf "\nLisitng available pods and their nodes\n"
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName

        # test with test_service

        # if tests successful switch service to new deployment
        printf "\nSwitching service to new deployment\n"
        envsubst < deployment_config/service.yml | kubectl apply -f -

        printf "\nlisting existing services\n"
        kubectl get svc -l app=prayertimes -o wide
        printf "\nTesting the deployed service\n"
        service_hostname=$(kubectl get svc prayertimes-service -o jsonpath="{.status.loadBalancer.ingress[*].hostname}")
        curl -I "${service_hostname}m"


        # delete old deployment
        printf "\nDelete old deployment\n"
        kubectl delete deployment "prayertimes-deployment-${DEPLOYED_ROLE}"

        sleep 3
        # list running pods
        printf "\nLisitng available pods and their nodes\n"
        kubectl get pods --output=custom-columns=Name:.metadata.name,NodeName:.spec.nodeName

    fi
}


main