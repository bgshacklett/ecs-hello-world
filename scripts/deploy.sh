#! /usr/bin/env bash

main()
{
  while [[ $# -gt 1 ]]
  do
    key="$1"

    case $key in
        -e|--environment)
        ENVIRONMENT="$2"
        shift # past argument
        ;;
        -t|--tag)
        TAG="$2"
        shift # past argument
        ;;
        -h|--help)
        usage
        ;;
        *)
        usage        # unknown option
        ;;
    esac
    shift # past argument or value
  done

  local -r AWS_ECS_TASK_DEFINITION="./build/task-definition.json"


  # Register the Task Definition
  aws ecs register-task-definition \
          --cli-input-json file://"${AWS_ECS_TASK_DEFINITION}" \
            || die "Task Definition Could Not be Registerd"
}

usage()
{
  echo "Usage: deploy.sh (-e|--environment) <environment> (-t|--tag) <git tag>"
}


die()
{
  local message=$1
  [ -z "$message" ] && message="Died"
  echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message." >&2
  exit 1
}


main $@
