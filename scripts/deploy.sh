#! /usr/bin/env bash

main()
{
  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
        -e|--environment)
        local -r ENVIRONMENT="$2"
        shift # past argument
        ;;
        -r|--region)
        local -r REGION="$2"
        shift # past argument
        ;;
        -t|--tag)
        local -r TAG="$2"
        shift # past argument
        ;;
        -h|--help)
        usage
        exit $?
        ;;
        *)
        usage        # unknown option
        exit 1
        ;;
    esac
    shift # past argument or value
  done

  # Set the path to the build file
  local -r AWS_ECS_TASK_DEFINITION="./build/task-definition.json"

  # Register the Task Definition
  aws ecs register-task-definition \
          --cli-input-json file://"${AWS_ECS_TASK_DEFINITION}" \
            || die "Task Definition Could Not be Registerd"
}

usage()
{
  echo "Usage: deploy.sh (-r|--region) <AWS ECS Region> (-e|--environment) <environment> (-t|--tag) <git tag>"
  return 0
}


die()
{
  local message=$1
  [ -z "$message" ] && message="Died"
  echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message." >&2
  exit 1
}


main $@
