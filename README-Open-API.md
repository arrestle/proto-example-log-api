# API Demonstrations: Proto → Go/Python/OpenAPI

This demonstrates proto-first API development for real AAP services, proving proto works for production APIs (not just logging structures).

## What This Includes

**Three API Examples:**

| API | Service | Proto Lines | Generated | Purpose |
|-----|---------|-------------|-----------|---------|
| **Gateway User API** | AAP Gateway | 143 | ~1,000 lines | User management |
| **AWX Job Template API** | Controller | 245 | ~1,500 lines | **Job execution (most common AWX API)** |
| **Combined Total** | - | 388 | ~2,500 lines | Real production APIs |

**Single command generates:**
- ✅ Go gRPC server code
- ✅ Python gRPC code
- ✅ **OpenAPI specifications** (Swagger 2.0 → convertible to OpenAPI 3.0.3)

All from proto source of truth - demonstrating **contract-first development** with mature, current tooling (protoc 33.0, Nov 2025).

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
make gen-all     # Generate everything (logging + APIs + OpenAPI specs)
make run-all     # Run all examples
make help        # See all available commands
```

## What Gets Generated

### Gateway User API: `make gen-gateway`

**From:** `shared/gateway_user_api.proto` (143 lines)

**Generates:** ~1,000 lines
- Go gRPC code (~680 lines) in `gen/go/.../gatewaypb/`
- Python gRPC code (~200 lines) in `gen/python/shared/`
- OpenAPI spec (116 lines) in `gen/openapi/shared/gateway_user_api.swagger.json`

### AWX Job Template API: `make gen-awx`

**From:** `shared/awx_job_template.proto` (245 lines) - **Real Controller API**

**Generates:** ~1,500 lines
- Go gRPC code (~1,055 lines) in `gen/go/.../awxpb/`
- Python gRPC code (~250 lines) in `gen/python/shared/`
- OpenAPI spec (201 lines) in `gen/openapi/shared/awx_job_template.swagger.json`

**AWX Job Template is the most commonly used Controller API** - demonstrates proto works for real production APIs that launch automation jobs.

### OpenAPI Format

**Generated format:** Swagger 2.0 (MCP-compatible)
**Optional conversion:** `make convert-to-openapi3` → OpenAPI 3.0.3 YAML (AAP standard)

**Tooling:** protoc 33.0 (latest, Nov 2025) + Go plugins @latest

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

**MCP-compatible:** Yes! MCP parses `title` and `description` fields. LLMs extract descriptions, types, examples, and usage context from proto comments - no x-llm-* extensions required.

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

## Available Commands

Run `make help` to see all available targets.

## Connection to ANSTRAT-1738

### Addresses SDP-0050 Problem Statements

**P1: Standardize OpenAPI format**
- Proto generates consistent Swagger 2.0 (convertible to OpenAPI 3.0.3)
- Same format whether service is Python (Django) or Go

**P2: Integrate into CI/CD**
- `make gen-gateway` / `make gen-awx` validate proto contracts
- Breaking changes detected at build time
- No development deadlocks

**P12: Downstream tooling (MCP) integration** ([ANSTRAT-1646](https://issues.redhat.com/browse/ANSTRAT-1646))
- Proto → OpenAPI pipeline automatic
- Rich documentation from proto comments
- MCP-compatible (Tami confirmed: "version 3.0.3 was sufficient")

### Addresses Controller Migration Issue

**From Agentic AI Demo - Initiative 1 & 2 November 11th meeting (Tami - MCP team):**
> "The biggest problem was on Controller spec, which was not in v3 format yet"

**AWX Job Template demo shows:**
- Controller's most common API (job execution) defined in proto
- Generates Swagger 2.0 → convertible to OpenAPI 3.0.3
- Provides Controller migration path from current Swagger 2.0

## Repository Structure

```
shared/                      # Proto source files
├── gateway_user_api.proto   # Gateway User API
└── awx_job_template.proto   # AWX Job Template API

example/                     # Example code using generated protos
├── go_gateway/              # Go Gateway API example
└── py_gateway/              # Python Gateway API example

gen/                         # Generated code (not committed)
├── go/                      # Go gRPC code
├── python/                  # Python gRPC code
└── openapi/                 # OpenAPI specs (.swagger.json, .openapi.yaml)
```

## AI/LLM Extensions for MCP

Proto generates MCP-compatible OpenAPI via comments (simple) or annotations (enhanced).

### Two Approaches

| Approach | File | Dependencies | Lines | AI Support |
|----------|------|--------------|-------|------------|
| **Simple** (current) | `gateway_user_api.proto` | None | 143 | Good - comments → title/description |
| **Enhanced** (optional) | `gateway_user_api_with_ai.proto` | grpc-gateway | ~280 | Excellent - structured x-ai-* extensions |

**Recommendation:** Simple approach sufficient for MCP. Use enhanced only if MCP team requests specific x-ai-* extensions.

### MCP Consumption

**Current proto comments provide:** Descriptions, types, examples, constraints - MCP can parse these from `title`/`description` fields.

**Optional x-ai-* extensions** (via `gateway_user_api_with_ai.proto`): `x-ai-reasoning-instructions`, `x-ai-capabilities`, `x-openai-isConsequential`, `x-ai-hint`, `x-aap-rbac-permission`.

**Recommendation:** Simple proto comments sufficient. Add x-ai-* only if MCP team specifically requests them.

### References

| Resource | URL |
|----------|-----|
| OpenAPI Extensions Spec | https://spec.openapis.org/oas/v3.0.0#specification-extensions |
| Microsoft x-ai-* Catalog | https://deepwiki.com/microsoft/OpenAPI/2-openapi-extensions-catalog |
| OpenAI Consequential Flag | https://platform.openai.com/docs/actions/consequential-flag |
| Agentic API Patterns | https://agenticapi.io/docs/openapi-extensions/ |
| grpc-gateway Options | https://github.com/grpc-ecosystem/grpc-gateway/tree/main/protoc-gen-openapiv2/options |
| Model Context Protocol | https://spec.modelcontextprotocol.io/ |

## Related Documentation

- **[README-Structured-Logging.md](README-Structured-Logging.md)** - Original logging demo
- **`shared/gateway_user_api_with_ai.proto`** - Optional: Enhanced proto with x-ai-* annotations

## For ANSTRAT-1738 Discussion

This branch demonstrates:
1. **Proto-first** works for AAP APIs (not just logging)
2. **Contract-first** is achievable with protoc tooling
3. **OpenAPI generated automatically** for MCP consumption
4. **AI/LLM extensions** supported via proto annotations or post-processing
5. **Same pattern as log-schema**, just expanded to API services

Branch: `open-api-demo`

