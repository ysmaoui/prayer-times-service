# Setting Up Jenkins on AWS

## Highlights

* CloudFormation to create the infrastructure
* Ansible to configure the Jenkins servers
* EFS to store the jenkins configuration

## Description

defines the infrastructure to deploy a highly available jenkins server.
The configuration is stored in an EFS volume.

https://d0.awsstatic.com/whitepapers/DevOps/Jenkins_on_AWS.pdf
By storing the jenkins configuration in an EFS volume we are able to kill and start the jenkins server as we wish without loosing the configuration and the plugins that we installed, and without loosing the job builds and their history. We are also able to put the jenkins server in an auto scaling group ( with a max of 1 instance to make sure that we have only 1 Jenkins master). This makes the jenkins Master Highly available.

* jenkins-network.yml  defines the network infrastructure
  * VPC
  * 2 public and 2 private subnets
  * Nat and internet gateway
  * routing tables

* jenkins-servers.yml defines the servers
  * Jenkins servers defined by:
    * Launch configuration
    * auto scaling group
    * security group
  * Mount targets to be able to mount an EFS volume

* playbook_configure_jenkins_master.yml
  * Ansible playbook that defines the steps to configure the Jenkins master:
    * installing dependencies
    * installing Jenkins
    * starting the jenkins server


## How to use:

1. Create an empty EFS volume from the AWS console and note its ID
2. put the Ansible playbook in an S3 bucket
   1. this Bucket will be used by the cloudformation script to setup the jenkins server
   2. So an IAM role is needed to allow access to this S3 Bucket
   3. *TODO:* the S3 bucket name should be given as a parameter
3. Create the jenkins-network.yml stack
4. Pass the EFS volume ID as a parameter and create the jenkins-servers.yml stack.
5. access the Jenkins UI via the public dns name of the jenkins server
   1. *TODO:* create a load balancer and provide its public URL as an output to access the Jenkins UI
6. Configure jenkins through its UI and start using it normally, the configuration will be saved and persisted in the EFS volume.



TODO: make buckups of the EFS volume ( backup of the jenkins configuration)
TODO: Add Jenkins slaves and remove the executers from the jenkins master


## Notes

### Setup of AWS credentials in Jenkins

**NOTE:** make sure to check the aws credentials setup in jenkins specially extra spaces that might have been added by mistake during copy/paste

* use the plugin [<https://wiki.jenkins.io/display/JENKINS/CloudBees+AWS+Credentials+Plugin>] to add support for aws credentials in jenkins
* add aws credentials as global credentials in Jenkins:
  * Credentials > System > Global credentials (unrestricted) > Add Credentials   then select kind `AWS credentials` and enter the acces key and the secret
* use the plugin [<https://jenkins.io/doc/pipeline/steps/credentials-binding/>] to use the credentials in pipelines

  ```groovy
  node {

    stage("setup Cluster"){

      withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'AWS-CREDENTIALS', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
          sh """

          aws sts get-caller-identity

          kubectl get nodes

          kubectl get pods
          """
      }
    }
  }
  ```
