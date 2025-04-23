from google.protobuf.json_format import MessageToDict
import sys
import os
import json


from shared import log_attributes_pb2

attrs = log_attributes_pb2.LogAttributes(
    job_id="abc-123",
    work_unit_type="playbook",
    org_id="redhat",
    controller_id="controller-01",
    username="arestle"
)

# Automatic camelCase conversion
structured_log = MessageToDict(attrs, preserving_proto_field_name=False)

print(json.dumps(structured_log))
