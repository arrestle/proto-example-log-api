import sys
import os
import json

# Add generated code path
sys.path.insert(0, os.path.abspath("../../gen/python"))

from shared import awx_job_template_pb2

def main():
    print("=== REST Endpoint Mapping ===")
    print("These proto messages map to REST endpoints via google.api.http annotations:")
    print("  GET    /api/v2/job_templates/{id}        → GetJobTemplate")
    print("  GET    /api/v2/job_templates             → ListJobTemplates")
    print("  POST   /api/v2/job_templates/{id}/launch → LaunchJobTemplate")
    print()

    # Example 1: Job Template
    job_template = awx_job_template_pb2.JobTemplate(
        id=7,
        name="Deploy Web Servers",
        description="Deploys Apache web servers to production",
        job_type="run",
        project_id=5,
        inventory_id=3,
        playbook="site.yml",
        organization_id=1,
        status="successful",
        created="2025-01-15T10:00:00Z",
        modified="2025-10-29T14:30:00Z",
        verbosity=0,
        forks=0,
        timeout=0,
        limit="webservers",
        become_enabled=False,
        diff_mode=False
    )

    print("=== Example: Job Template ===")
    job_template_dict = {
        "id": job_template.id,
        "name": job_template.name,
        "description": job_template.description,
        "jobType": job_template.job_type,
        "projectId": job_template.project_id,
        "inventoryId": job_template.inventory_id,
        "playbook": job_template.playbook,
        "organizationId": job_template.organization_id,
        "status": job_template.status,
        "limit": job_template.limit,
    }
    print(json.dumps(job_template_dict, indent=2))

    # Example 2: Launch Job Template Request
    launch_request = awx_job_template_pb2.LaunchJobTemplateRequest(
        id=7,
        limit="webservers:&production",
        extra_vars='{"env": "production", "debug": false}',
        tags="deploy,configure",
        skip_tags="backup"
    )

    print("\n=== Example: Launch Job Template Request ===")
    launch_dict = {
        "id": launch_request.id,
        "limit": launch_request.limit,
        "extraVars": launch_request.extra_vars,
        "tags": launch_request.tags,
        "skipTags": launch_request.skip_tags,
    }
    print(json.dumps(launch_dict, indent=2))

    # Example 3: Created Job (result of launch)
    job = awx_job_template_pb2.Job(
        id=42,
        name="Deploy Web Servers",
        status="pending",
        job_template_id=7,
        created="2025-11-11T14:00:00Z",
        started="",
        finished="",
        stdout_url="/api/v2/jobs/42/stdout/"
    )

    print("\n=== Example: Created Job (Pending Execution) ===")
    job_dict = {
        "id": job.id,
        "name": job.name,
        "status": job.status,
        "jobTemplateId": job.job_template_id,
        "created": job.created,
        "stdoutUrl": job.stdout_url,
    }
    print(json.dumps(job_dict, indent=2))

    # Type safety demonstration
    print("\n=== Type Safety Demo ===")
    print(f"Job Template ID: {job_template.id} (type: int)")
    print(f"Playbook: {job_template.playbook} (type: str)")
    print(f"Job Status: {job.status} (type: str)")
    print(f"Launch will create job ID: {job.id}")

if __name__ == "__main__":
    main()


