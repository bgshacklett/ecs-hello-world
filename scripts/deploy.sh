#! /usr/bin/env bash
readonly DEBUG=0

main()
{
  # Transform long options to short ones
  for arg in "$@"; do
    shift
    case "${arg}" in
      "--help")          set -- "$@" "-h" ;;
      "--cluster-name")  set -- "$@" "-c" ;;
      "--environment")   set -- "$@" "-e" ;;
      "--region")        set -- "$@" "-r" ;;
      "--tag")           set -- "$@" "-t" ;;
      "--"*)             usage ${arg}; exit 2;;
      *)                 set -- "$@" "$arg"
    esac
  done

  # Output all arguments if debug is enabled
  debug "Arguments: $@"

  # Pass the transformed args to getopts
  while getopts "hc:e:r:t:" opt; do
    case $opt in
      h)
        debug "Usage details requested."
        usage
        exit $?
        ;;
      c)
        local -r CLUSTER_NAME="${OPTARG}"
        debug "Cluster: ${CLUSTER_NAME}"
        ;;
      e)
        local -r ENVIRONMENT="${OPTARG}"
        debug "Environment: ${ENVIRONMENT}"
        ;;
      r)
        local -r REGION="${OPTARG}"
        debug "Region: ${REGION}"
        ;;
      t)
        local -r TAG="${OPTARG}"
        debug "Tag: ${TAG}"
        ;;
      *)
        debug "Unknown option; exiting with usage details and an error."
        usage
        exit 2
        ;;
    esac
  done


  # Set the path to the build files
  local -r AWS_ECS_TASK_DEFINITION_CONFIG="./build/task-definition.json"
  local -r AWS_ECS_SERVICE_CONFIG="./build/service.json"


  # Register the Task Definition and grab the result.
  aws ecs register-task-definition \
          --region "${REGION}" \
          --cli-input-json file://"${AWS_ECS_TASK_DEFINITION_CONFIG}" \

  [[ $? -eq 0 ]] || die "Task Definition could not be registered"


  # Create a new Service using this task definition
  aws ecs create-service \
          --region "${REGION}" \
          --cluster "${CLUSTER_NAME}" \
          --cli-input-json file://"${AWS_ECS_SERVICE_CONFIG}"

  [[ $? -eq 0 ]] || die "Could not create service on cluster ${CLUSTER_NAME}"
}


# usage( option )
#  - Prints standard usage message to stdout
#
usage()
{
  local -r OPTION=$1

  echo "Invalid option: \"${OPTION}\""
  echo "Usage: deploy.sh (-r|--region) <AWS ECS Region> (-e|--environment) <environment> (-t|--tag) <git tag>"
  return 0
}


# die( msg )
#  - Prints standard debug message to stderr
#  - Exits >0
#
die()
{
  local message=$1
  [ -z "$message" ] && message="Died"
  echo "${BASH_SOURCE[1]}: line ${BASH_LINENO[0]}: ${FUNCNAME[1]}: $message." >&2
  exit 1
}


# debug( msg )
#  - Prints standard debug message to stderr
#  - Only print if debugging is enabled
#
debug()
{
  if [ "$DEBUG" -ne 1 ]
  then
    return
  fi
  echo $(date +%T) " $@" > /dev/stderr
}

main $@
