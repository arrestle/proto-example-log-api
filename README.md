# Structured Logging Across Languages with Protobuf and OpenTelemetry

This repo demonstrates a simple, dependency-light approach for sharing a `.proto` file that combines OpenTelemetry and Ansible-specific fields across Python and Go. It generates language-specific structs for structured (JSON) logging using standard `protoc` tooling.

**Note:** This is a proof of concept. Logs are emitted as JSON (not binary OTLP), and no additional Python libraries are required.

## Proof of Concept Scope

- Uses native `protoc` with no extra dependencies
- Generates Go and Python structs from a shared schema
- Emits JSON logs for simplicity and inspection
- Aligns with OpenTelemetry, extensible for Ansible use cases

## Examples

- [`example/go/main.go`](example/go/main.go): Minimal Go program using the generated struct
- [`example/py/main.py`](example/py/main.py): Minimal Python program using the generated class


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
## Demo

![Terminal demo of log-schema usage](demo.gif)

## Future Work

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
- For structured logging we can simply generate the go and python equivalents and check into github, later versions can be generated using pipelines to always regenerate when a PR is merged.

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

