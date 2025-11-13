package protohelper

import (
	"fmt"

	"google.golang.org/protobuf/proto"
	"google.golang.org/protobuf/reflect/protoreflect"
	descriptorpb "google.golang.org/protobuf/types/descriptorpb"
	annotations "google.golang.org/genproto/googleapis/api/annotations"
)

// PrintRESTEndpoints extracts and displays REST endpoint mappings from a proto file descriptor
func PrintRESTEndpoints(fileDesc protoreflect.FileDescriptor) {
	services := fileDesc.Services()

	fmt.Println("=== REST Endpoint Mapping ===")
	fmt.Println("From proto google.api.http annotations:")

	for i := 0; i < services.Len(); i++ {
		service := services.Get(i)
		methods := service.Methods()

		for j := 0; j < methods.Len(); j++ {
			method := methods.Get(j)
			opts := method.Options().(*descriptorpb.MethodOptions)

			if proto.HasExtension(opts, annotations.E_Http) {
				httpRule := proto.GetExtension(opts, annotations.E_Http).(*annotations.HttpRule)

				methodName := string(method.Name())

				switch pattern := httpRule.Pattern.(type) {
				case *annotations.HttpRule_Get:
					fmt.Printf("  GET    %-40s → %s\n", pattern.Get, methodName)
				case *annotations.HttpRule_Post:
					fmt.Printf("  POST   %-40s → %s\n", pattern.Post, methodName)
				case *annotations.HttpRule_Put:
					fmt.Printf("  PUT    %-40s → %s\n", pattern.Put, methodName)
				case *annotations.HttpRule_Delete:
					fmt.Printf("  DELETE %-40s → %s\n", pattern.Delete, methodName)
				case *annotations.HttpRule_Patch:
					fmt.Printf("  PATCH  %-40s → %s\n", pattern.Patch, methodName)
				}
			}
		}
	}
	fmt.Println()
}

