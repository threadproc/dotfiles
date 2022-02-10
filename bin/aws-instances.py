#!/usr/bin/env python3
import os
import sys
import subprocess
import time


profile_name = os.getenv('AWS_PROFILE', 'default').strip()
if len(profile_name) == 0:
    profile_name = "default"

region = subprocess.run(["aws", "configure", "get", "region"], capture_output=True).stdout.decode().strip()
def_region = os.getenv("AWS_DEFAULT_REGION", region)
if len(def_region) > 0 and def_region != region:
    region = def_region
override_region = os.getenv("AWS_REGION", region)
if len(override_region) > 0 and override_region != region:
    region = override_region

cache_file = os.path.expanduser("~/.cache/aws-instances-" + profile_name + "-" + region)

# cache these results for 30 minutes (30*60 seconds)
if os.path.exists(cache_file) and os.path.getmtime(cache_file) > time.time() - (30 * 60):
    # use the cache file
    with open(cache_file, 'r') as fh:
        print(fh.read())
    sys.exit(0)

try:
    cmd = subprocess.run(["aws", "ec2", "describe-instances", "--query", "Reservations[*].Instances[*].{Name:Tags[?Key=='Name']|[0].Value}", "--output", "text"], capture_output=True)
    if cmd.returncode != 0:
        sys.exit(cmd.returncode)
    
    out = cmd.stdout.strip().decode().replace('\n', ' ')

    with open(cache_file, 'w') as fh:
        fh.write(out)
    
    print(out)
except subprocess.CalledProcessError:
    sys.exit(1)