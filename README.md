# log-schema: Protobuf for AAP Cross-Language Development

This repository demonstrates Protocol Buffers (protobuf) for generating consistent code across Python and Go in Ansible Automation Platform (AAP).

## Two Demonstrations

### 1. Structured Logging (Original)

Proof-of-concept for cross-language structured logging using protobuf.

**See:** [README-Structured-Logging.md](README-Structured-Logging.md)

**Pattern:** `.proto` → Python + Go structs → Consistent JSON logs

### 2. Gateway API (New - OpenAPI Demo)

Extends the logging pattern to actual API service definitions with automatic OpenAPI generation.

**See:** [README-Open-API.md](README-Open-API.md)

**Pattern:** `.proto` → Go/Python/gRPC + OpenAPI spec → Contract-first APIs

---

## Quick Start

```bash
# Prerequisites
go version  # Requires go1.24.6 or higher
gvm use go1.24.6 --default  # If using gvm

# Generate everything (logging + gateway API + OpenAPI)
make gen-all

# Run all examples
make run-all

# See available commands
make help
```

## What This Proves

✅ **Contract-first development** - Proto must exist before code generation  
✅ **Cross-language type safety** - Same proto generates Go and Python with identical types  
✅ **OpenAPI generation** - Automatic spec generation from proto for MCP/UI/partners  
✅ **Single source of truth** - All artifacts guaranteed to match (from same proto)

## Connection to ANSTRAT-1738

This repository demonstrates implementation approaches for the OpenAPI standardization initiative (ANSTRAT-1738), showing how proto-first development can:
- Standardize API contracts across Python and Go services
- Generate OpenAPI specs automatically for downstream consumers
- Enable contract-first development with mature tooling
- Maintain type safety across language boundaries

**Branch:** `open-api-demo`

---

## Repository Structure

```
log-schema/
├── README.md                         # This file (overview)
├── README-Structured-Logging.md      # Original logging demo docs
├── README-Open-API.md                # Gateway API demo docs
├── MCP-CONSUMPTION.md                # How MCP consumes generated OpenAPI
├── Makefile                          # Build and generation targets
│
├── shared/
│   ├── log_attributes.proto          # Logging structures (original)
│   └── gateway_user_api.proto        # API service definition (new)
│
├── example/
│   ├── go/                           # Go logging example
│   ├── go_otlp/                      # OTLP logging example
│   ├── py/                           # Python logging example
│   ├── py_google/                    # Python logging (Google lib)
│   ├── go_gateway/                   # Go gateway API example (new)
│   └── py_gateway/                   # Python gateway API example (new)
│
└── gen/                              # Generated code (not committed)
    ├── go/                           # Generated Go code
    ├── python/                       # Generated Python code
    └── openapi/                      # Generated OpenAPI specs (new)
```

## Key Files

| File | Purpose |
|------|---------|
| `shared/log_attributes.proto` | Logging structure definition |
| `shared/gateway_user_api.proto` | API service definition |
| `gen/openapi/shared/gateway_user_api.swagger.json` | Auto-generated OpenAPI spec |

## Documentation

- **[README-Structured-Logging.md](README-Structured-Logging.md)** - Original logging demo
- **[README-Open-API.md](README-Open-API.md)** - Gateway API demo
- **[MCP-CONSUMPTION.md](MCP-CONSUMPTION.md)** - How MCP uses generated OpenAPI
- **[COMMIT-MSG.md](COMMIT-MSG.md)** - Git commit guidance for this branch

Run `make help` for all available Makefile targets.
