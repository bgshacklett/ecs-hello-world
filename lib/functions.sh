get_aws_ecr_uri()
{
  _AWS_ACCOUNT_ID=$1
  _AWS_ECR_REPO_REGION=$2
  _AWS_ECR_REPO_NAME=$3
  _DOCKER_IMG_TAG=$4

  aws_ecr_endpoint="$_AWS_ACCOUNT_ID"
  aws_ecr_endpoint="$aws_ecr_endpoint.dkr.ecr"
  aws_ecr_endpoint="$aws_ecr_endpoint.$_AWS_ECR_REPO_REGION"
  aws_ecr_endpoint="$aws_ecr_endpoint.amazonaws.com"

  echo "$aws_ecr_endpoint/$_AWS_ECR_REPO_NAME:$_DOCKER_IMG_TAG"
}
