package main

import (
    "fmt"
    "log"
    "time"

    "google.golang.org/protobuf/encoding/protojson"

    commonpb "go.opentelemetry.io/proto/otlp/common/v1"
    logspb "go.opentelemetry.io/proto/otlp/logs/v1"
    respb "go.opentelemetry.io/proto/otlp/resource/v1"

    sharedpb "github.com/ansible/log-schema/gen/go/sharedpb"
)

// toKeyValues converts our shared.LogAttributes message into the
// OTLP KeyValue slice required by LogRecord.Attributes.
func toKeyValues(attrs *sharedpb.LogAttributes) []*commonpb.KeyValue {
    if attrs == nil {
        return nil
    }
    return []*commonpb.KeyValue{
        {Key: "job_id", Value: &commonpb.AnyValue{Value: &commonpb.AnyValue_StringValue{StringValue: attrs.GetJobId()}}},
        {Key: "work_unit_type", Value: &commonpb.AnyValue{Value: &commonpb.AnyValue_StringValue{StringValue: attrs.GetWorkUnitType()}}},
        {Key: "org_id", Value: &commonpb.AnyValue{Value: &commonpb.AnyValue_StringValue{StringValue: attrs.GetOrgId()}}},
        {Key: "controller_id", Value: &commonpb.AnyValue{Value: &commonpb.AnyValue_StringValue{StringValue: attrs.GetControllerId()}}},
        {Key: "username", Value: &commonpb.AnyValue{Value: &commonpb.AnyValue_StringValue{StringValue: attrs.GetUsername()}}},
    }
}

func main() {
    // 1.  Create the canonical set of structured attributes once.
    logAttrs := &sharedpb.LogAttributes{
        JobId:        "abc-123",
        WorkUnitType: "playbook",
        OrgId:        "redhat",
        ControllerId: "controller-01",
        Username:     "arestle",
    }

    // 2.  Wrap them into an OTLP LogRecord.
    lr := &logspb.LogRecord{
        TimeUnixNano:  uint64(time.Now().UnixNano()),
        SeverityNumber: logspb.SeverityNumber_SEVERITY_NUMBER_INFO,
        SeverityText:  "INFO",
        Body: &commonpb.AnyValue{Value: &commonpb.AnyValue_StringValue{StringValue: "controller started"}},
        Attributes: toKeyValues(logAttrs),
    }

    // 3. Stitch together the full LogsData envelope.
    scopeLogs := &logspb.ScopeLogs{LogRecords: []*logspb.LogRecord{lr}}
    resLogs := &logspb.ResourceLogs{
        Resource:  &respb.Resource{},
        ScopeLogs: []*logspb.ScopeLogs{scopeLogs},
    }
    data := &logspb.LogsData{ResourceLogs: []*logspb.ResourceLogs{resLogs}}

    // 4. Marshal to JSON for human‑readable output.
    marshaler := protojson.MarshalOptions{Multiline: true, EmitUnpopulated: true}
    out, err := marshaler.Marshal(data)
    if err != nil {
        log.Fatalf("failed to marshal: %v", err)
    }
    fmt.Println(string(out))
}
