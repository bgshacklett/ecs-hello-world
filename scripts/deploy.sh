#! /usr/bin/env bash
DEBUG=1
set -x

main()
{
  # Transform long options to short ones
  for arg in "$@"; do
    shift
    case "$arg" in
      "--help")        set -- "$@" "-h" ;;
      "--environment") set -- "$@" "-e" ;;
      "--region")      set -- "$@" "-r" ;;
      "--tag")         set -- "$@" "-t" ;;
      *)               set -- "$@" "$arg"
    esac
  done

  debug $@

  while getopts "he:r:t:" opt; do
    case $opt in
      h)
        debug "Usage details requested."
        usage
        exit $?
        ;;
      e)
        local -r ENVIRONMENT="${OPTARG}"
        debug "Environment: ${ENVIRONMENT}"
        ;;
      r)
        local -r REGION="${OPTARG}"
        debug "REGION: ${REGION}"
        ;;
      t)
        local -r TAG="${OPTARG}"
        debug "TAG: ${TAG}"
        ;;
      *)
        debug "Unknown option; exiting with usage details and an error."
        usage
        exit 2
        ;;
    esac
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

#
# debug( msg )
#  - Prints standard debug message to stderr
#  - Only print if debugging is enabled
#
debug() {
  if [ "$DEBUG" -ne 1 ]
  then
    return
  fi
  echo $(date +%T) " $@" > /dev/stderr
}

main $@
