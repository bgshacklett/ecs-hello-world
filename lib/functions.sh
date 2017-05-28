get_aws_ecr_uri()
{
  local -r AWS_ACCOUNT_ID=$1
  local -r AWS_ECR_REPO_REGION=$2
  local -r AWS_ECR_REPO_NAME=$3
  local -r DOCKER_IMG_TAG=$4

  local aws_ecr_endpoint
  aws_ecr_endpoint="$AWS_ACCOUNT_ID"
  aws_ecr_endpoint="$aws_ecr_endpoint.dkr.ecr"
  aws_ecr_endpoint="$aws_ecr_endpoint.$AWS_ECR_REPO_REGION"
  aws_ecr_endpoint="$aws_ecr_endpoint.amazonaws.com"

  echo "$aws_ecr_endpoint/$AWS_ECR_REPO_NAME:$DOCKER_IMG_TAG"
  return 0
}

get_environment()
{
  readonly GIT_BRANCH=$1

  local environments=("prod" "staging" "qa" "dev" "test")

  if [[ "${GIT_BRANCH}" == "master" ]]; then
    echo "prod"
    return 0
  fi

  if [[ " ${environments[@]} " =~ " ${GIT_BRANCH} " ]]; then
    echo "${GIT_BRANCH}"
    return 0
  fi

  echo "dev"
  return 0
}
