module github.com/ansible/log-schema/example

go 1.22.7

require (
	github.com/ansible/log-schema/gen/go/sharedpb v0.0.0-00010101000000-000000000000
	google.golang.org/protobuf v1.36.6
)

replace github.com/ansible/log-schema/gen/go/sharedpb => ../../gen/go/github.com/ansible/log-schema/gen/go/sharedpb
