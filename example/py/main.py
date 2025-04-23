import sys
import os
import json

# Add generated code path
sys.path.insert(0, os.path.abspath("../../gen/python"))

from shared import log_attributes_pb2

# Construct the LogAttributes message
# Python uses snake_case for variable names
attrs = log_attributes_pb2.LogAttributes(
    job_id="abc-123",
    work_unit_type="playbook",
    org_id="redhat",
    controller_id="controller-01",
    username="arestle"
)

# Convert to camelCase for public-facing logs and interfaces
#   * Decision point: Do we want to use camelCase or snake_case?
structured_log = {
    "jobId": attrs.job_id,
    "workUnitType": attrs.work_unit_type,
    "orgId": attrs.org_id,
    "controllerId": attrs.controller_id,
    "username": attrs.username,
}

print(json.dumps(structured_log))
