package main

import (
	"context"
	"fmt"
	"log"

	"google.golang.org/protobuf/encoding/protojson"

	"example.com/protohelper"
	gatewaypb "github.com/ansible/log-schema/gen/go/gatewaypb"
)

func main() {
	ctx := context.Background()

	// Display REST endpoints from proto annotations
	protohelper.PrintRESTEndpoints(gatewaypb.File_shared_gateway_user_api_proto)

	// Example 1: Create a User
	newUser := &gatewaypb.User{
		Id:          1,
		Username:    "alice",
		Email:       "alice@example.com",
		FirstName:   "Alice",
		LastName:    "Smith",
		IsSuperuser: false,
		Created:     "2025-10-29T10:00:00Z",
		Modified:    "2025-10-29T10:00:00Z",
	}

	fmt.Println("=== Example: User Message ===")
	jsonBytes, err := protojson.Marshal(newUser)
	if err != nil {
		log.Fatalf("failed to marshal user to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Example 2: List Users Request
	listRequest := &gatewaypb.ListUsersRequest{
		Page:     1,
		PageSize: 25,
		Search:   "alice",
	}

	fmt.Println("\n=== Example: ListUsers Request ===")
	jsonBytes, err = protojson.Marshal(listRequest)
	if err != nil {
		log.Fatalf("failed to marshal request to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Example 3: List Users Response
	listResponse := &gatewaypb.ListUsersResponse{
		Count:    1,
		Next:     "",
		Previous: "",
		Results: []*gatewaypb.User{
			newUser,
		},
	}

	fmt.Println("\n=== Example: ListUsers Response ===")
	jsonBytes, err = protojson.Marshal(listResponse)
	if err != nil {
		log.Fatalf("failed to marshal response to JSON: %v", err)
	}
	fmt.Println(string(jsonBytes))

	// Demonstrate the type safety
	fmt.Println("\n=== Type Safety Demo ===")
	fmt.Printf("User ID: %d (type: int32)\n", newUser.Id)
	fmt.Printf("Username: %s (type: string)\n", newUser.Username)
	fmt.Printf("Is Superuser: %t (type: bool)\n", newUser.IsSuperuser)

	_ = ctx // satisfy linter
}
