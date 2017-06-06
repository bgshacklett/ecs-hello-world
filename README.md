# ECS Hello World
A starting Point for CI/CD with ECS and Travis-CI

## Summary

This repository is designed to demonstrate a CI/CD workflow with Docker and the AWS EC2 Container Service. Its goals include:

* The use of the Amazon EC2 Container Registry for the storage of images
* Automated publishing of successful builds to ECR
* Secure storage of secrets
* A Blue/Green or Immutable Infrastructure deployment methodology
* Minimal human intervention for deployments to ECS

## Setup

_Note: These instructions are designed for public repositories. If you decide to keep your project in a private repository, you will need to use travis-ci.com and some of the steps below may differ slightly._

### Requirements
* An IAM User—to be used by Travis-CI for Interaction with AWS Services
* An Access Key ID and Secret Access Key for this IAM User
* An EC2 Instance Role—to be used by the ECS Cluster instances
* An ECR Repository—to serve as a target for the ECS Service
* An ECS Cluster—to serve as a target for the ECS Service
* A CloudWatch Log Group—to accept log data from the ECS container

### Process
Begin by ensuring that all of the above requirements are met. Sample IAM policies are available in `lib/iam/`. Once the necessary resources have been created, you can proceed with forking the repository. Alternatively, you can manually clone it and push it to an unlinked repository in your GitHub account.

#### Configure Travis-CI to build the repository:
Travis-CI is not active on new repositories by default. It will need to be enabled for this repository before it will process builds.
  1. Navigate to https://www.travis-ci.org
  1. If you're not already logged in, click the Sign Up button.
  1. Click the Plus sign next to the My Repositories link in the navigation pane on the left side of the screen.
  1. Find your clone of the repository in the list.
  1. Ensure that builds are enabled for the repository.

#### Configure the Build Settings for the repository:
There are some basic configuration settings which will tell Travis-CI when builds should be processed. Also, secrets are stored as environment variables which will need to be configured in the Travis-CI control panel. Travis-CI is also capable of reading encrypted secrets from the .travis.yml file, but this is out of the scope of this project. Please see https://docs.travis-ci.com/user/encryption-keys/ for further details on this feature.

  1. Navigate to the repository in Travis-CI.
  1. Click the More Options menu, then select the Settings menu item.
  1. Choose your preferred options under the General and Auto Cancellation headings. These options are dependent on your desired workflow, so you will want to ensure that you configure them to your requirements. This project was originally created with the following settings:
    * Build Only if .travis.yml is Present—On
    * Limit Concurrent Jobs—Off
    * Build Branch Updates—On
    * Build Pull Request Updates—On
    * Auto Cancel Branch Builds—Off
    * Auto Cancel Pull Request Builds—Off
  1. Configure the following Environment Variables, leaving the Display Value in Build Log slider in the Off position:
    * AWS\_ACCESS\_KEY\_ID—The Access Key ID of the IAM User that Travis will Log In as.
    * AWS\_SECRET\_ACCESS\_KEY—The Secret Access Key for the IAM user
    * AWS\_ECR\_REPO\_NAME—The name of the ECR Repository
    * AWS\_ECR\_REPO\_REGION—The Region of your ECR Repository
    * AWS\_ECS\_CLUSTER—The Name of the ECS Cluster which the ECS Service will target for Production deployments
    * AWS\_ECS\_CLUSTER\_DEV—The Name of ECS Cluster wich the ECS Service will target forr Development deployments
    * AWS\_ECS\_REGION—The region which your ECS resources will reside in
