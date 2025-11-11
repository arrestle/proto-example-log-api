# Paths
PROTOC_VERSION = 33.0
PROTOC_DIR = tools/protoc_install
PROTOC_TEMP_BIN = $(PROTOC_DIR)/bin/protoc
TOOLS_DIR = tools
OPENTELEMETRY_DIR = third_party/opentelemetry-proto
SHARED_DIR = shared

LOGS_PROTO = $(OPENTELEMETRY_DIR)/opentelemetry/proto/logs/v1/logs.proto
SHARED_PROTO = $(SHARED_DIR)/log_attributes.proto
GATEWAY_PROTO = $(SHARED_DIR)/gateway_user_api.proto
GATEWAY_AI_PROTO = $(SHARED_DIR)/gateway_user_api_with_ai.proto
AWX_PROTO = $(SHARED_DIR)/awx_job_template.proto

PROTOC_GEN_GO = $(TOOLS_DIR)/bin/protoc-gen-go
PROTOC_GEN_GO_GRPC = $(TOOLS_DIR)/bin/protoc-gen-go-grpc
PROTOC_GEN_OPENAPI = $(TOOLS_DIR)/bin/protoc-gen-openapiv2

.PHONY: all go python clean install-tools clean-tools check-tools

# Build everything
gen-all: check-go-version install-tools check-tools gen-go gen-python gen-gateway gen-awx
run-all: run-go-example run-py-example run-gateway-examples run-awx-examples

# Quick Go version check (run before install-tools)
check-go-version:
	@echo "Verifying Go version..."
	@which go > /dev/null || (echo "❌ ERROR: Go not installed. Install via gvm or system package manager." && exit 1)
	@go version | grep -qE 'go1\.(2[4-9]|[3-9][0-9])\.[6-9]|go1\.2[4-9]\.[0-9]+|go1\.[3-9][0-9]' || \
		(echo "❌ ERROR: Go 1.24.6 or higher required" && \
		 echo "   Current: $$(go version)" && \
		 echo "" && \
		 echo "   Fix with gvm (recommended):" && \
		 echo "     gvm install go1.24.6 -B" && \
		 echo "     gvm use go1.24.6 --default" && \
		 echo "" && \
		 echo "   Or download from: https://go.dev/dl/" && \
		 exit 1)
	@echo "✓ Go version OK: $$(go version | awk '{print $$3}')"

# Install tools in local tools dir
install-tools:

	@echo "Install protoc-gen-go, -grpc, and -openapi"
	GOBIN=$(abspath $(TOOLS_DIR))/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	GOBIN=$(abspath $(TOOLS_DIR))/bin go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
	GOBIN=$(abspath $(TOOLS_DIR))/bin go install github.com/grpc-ecosystem/grpc-gateway/v2/protoc-gen-openapiv2@latest
	pip install --target=$(abspath $(TOOLS_DIR))/python grpcio-tools protobuf 

	@echo "Installing protoc $(PROTOC_VERSION)..."
	mkdir -p $(PROTOC_DIR)
	curl -sSL https://github.com/protocolbuffers/protobuf/releases/download/v$(PROTOC_VERSION)/protoc-$(PROTOC_VERSION)-linux-x86_64.zip -o protoc.zip
	unzip -q -o protoc.zip -d $(PROTOC_DIR)
	rm -f protoc.zip
	chmod +x $(PROTOC_TEMP_BIN)
	mv $(PROTOC_TEMP_BIN) tools/bin/protoc

# Compile for Go
gen-go:
	@echo "🔧 Generating Go code from protos..."
	@mkdir -p gen/go
	@bash -c 'PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH && \
	echo "🧭 PATH is: $$PATH" && \
	protoc -I. -I$(OPENTELEMETRY_DIR) \
		--go_out=gen/go --go_opt=paths=source_relative \
		--go-grpc_out=gen/go --go-grpc_opt=paths=source_relative \
		$(LOGS_PROTO) && \
	protoc -I. -I$(OPENTELEMETRY_DIR) \
		--go_out=gen/go \
		--go-grpc_out=gen/go \
		$(SHARED_PROTO)'

	# Use go_package for log_attributes
	PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH \
	protoc -I. -I$(OPENTELEMETRY_DIR) \
		--go_out=gen/go \
		--go-grpc_out=gen/go \
		$(SHARED_PROTO)

	# Initialize and tidy Go module for sharedpb if not already done
	cd gen/go/github.com/ansible/log-schema/gen/go/sharedpb && \
		(test -f go.mod || go mod init github.com/ansible/log-schema/gen/go/sharedpb) && \
		go mod tidy

# Compile Gateway API proto for Go
gen-gateway-go:
	@echo "🔧 Generating Go code from gateway_user_api.proto..."
	@mkdir -p gen/go/github.com/ansible/log-schema/gen/go/gatewaypb
	PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH \
	protoc -I. \
		--go_out=gen/go \
		--go-grpc_out=gen/go \
		$(GATEWAY_PROTO)
	
	# Initialize and tidy Go module for gatewaypb
	cd gen/go/github.com/ansible/log-schema/gen/go/gatewaypb && \
		(test -f go.mod || go mod init github.com/ansible/log-schema/gen/go/gatewaypb) && \
		go mod tidy

