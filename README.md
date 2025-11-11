# Proto-First API Development for AAP

This repository demonstrates Protocol Buffers (protobuf) as a solution for **ANSTRAT-1738: OpenAPI Standardization** and **contract-first development** across Ansible Automation Platform services.

## Why Protobuf for ANSTRAT-1738?

### The Problems (From SDP-0050 and Recent Discussions)

**Problem 1: Controller Stuck on Swagger 2.0** (Tami, Nov 11 2025)
> "The biggest problem was on Controller spec, which was not in v3 format yet while others were already v3.0.3"

**Problem 2: Can't Do Contract-First with Current Tools** (Alan, PR #870)
> "You have to implement it to get the OpenAPI spec. All the tooling mentioned generates the spec from the code."

**Problem 3: Breaking Changes Break Consumers** (Pablo/elyezer, PR #870)
> "Some API changed for AAP 2.6 that broke some UI functionality, also impacted the ATF clients"

**Problem 4: AAP is Polyglot** (Architecture Reality)
- Receptor: Go
- Controller, Gateway, Hub, EDA: Python/Django
- Need type-safe communication across language boundaries

### Why Proto Solves These Problems

| Problem | Proto Solution | Reference |
|---------|----------------|-----------|
| **Controller Swagger 2.0** | Proto → Swagger 2.0 → OpenAPI 3.0.3 (trivial conversion) | Agentic AI Demo - Initiative 1 & 2 November 11th meeting |
| **Contract-first impossible** | Proto enforces contract-first (won't compile without proto) | [SDP-0050 P1](../handbook/...) |
| **Breaking changes** | Proto field numbers are immutable (compiler prevents breaks) | [PR #870 discussion](../pr-870.txt) |
| **Polyglot architecture** | Proto generates Go + Python from single source | This repo (working proof) |
| **MCP needs OpenAPI** | Proto → OpenAPI automatic, rich docs from comments | [ANSTRAT-1646](../ANSTRAT-1738.txt) |

### Industry Validation

**Companies using Proto for Python + Go polyglot services:**
- Google: All internal services (millions of proto definitions)
- Netflix: Microservices (Java, Python, Go, Node)
- Uber: Service mesh coordination
- Lyft: Envoy configuration + services

**Not experimental** - industry-proven solution for exactly AAP's architecture (polyglot services).

### Timeline Alignment

| Initiative | Deadline | Dependency on OpenAPI |
|----------|----------|----------------------|
| MCP Phase 1 (ANSTRAT-1646) | Dec 2025 | Needs standardized specs |
| ANSTRAT-1738 Testathon | Dec 16, 2025 | OpenAPI validation |
| BYOLLM (ANSTRAT-505) | Dec 19, 2025 | LLM API understanding |

**All December deadlines** - proto provides mature tooling that works today (protoc 33.0, proven 15+ years).

### References

- **ANSTRAT-1738:** https://issues.redhat.com/browse/ANSTRAT-1738
- **SDP-0050 (PR #870):** https://github.com/ansible/handbook/pull/870
- **ANSTRAT-1646 (MCP):** https://issues.redhat.com/browse/ANSTRAT-1646
- **Protocol Buffers:** https://protobuf.dev/
- **grpc-gateway:** https://github.com/grpc-ecosystem/grpc-gateway

## Three Demonstrations

### 1. Structured Logging (Original)

Proof-of-concept for cross-language structured logging using protobuf.

**See:** [README-Structured-Logging.md](README-Structured-Logging.md)

**Pattern:** `.proto` → Python + Go structs → Consistent JSON logs

### 2. Gateway User API (AAP Gateway)

Proto-first API for AAP Gateway user management.

**See:** [README-Open-API.md](README-Open-API.md)

**Pattern:** `gateway_user_api.proto` → Go/Python/gRPC + OpenAPI spec

### 3. AWX Job Template API (Controller)

Proto-first API for AWX/Controller job template management and execution.

**Real AWX API:** Job templates are the most commonly used Controller API (launching automation).

**Pattern:** `awx_job_template.proto` → Go/Python/gRPC + OpenAPI spec

**Demonstrates:** Proto works for actual Controller APIs, not just theoretical examples

---

## Quick Start

```bash
gvm use go1.24.6 --default  # Requires Go 1.24.6+
make gen-all                # Generate everything
make run-all                # Run all examples
make help                   # See all commands
```

## What This Proves

✅ **Contract-first development** - Proto must exist before code generation  
✅ **Cross-language type safety** - Same proto generates Go and Python with identical types  
✅ **OpenAPI generation** - Automatic spec generation from proto for MCP/UI/partners  
✅ **Single source of truth** - All artifacts guaranteed to match (from same proto)  
✅ **Real AWX/Controller APIs** - Works for actual production APIs (Job Templates)

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
│   ├── gateway_user_api.proto        # Gateway User API (new)
│   └── awx_job_template.proto        # AWX Job Template API (new - real Controller API)
│
├── example/
│   ├── go/go_otlp/py/py_google/      # Logging examples
│   ├── go_gateway/py_gateway/        # Gateway API examples
│   └── go_awx/py_awx/                # AWX Job Template examples
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
| `shared/gateway_user_api.proto` | AAP Gateway User API |
| `shared/awx_job_template.proto` | AWX Job Template API (real Controller API) |
| `gen/openapi/shared/gateway_user_api.swagger.json` | Auto-generated OpenAPI (Gateway) |
| `gen/openapi/shared/awx_job_template.swagger.json` | Auto-generated OpenAPI (AWX/Controller) |

## Documentation

- **[README-Structured-Logging.md](README-Structured-Logging.md)** - Original logging demo
- **[README-Open-API.md](README-Open-API.md)** - Gateway API demo
- **[MCP-CONSUMPTION.md](MCP-CONSUMPTION.md)** - How MCP uses generated OpenAPI
- **[COMMIT-MSG.md](COMMIT-MSG.md)** - Git commit guidance for this branch

Run `make help` for all available Makefile targets.
