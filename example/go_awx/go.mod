module github.com/ansible/proto-example-log-api/example

go 1.24.6

require (
	github.com/ansible/proto-example-log-api/gen/go/awxpb v0.0.0-00010101000000-000000000000
	google.golang.org/protobuf v1.36.10
)

require (
	golang.org/x/net v0.42.0 // indirect
	golang.org/x/sys v0.34.0 // indirect
	golang.org/x/text v0.27.0 // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20250804133106-a7a43d27e69b // indirect
	google.golang.org/grpc v1.76.0 // indirect
)

replace github.com/ansible/proto-example-log-api/gen/go/awxpb => ../../gen/go/github.com/ansible/proto-example-log-api/gen/go/awxpb