# Compile for Python
gen-python:
	mkdir -p gen/python
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python \
	python -m grpc_tools.protoc -I. -I$(OPENTELEMETRY_DIR) \
		--python_out=gen/python \
		$(LOGS_PROTO) $(SHARED_PROTO)

# Compile Gateway API proto for Python
gen-gateway-python:
	@echo "🔧 Generating Python code from gateway_user_api.proto..."
	mkdir -p gen/python
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python \
	python -m grpc_tools.protoc -I. \
		--python_out=gen/python \
		--grpc_python_out=gen/python \
		$(GATEWAY_PROTO)

# Generate OpenAPI spec from Gateway API proto
gen-gateway-openapi:
	@echo "🔧 Generating OpenAPI 2.0 from gateway_user_api.proto..."
	mkdir -p gen/openapi
	PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH \
	protoc -I. \
		--openapiv2_out=gen/openapi \
		--openapiv2_opt=logtostderr=true \
		$(GATEWAY_PROTO)
	@echo "✓ Generated: gen/openapi/shared/gateway_user_api.swagger.json"

# Generate OpenAPI with AI extensions from enhanced proto
gen-gateway-openapi-ai:
	@echo "🔧 Generating OpenAPI 2.0 with AI extensions from gateway_user_api_with_ai.proto..."
	@echo "⚠️  Note: Requires grpc-gateway protos in third_party/grpc-gateway/"
	mkdir -p gen/openapi
	PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH \
	$(TOOLS_DIR)/bin/protoc -I. \
		-Ithird_party/grpc-gateway \
		--openapiv2_out=gen/openapi \
		--openapiv2_opt=logtostderr=true \
		$(GATEWAY_AI_PROTO)
	@echo "✓ Generated: gen/openapi/shared/gateway_user_api_with_ai.swagger.json"
	@echo ""
	@echo "Compare specs:"
	@echo "  Simple:   gen/openapi/shared/gateway_user_api.swagger.json"
	@echo "  Enhanced: gen/openapi/shared/gateway_user_api_with_ai.swagger.json"

# Generate both Go and Python for Gateway API
gen-gateway: gen-gateway-go gen-gateway-python gen-gateway-openapi

# Generate AWX Job Template API (Go + Python + OpenAPI)
gen-awx-go:
	@echo "🔧 Generating Go code from awx_job_template.proto..."
	@mkdir -p gen/go/github.com/ansible/proto-example-log-api/gen/go/awxpb
	PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH \
	protoc -I. \
		--go_out=gen/go \
		--go-grpc_out=gen/go \
		$(AWX_PROTO)
	cd gen/go/github.com/ansible/proto-example-log-api/gen/go/awxpb && \
		(test -f go.mod || go mod init github.com/ansible/proto-example-log-api/gen/go/awxpb) && \
		go mod tidy

gen-awx-python:
	@echo "🔧 Generating Python code from awx_job_template.proto..."
	mkdir -p gen/python
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python \
	python -m grpc_tools.protoc -I. \
		--python_out=gen/python \
		--grpc_python_out=gen/python \
		$(AWX_PROTO)

gen-awx-openapi:
	@echo "🔧 Generating OpenAPI from awx_job_template.proto..."
	mkdir -p gen/openapi
	PATH=$(abspath $(TOOLS_DIR))/bin:$$PATH \
	protoc -I. \
		--openapiv2_out=gen/openapi \
		--openapiv2_opt=logtostderr=true \
		$(AWX_PROTO)
	@echo "✓ Generated: gen/openapi/shared/awx_job_template.swagger.json"

gen-awx: gen-awx-go gen-awx-python gen-awx-openapi

