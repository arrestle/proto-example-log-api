# Gateway API Demo: Proto → Go/Python/OpenAPI Generation

This demo extends log-schema to demonstrate proto-first API development for AAP Gateway User API, proving proto works for actual API services (not just logging structures).

## Why This Matters

Single `.proto` file generates:
- ✅ Go gRPC server code
- ✅ Python gRPC code
- ✅ **OpenAPI specification** (for MCP, UI teams, partners)

All from one source of truth - demonstrating **contract-first development** with mature tooling.

## Prerequisites

**Go Version:** Requires **Go 1.24.6 or higher** (for protoc-gen-openapi)

```bash
# Check version
go version  # Must show go1.24.6 or higher

# Install/switch with gvm (recommended)
gvm install go1.24.6 -B
gvm use go1.24.6 --default
```

**Python:** 3.9 or higher

## Quick Start

```bash
# 1. Install all tools (protoc, protoc-gen-go, protoc-gen-openapi, etc.)
make install-tools

# 2. Generate everything from gateway_user_api.proto
make gen-gateway

# 3. Verify what was generated
ls gen/go/.../gatewaypb/              # Go gRPC code
ls gen/python/shared/                 # Python gRPC code
cat gen/openapi/shared/*.swagger.json # OpenAPI spec!

# 4. Run the examples
make run-gateway-examples
```

## What Gets Generated

### From `shared/gateway_user_api.proto` (143 lines)

**Single command:** `make gen-gateway`

**Generates:**

1. **Go gRPC Code** (~680 lines)
   - Message types and gRPC service/client
   - Location: `gen/go/.../gatewaypb/`

2. **Python gRPC Code** (~200 lines)
   - Message classes and gRPC stubs
   - Location: `gen/python/shared/`

3. **OpenAPI Specification** (~116 lines)
   - Swagger 2.0 / OpenAPI compatible
   - Location: `gen/openapi/shared/gateway_user_api.swagger.json`

**Total: ~1,000 lines generated from 143 lines of proto (7x multiplication)**

## Key Demonstrations

### ✅ Contract-First Development

Proto must exist before any code generation:

```bash
# Without proto - fails
make gen-gateway

# Write proto first - succeeds
vim shared/gateway_user_api.proto
make gen-gateway  # ✓ Generates Go + Python + OpenAPI
```

**Solves:** "You have to implement it to get the OpenAPI spec" (Alan's objection)

### ✅ Type Safety Across Languages

Same proto generates identical types in Go and Python:

**Go:**
```go
user := &gatewaypb.User{
    Id:       123,
    Username: "alice",
}
```

**Python:**
```python
user = gateway_user_api_pb2.User(
    id=123,
    username="alice"
)
```

Both produce identical JSON output.

### ✅ OpenAPI with Rich Documentation

Proto comments automatically transfer to OpenAPI:

**Proto:**
```protobuf
// Username for login and identification. Must be unique across all users.
// Typically lowercase alphanumeric with underscores or hyphens.
// Example: "alice" or "bob_admin"
string username = 2;
```

**Generated OpenAPI:**
```json
"username": {
  "type": "string",
  "title": "Username for login and identification. Must be unique across all users.\nTypically lowercase alphanumeric with underscores or hyphens.\nExample: \"alice\" or \"bob_admin\""
}
```

**MCP-compatible:** Yes! MCP parses `title` and `description` fields.

### ✅ Single Source, Multiple Outputs

```
gateway_user_api.proto (one file)
    ↓
make gen-gateway
    ↓
├─→ Go server (for Receptor team)
├─→ Python code (for Controller team)
├─→ OpenAPI spec (for MCP, UI, partners)
└─→ All guaranteed to match (same source)
```

## Makefile Targets

```bash
make gen-gateway            # Generate Go + Python + OpenAPI
make gen-gateway-go         # Generate Go only
make gen-gateway-python     # Generate Python only
make gen-gateway-openapi    # Generate OpenAPI only

make run-gateway-examples   # Run both Go and Python examples
make clean                  # Remove all generated artifacts
make help                   # Show all available targets
```

## Connection to ANSTRAT-1738

This demo addresses SDP-0050 problem statements:

**P1: How do we standardize OpenAPI format?**
- Proto generates consistent OpenAPI (Swagger 2.0 / OpenAPI compatible)
- Same format whether service is Python or Go

**P2: How do we integrate into CI/CD?**
- `make gen-gateway` is the CI validation step
- Proto compilation catches contract changes
- Breaking changes detected at build time

**P12: How do we ensure downstream tooling (MCP) integration?**
- Proto → OpenAPI pipeline automatic
- Rich descriptions from proto comments
- MCP-compatible format

## Files

```
shared/
└── gateway_user_api.proto    # API service definition (source of truth)

example/
├── go_gateway/               # Go example using generated code
│   ├── main.go
│   └── go.mod
└── py_gateway/               # Python example using generated code
    ├── main.py
    └── __init__

gen/                          # Generated (not committed)
├── go/.../gatewaypb/         # Go gRPC code
├── python/shared/            # Python gRPC code
└── openapi/shared/           # OpenAPI spec
```

## Related Documentation

- **[README-Structured-Logging.md](README-Structured-Logging.md)** - Original log-schema documentation
- **Makefile** - Run `make help` for all available commands

## For ANSTRAT-1738 Discussion

This branch demonstrates:
1. **Proto-first** works for AAP APIs (not just logging)
2. **Contract-first** is achievable with protoc tooling
3. **OpenAPI generated automatically** for MCP consumption
4. **Same pattern as log-schema**, just expanded to API services

Branch: `open-api-demo`

