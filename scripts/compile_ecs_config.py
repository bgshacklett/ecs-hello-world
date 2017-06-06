#!/usr/bin/env python3

import argparse
import json
import re
import os

#
# Message Formats
#
FMT_DESCRIPTION = """Generates a deployable ECS Task Definition from a base
                 JSON file"""

FMT_HELP_IMG_URI = "The URI of the image which will be deployed"
FMT_HELP_ENV = "The environment that we're building for"

FMT_HELP_INPUT_SERVICE = """The Path to a base JSON service file which will
                         be updated to reflect the values necessary for
                         deployment"""

FMT_HELP_INPUT_TASKDEF = """The Path to a base JSON task definition file which
                         will be updated to reflect the values necessary for
                         deployment"""

FMT_HELP_OUTPUT_FILE = """The path at which to output the final JSON task
                       definition file"""

FMT_SERVICE_NAME = "%s-%s"

#
# Argument Parsing
#
parser = argparse.ArgumentParser(description=FMT_DESCRIPTION)
parser.add_argument('-e', '--environment',
                    default='prod',
                    choices=['prod', 'staging', 'qa', 'dev', 'test'],
                    dest='env',
                    help=FMT_HELP_ENV)
parser.add_argument('-u', '--image-uri',
                    dest='image_uri',
                    help=FMT_HELP_IMG_URI)
parser.add_argument('-s', '--service-json',
                    dest='service_json',
                    help=FMT_HELP_INPUT_SERVICE)
parser.add_argument('-t', '--task-definition-json',
                    dest='task_definition_json',
                    help=FMT_HELP_INPUT_TASKDEF)
parser.add_argument('-o', '--output-directory',
                    dest='output_directory',
                    help=FMT_HELP_OUTPUT_FILE)

args = parser.parse_args()

#
# Main logic
#
# Constants
ENV = args.env
IMAGE_URI = args.image_uri
SERVICE_JSON = args.service_json
TASK_DEFINITION_JSON = args.task_definition_json
OUTPUT_DIRECTORY = args.output_directory

TAG = str.split(IMAGE_URI, ':')[-1]
_, TASK_DEF_JSON_NAME = os.path.split(TASK_DEFINITION_JSON)
_, SERVICE_JSON_NAME = os.path.split(SERVICE_JSON)
TASK_DEF_OUT = os.path.join(OUTPUT_DIRECTORY, TASK_DEF_JSON_NAME)
SERVICE_OUT = os.path.join(OUTPUT_DIRECTORY, SERVICE_JSON_NAME)


# Open the generalized config files
with open(TASK_DEFINITION_JSON, 'r') as json_data:
    task_def = json.load(json_data)

with open(SERVICE_JSON, 'r') as json_data:
    service = json.load(json_data)


# Set the image path in the task definition
for i in range(len(task_def['containerDefinitions'])):
    task_def['containerDefinitions'][i]['image'] = IMAGE_URI
    (task_def['containerDefinitions'][i]
             ['logConfiguration']
             ['options']
             ['awslogs-stream-prefix']) = ENV


# Configure the Service with a Name and Task Definition
# We do this in the build step due to dependencies on the Task Definition
# TODO Account for a bad existing service name in the base service json.
service_name = re.sub('[^a-zA-Z0-9\-_]',
                      '-',
                      (FMT_SERVICE_NAME % (service['serviceName'], TAG)))

task_definition_name = task_def['family']

service['serviceName'] = service_name
service['taskDefinition'] = task_definition_name


# Export the finalized configuration files.
with open(TASK_DEF_OUT, 'w') as outfile:
    json.dump(task_def, outfile)

with open(SERVICE_OUT, 'w') as outfile:
    json.dump(service, outfile)