# Convert Swagger 2.0 specs to OpenAPI 3.0.3 (optional - requires npm/npx)
convert-to-openapi3:
	@echo "🔧 Converting Swagger 2.0 specs to OpenAPI 3.0.3..."
	@command -v npx >/dev/null 2>&1 || (echo "❌ npx not found. Install Node.js/npm first" && exit 1)
	@for spec in gen/openapi/shared/*.swagger.json; do \
		base=$$(basename $$spec .swagger.json); \
		echo "  Converting $$base..."; \
		npx --yes swagger2openapi $$spec -o gen/openapi/shared/$${base}.openapi.yaml; \
	done
	@echo "✓ Converted specs to OpenAPI 3.0.3 in gen/openapi/shared/*.openapi.yaml"
	@echo ""
	@echo "Swagger 2.0 specs (original):  gen/openapi/shared/*.swagger.json"
	@echo "OpenAPI 3.0.3 specs (converted): gen/openapi/shared/*.openapi.yaml"

 run-go-example: go
	@echo ""
	@echo "--running go example"
	cd example/go && go mod tidy && go run main.go


 run-otlp-example: go
	@echo ""
	@echo "--running go example"
	cd example/go_otlp && go mod tidy && go run main.go

 run-py-example:
	@echo ""
	@echo "--running minimal library version"
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python:$(abspath gen/python) \
	python3 example/py/main.py
	@echo ""
	@echo "--running with google library version"
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python:$(abspath gen/python) \
	python3 example/py_google/main.py

run-go-gateway-example:
	@echo ""
	@echo "--running Go gateway API example"
	cd example/go_gateway && go mod tidy && go run main.go

run-py-gateway-example:
	@echo ""
	@echo "--running Python gateway API example"
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python:$(abspath gen/python) \
	python3 example/py_gateway/main.py

run-gateway-examples: run-go-gateway-example run-py-gateway-example

run-go-awx-example:
	@echo ""
	@echo "--running Go AWX Job Template example"
	cd example/go_awx && go mod tidy && go run main.go

run-py-awx-example:
	@echo ""
	@echo "--running Python AWX Job Template example"
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python:$(abspath gen/python) \
	python3 example/py_awx/main.py

run-awx-examples: run-go-awx-example run-py-awx-example

# Clean all generated artifacts and tools
clean:
	@echo "🧹 Cleaning generated code..."
	rm -rf gen
	@echo "🧹 Cleaning tools..."
	rm -rf $(TOOLS_DIR)
	@echo "🧹 Cleaning Go caches..."
	go clean -cache -modcache -testcache -x
	@echo "🧹 Cleaning example go.sum files..."
	rm -f example/go/go.sum
	rm -f example/go_otlp/go.sum
	rm -f example/go_gateway/go.sum
	@echo "✓ Clean complete"


# Validate tools are correctly installed
check-tools:
	@echo "Checking Go version (requires >= 1.24.6)..."
	@go version || (echo "❌ Go not found or not executable" && exit 1)
	@go version | grep -qE 'go1\.(2[4-9]|[3-9][0-9])\.[6-9]|go1\.2[4-9]\.[0-9]+|go1\.[3-9][0-9]' || \
		(echo "❌ ERROR: Go 1.24.6 or higher required (protoc-gen-openapi dependency)" && \
		 echo "   Current version: $$(go version)" && \
		 echo "   Install with gvm: gvm install go1.24.6 -B && gvm use go1.24.6 --default" && \
		 exit 1)
	@echo "✓ Go version OK: $$(go version | awk '{print $$3}')"
	
	@echo "Checking protoc..."
	@$(TOOLS_DIR)/bin/protoc --version || (echo "❌ protoc not found - run: make install-tools" && exit 1)
	
	@echo "Checking protoc-gen-go..."
	@$(PROTOC_GEN_GO) --version || (echo "❌ protoc-gen-go not found - run: make install-tools" && exit 1)
	
	@echo "Checking protoc-gen-go-grpc..."
	@$(PROTOC_GEN_GO_GRPC) --version || (echo "❌ protoc-gen-go-grpc not found - run: make install-tools" && exit 1)
	
	@echo "Checking protoc-gen-openapiv2..."
	@test -f $(PROTOC_GEN_OPENAPI) || (echo "❌ protoc-gen-openapiv2 not found - run: make install-tools" && exit 1)
	@echo "✓ All protoc plugins found"

	@echo "Checking Python version..."
	@python3 --version || (echo "❌ Python 3 not found or not executable" && exit 1)
	@echo "✓ Python OK: $$(python3 --version | awk '{print $$2}')"
	
	@echo ""
	@echo "✓ All tools validated successfully"

# Show help
help:
	@echo ""
	@echo "  gen-all                Install tools and generate all (logging + gateway API + OpenAPI)"
	@echo "    install-tools          Install protoc, protoc-gen-go, protoc-gen-grpc, protoc-gen-openapi"
	@echo "    check-tools            Verify all tools are installed"
	@echo "    gen-go                 Generate Go code from log_attributes.proto"
	@echo "    gen-python             Generate Python code from log_attributes.proto"
	@echo "    gen-gateway            Generate Gateway API (Go + Python + OpenAPI)"
	@echo "      gen-gateway-openapi    → Generate Swagger 2.0 spec (OpenAPI compatible)"
	@echo "    gen-awx                Generate AWX Job Template API (Go + Python + OpenAPI)"
	@echo "      gen-awx-openapi        → Generate Swagger 2.0 spec (OpenAPI compatible)"
	@echo "  run-all                Run all examples (logging + gateway API)"
	@echo "    run-go-example         Run go logging example"
	@echo "    run-py-example         Run python logging example"
	@echo "    run-gateway-examples   Run Gateway API examples (Go + Python)"
	@echo "    run-awx-examples       Run AWX Job Template examples (Go + Python)"
	@echo "  run-otlp-example  A go program showing how to embed LogAttributes within an OTEL LogRecord"
	@echo "                    **note**: Above would normally be carried in a binary payload"
	@echo "                    and processed by otel toolslike grafana and not designed to be human-readable."
	@echo "  clean             Remove all generated code and tools, you will need to make gen-all again"
	@echo "  help              Show this help message"
