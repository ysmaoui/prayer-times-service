# Deploying Kubernetes cluster on AWS

## Components

To create a working Kubernetes cluster, three components needs to be created

* Networking (VPC,subnets and control panel security group)
* The EKS cluster ( managed control panel)
* Worker nodes


## Steps

1. deploy the kubernetes cluster networking infrastructure

```sh
infrastructure/create.sh k8s-Cluster-Network infrastructure/k8s_cluster/cluster_network.yml infrastructure/k8s_cluster/cluster_network.json
```

2. deploy the control panel

```sh
infrastructure/create.sh k8s-Cluster-Control infrastructure/k8s_cluster/cluster_controlNode.yml infrastructure/k8s_cluster/cluster_controlNode.json
```

3. get the kubeconfig from the created control panel

this will allow the use of kubectl from the local terminal

```sh
aws eks --region <region> update-kubeconfig --name <clusterName>
```

the response would be

```sh
Added new context arn:aws:eks:<region>:<aws_account_id>:cluster/<clusterName> to
<path_to_local_kubeconfig>
```


and the first service can now be checked

```sh
kubectl get svc
```

4. deploy worker nodes

```sh
infrastructure/create.sh k8s-Cluster-Workers infrastructure/k8s_cluster/cluster_workerNodes.yml infrastructure/k8s_cluster/cluster_workerNodes.json
```

5. setup the AWS authenticator configMap

    1. get the default configmap template

    ```sh
    curl -O https://amazon-eks.s3-us-west-2.amazonaws.com/cloudformation/2019-01-09/aws-auth-cm.yaml
    ```

    **or** use the file `k8s_cluster/aws-auth-cm.yml` from the current repo.

    2. modfiy the `aws-auth-cm.yaml` file and adjust the role arn with the nodeInstanceRole arn associated with the launchconfig of the worker nodes ( the value is defined as output in cluster_workerNodes.yml )

    ```sh
    apiVersion: v1
    kind: ConfigMap
    metadata:
    name: aws-auth
    namespace: kube-system
    data:
    mapRoles: |
        - rolearn: <ARN of instance role>
        username: system:node:{{EC2PrivateDNSName}}
        groups:
            - system:bootstrappers
            - system:nodes
    ```
    3. Also add the IAM-user used by jenkins to give it access to the cluster

    ```sh
        apiVersion: v1
        kind: ConfigMap
        metadata:
        name: aws-auth
        namespace: kube-system
        data:
        mapRoles: |
            - rolearn: 	<arn_of_instance_role_of_worker_nodes>
            username: system:node:{{EC2PrivateDNSName}}
            groups:
                - system:bootstrappers
                - system:nodes
            - rolearn: <arn_of_jenkins_user_that_needs_to_control_the_cluster>
            username: <jenkins_user_name>
            groups:
                - system:masters
    ```

    4. apply the configMap to the cluster

    ```sh
    kubectl apply -f aws-auth-cm.yaml
    ```

6. Check that the worker nodes were added to the cluster

```sh
kubectl get nodes
```


## Notes

### Policies needed by the IAM-jenkins-user

The IAM-jenkins-user is the aws user that will be used by jenkins to interact with the aws resources

* To be able to get the kubeconfig, the IAM-jenkins-user needs the following permissions

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster",
                "eks:ListClusters"
            ],
            "Resource": "*"
        }
    ]
}
```

* it is also possible to give the jenkins user complete admin rights to the eks resources

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:*"
            ],
            "Resource": "*"
        }
    ]
}
```


