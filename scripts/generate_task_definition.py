#!/usr/bin/env python3

import argparse
import json

#
# Message Formats
#
fmtDescription = """Generates a deployable ECS Task Definition from a base
                 JSON file"""

fmtHelpTag = "The Tag of the Image Which Will Be Deployed"

fmtHelpInputFile = """The Path to a base JSON task definition file which will
                      be updated to reflect the values necessary for
                      deployment"""

fmtHelpOutputFile = """The path at which to output the final JSON task
                    definition file"""

#
# Argument Parsing
#
parser = argparse.ArgumentParser(description=fmtDescription)
parser.add_argument('-e', '--environment',
                    default='prod',
                    choices=['prod', 'staging', 'qa', 'dev', 'test'],
                    dest='env',
                    help=fmtHelpTag)
parser.add_argument('-u', '--image-uri',
                    default='latest',
                    dest='image_uri',
                    help=fmtHelpTag)
parser.add_argument('-i', '--input-file',
                    dest='input_file',
                    help=fmtHelpInputFile)
parser.add_argument('-o', '--output-file',
                    dest='output_file',
                    help=fmtHelpOutputFile)

args = parser.parse_args()

#
# Main logic
#
with open(args.input_file, 'r') as json_data:
    task_def = json.load(json_data)

# Append the tag to the image in each task definition.
# TODO Account for and fix bad image names in the base task definition.
for i in range(len(task_def['containerDefinitions'])):
    task_def['containerDefinitions'][i]['image'] = args.image_uri
    (task_def['containerDefinitions'][i]
             ['logConfiguration']
             ['options']
             ['awslogs-stream-prefix']) = args.env

# Export the new task definition JSON data.
with open(args.output_file, 'w') as outfile:
    json.dump(task_def, outfile)
