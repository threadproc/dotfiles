#!/usr/bin/env python3
import os
import sys
import subprocess


profile_name = os.getenv('AWS_PROFILE', 'default').strip()
if len(profile_name) == 0:
    profile_name = "default"
cache_file = os.path.expanduser("~/.cache/aws-regions-" + profile_name + "-cached")

if os.path.exists(cache_file):
    with open(cache_file, 'r') as fh:
        print(fh.read())
    sys.exit(0)

# TODO: check if the file is too old

try:
    cmd = subprocess.run(["aws", "ec2", "describe-regions", "--query", "Regions[*].RegionName", "--output", "text"], capture_output=True)

    if cmd.returncode != 0:
        sys.exit(1)

    out = cmd.stdout.strip().decode().replace('\t', ' ')
    
    with open(cache_file, 'w') as fh:
        fh.write(out)
    
    print(out)

except subprocess.CalledProcessError:
    sys.exit(1)