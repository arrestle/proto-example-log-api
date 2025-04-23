package main

import (
	"fmt"
	"log"

	"google.golang.org/protobuf/encoding/protojson"

	"github.com/ansible/log-schema/gen/go/sharedpb"
)

func main() {
	// Create a new LogAttributes instance
	attrs := &sharedpb.LogAttributes{
		JobId:         "abc-123",
		WorkUnitType:  "playbook",
		OrgId:         "redhat",
		ControllerId:  "controller-01",
		Username:      "arestle",
	}

	// Convert to JSON (for readable logs)
	// note that Go converts to camelCase idiom while Python does not.
	jsonBytes, err := protojson.Marshal(attrs)
	if err != nil {
		log.Fatalf("failed to marshal to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))
}

