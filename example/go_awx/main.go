package main

import (
	"context"
	"fmt"
	"log"

	"google.golang.org/protobuf/encoding/protojson"

	awxpb "github.com/ansible/proto-example-log-api/gen/go/awxpb"
)

func main() {
	ctx := context.Background()

	// Example 1: Job Template
	jobTemplate := &awxpb.JobTemplate{
		Id:             7,
		Name:           "Deploy Web Servers",
		Description:    "Deploys Apache web servers to production",
		JobType:        "run",
		ProjectId:      5,
		InventoryId:    3,
		Playbook:       "site.yml",
		OrganizationId: 1,
		Status:         "successful",
		Created:        "2025-01-15T10:00:00Z",
		Modified:       "2025-10-29T14:30:00Z",
		Verbosity:      0,
		Forks:          0,
		Timeout:        0,
		Limit:          "webservers",
		BecomeEnabled:  false,
		DiffMode:       false,
	}

	fmt.Println("=== Example: Job Template ===")
	jsonBytes, err := protojson.Marshal(jobTemplate)
	if err != nil {
		log.Fatalf("failed to marshal job template to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Example 2: Launch Job Template Request
	launchRequest := &awxpb.LaunchJobTemplateRequest{
		Id:        7,
		Limit:     "webservers:&production",
		ExtraVars: `{"env": "production", "debug": false}`,
		Tags:      "deploy,configure",
		SkipTags:  "backup",
	}

	fmt.Println("\n=== Example: Launch Job Template Request ===")
	jsonBytes, err = protojson.Marshal(launchRequest)
	if err != nil {
		log.Fatalf("failed to marshal launch request to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Example 3: Created Job (result of launch)
	job := &awxpb.Job{
		Id:             42,
		Name:           "Deploy Web Servers",
		Status:         "pending",
		JobTemplateId:  7,
		Created:        "2025-11-11T14:00:00Z",
		Started:        "",
		Finished:       "",
		StdoutUrl:      "/api/v2/jobs/42/stdout/",
	}

	fmt.Println("\n=== Example: Created Job (Pending Execution) ===")
	jsonBytes, err = protojson.Marshal(job)
	if err != nil {
		log.Fatalf("failed to marshal job to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Example 4: List Job Templates Request
	listRequest := &awxpb.ListJobTemplatesRequest{
		Page:           1,
		PageSize:       25,
		Search:         "web",
		OrganizationId: 1,
		OrderBy:        "-created",
	}

	fmt.Println("\n=== Example: List Job Templates Request ===")
	jsonBytes, err = protojson.Marshal(listRequest)
	if err != nil {
		log.Fatalf("failed to marshal list request to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Type safety demonstration
	fmt.Println("\n=== Type Safety Demo ===")
	fmt.Printf("Job Template ID: %d (type: int32)\n", jobTemplate.Id)
	fmt.Printf("Playbook: %s (type: string)\n", jobTemplate.Playbook)
	fmt.Printf("Job Status: %s (type: string)\n", job.Status)
	fmt.Printf("Launch will create job ID: %d\n", job.Id)

	_ = ctx // satisfy linter
}

