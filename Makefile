# Paths
PROTOC_VERSION = 26.0
PROTOC_DIR = tools/protoc_install
PROTOC_TEMP_BIN = $(PROTOC_DIR)/bin/protoc
TOOLS_DIR = tools
OPENTELEMETRY_DIR = third_party/opentelemetry-proto
SHARED_DIR = shared

LOGS_PROTO = $(OPENTELEMETRY_DIR)/opentelemetry/proto/logs/v1/logs.proto
SHARED_PROTO = $(SHARED_DIR)/log_attributes.proto

PROTOC_GEN_GO = $(TOOLS_DIR)/bin/protoc-gen-go
PROTOC_GEN_GO_GRPC = $(TOOLS_DIR)/bin/protoc-gen-go-grpc

.PHONY: all go python clean install-tools clean-tools check-tools

# Build everything
gen-all: install-tools check-tools gen-go gen-python 
run-all: run-go-example run-py-example

# Install tools in local tools dir
install-tools:

	@echo "Install protoc-gen-go and -grpc"
	GOBIN=$(abspath $(TOOLS_DIR))/bin go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
	GOBIN=$(abspath $(TOOLS_DIR))/bin go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
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

# Compile for Python
gen-python:
	mkdir -p gen/python
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python \
	python -m grpc_tools.protoc -I. -I$(OPENTELEMETRY_DIR) \
		--python_out=gen/python \
		$(LOGS_PROTO) $(SHARED_PROTO)

 run-go-example: go
	@echo ""
	@echo "--running go example"
	cd example/go && go mod tidy && go run main.go

 run-py-example:
	@echo ""
	@echo "--running minimal library version"
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python:$(abspath gen/python) \
	python3 example/py/main.py
	@echo ""
	@echo "--running with google library version"
	PYTHONPATH=$(abspath $(TOOLS_DIR))/python:$(abspath gen/python) \
	python3 example/py_google/main.py

# Clean all generated artifacts and tools
clean:
	rm -rf gen
	rm -rf $(TOOLS_DIR)
	go clean -cache -modcache -testcache -x


# Validate tools are correctly installed
check-tools:
	@echo "Checking protoc..."
	@$(TOOLS_DIR)/bin/protoc --version || (echo "protoc not found or not executable" && exit 1)
	
	@echo "Checking protoc-gen-go..."
	@$(PROTOC_GEN_GO) --version || (echo "protoc-gen-go not found or not executable" && exit 1)
	
	@echo "Checking protoc-gen-go-grpc..."
	@$(PROTOC_GEN_GO_GRPC) --version || (echo "protoc-gen-go-grpc not found or not executable" && exit 1)

	@echo "Checking Go version..."
	@go version || (echo "Go not found or not executable" && exit 1)

	@echo "Checking Python version..."
	@python3 --version || (echo "Python 3 not found or not executable" && exit 1)

# Show help
help:
	@echo ""
	@echo "  gen-all           Install tools and generate go and python structs"
	@echo "    install-tools     Install protoc compiler, Go/Python plugins, and deps"
	@echo "    check-tools       Verify protoc and plugins are installed correctly"
	@echo "    gen-go            Generate Go code from .proto definitions"
	@echo "    gen-python        Generate Python code from .proto definitions"
	@echo "  run-all           Run go and python examples after make gen-all first"
	@echo "    run-go-example    Run go example"
	@echo "    run-py-example    Run python example"
	@echo "  clean             Remove all generated code and tools, you will need to make gen-all again"
	@echo "  help              Show this help message"
