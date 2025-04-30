# Structured Logging Across Languages with Protobuf

This repo demonstrates a simple, dependency-light approach for sharing a `.proto` file that combines OpenTelemetry and Ansible-specific fields across Python and Go. It generates language-specific structs for structured (JSON) logging using standard `protoc` tooling.

## Why are we doing this? Why do you care?

We agree that OTEL implementation is slotted for phase 2. We propose the use of Protobuf in phase 1 to allow us to generate identical JSON structures in both Python and Go as demonstrated in this repo.

Protobuf generated data structures allow us to implement JSON structured logging now, and clarify the path forward to OTEL tracing in phase 2. We will also have the opportunity to socialize Protobuf with less complex .proto files before we tackle OTEL implementation.


**Note:** This is a minimal proof of concept. Logs are serialized as JSON rather than binary OTLP, and utilize only standard Python and Go libraries.

## Proof of Concept Scope
* Utilizes native protoc tooling without introducing extra dependencies, ensuring easy adoption across projects.

* Automatic generation of Go and Python structs from a shared Protobuf schema to promote consistency and maintainability.

* Emits structured JSON logs for immediate usability, with a clear migration path toward binary OTLP formats.

* Establishes alignment with OpenTelemetry standards, creating a foundation for future Ansible-specific extensions and end-to-end distributed tracing.

## Examples

- [`example/go/main.go`](example/go/main.go): Minimal Go program using the generated struct
- [`example/go_otlp/main.go`](example/go_otlp/main.go): OTLP Compliant Logging with embedded ansible-specific attributes.
- [`example/py/main.py`](example/py/main.py): Minimal Python program using the generated class
- [`example/py_google/main.py`](example/py_google/main.py): Same as above with Google MessageToDict library


## Getting Started / Makefile overview

Use a virtual environments (such as venv and gvm) and the makefile to simplify tooling and demonstrate capabilities 


```bash
python -m venv .venv
source .venv/bin/activate
pip install protobuf
python --version # Python 3.13.2 or similar 

gvm use go1.22.7 --default
export GOBIN=$(go env GOPATH)/bin
go version  # go1.22.7 or similar

# shows available targets to generate and run examples.
make help   
```
## Structured Logging Demo using .proto
Note that every a single .proto file is used to generate both a go struct and a python class which result in the same log format for both languages. The tooling is initially complex to set up, but thereafter easily reproducible.
![Terminal demo of log-schema usage](demo.gif)


## OTLP Demo using same log-schema .proto embedded into LogRecord.
Note that this would normally have resources filled in by the otel collector and be sent to a grafana (or other otel) backend for display correlation and processing. This is not meant to be human readable.
![Terminal demo of otlp LogRecord](demo2.gif)

## Future Work

### Grafana demo with traces

* Demonstrate how Controller and Receptor traces appear in OpenShift  [grafana dashboards](https://github.com/cloud-bulldozer/performance-dashboards/blob/master/dittybopper/README.md).

* Walk through modifying the OpenTelemetry (OTEL) Collector to filter traces by user_id, node_id, and other key fields.

* Showcase how to enrich trace data by adding resource attributes such as ip_address, pod, namespace, host_id, and more.


### Naming Conventions

- Go uses `camelCase`, Python prefers `snake_case`
- See [golang/protobuf#1329](https://github.com/golang/protobuf/issues/1329)
- AAP will need to standardize on field naming strategy across tools

### Dependency Management

- Convert `third_party/opentelemetry-proto` into a Git submodule
- Simplifies maintenance and upstream updates

### Shared Wrappers

- Create lightweight logging wrappers for Go and Python
- Reuse across repos once naming is resolved to promote consistency

### Containerize or other automation
- For structured logging we can simply generate the go and python equivalents and check that into github. 
- Later versions can be generated in pipelines to always regenerate when a PR is merged.

## Background

This repository demonstrates how to share OpenTelemetry-compatible `.proto` files between Go and Python, incorporating Ansible-specific attributes for structured logging use cases. It's designed to be minimal, reproducible, and easy to extend.

## Initial Environment Setup

These steps were used to prepare the repository and local development environment:

```bash
# Clone the OpenTelemetry proto definitions
git clone https://github.com/open-telemetry/opentelemetry-proto.git third_party/opentelemetry-proto

# Clean up unnecessary GitHub-related files
rm -rf third_party/opentelemetry-proto/.github
```

### Bootstrapping Go
```bash
mkdir -p example/go
cd example/go
go mod init github.com/ansible/log-schema/example
go get google.golang.org/protobuf@latest
go mod tidy
```

