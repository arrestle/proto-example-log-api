# API Demonstrations: Proto → Go/Python/OpenAPI

**Created:** November 2025 (open-api-demo branch)
**Purpose:** Extend original logging demo to prove proto works for real AAP API services

This document provides technical details for Gateway User API and AWX Job Template API demonstrations. See [README.md](README.md) for overview and compelling "why protobuf" argument.

## Available Demos

| Command | What It Does | Output Folders |
|---------|--------------|----------------|
| `make gen-gateway` | Proto → Go + Python + Swagger 2.0 (REST: GET/POST /api/gateway/v1/users) | `gen/go/*`<br>`gen/python/*`<br>`gen/openapi/*` |
| `make gen-awx` | Proto → Go + Python + Swagger 2.0 (REST: GET/POST /api/v2/job_templates) | `gen/go/*`<br>`gen/python/*`<br>`gen/openapi/*` |
| `make convert-to-openapi3` | Swagger 2.0 → OpenAPI 3.0.3 (with full REST paths) | `gen/openapi/*.openapi.yaml` |
| `make run-gateway-examples` | Run Gateway examples (Go/Python sample requests) | Console output |
| `make run-awx-examples` | Run AWX examples (Go/Python sample requests) | Console output |
| `make mcp` | (TBD) Generate MCP server from OpenAPI 3.0.3 | (TBD) |


**AWX Job Template** is Controller's most commonly used API.

## Connection to ANSTRAT-1738

### Addresses SDP: Contract-Driven Development Problem Statements

**Source:** [PR #870: Contract-Driven Development SDP](https://github.com/ansible/handbook/pull/870) (Andrew Potozniak)
- **SDP Document:** [0050-Contract-Driven-Development-Initial-OpenAPI-Specification-Adoption.md](https://github.com/ansible/handbook/blob/main/The%20Ansible%20Engineering%20Handbook/System%20Design%20Plans/0050-Contract-Driven-Development-Initial-OpenAPI-Specification-Adoption.md)

**P1: Standardize OpenAPI format** ([ANSTRAT-1738](https://issues.redhat.com/browse/ANSTRAT-1738))
- Proto generates consistent Swagger 2.0 (convertible to OpenAPI 3.0.3)
- Same format whether service is Python (Django) or Go

**P2: Integrate into CI/CD** ([ANSTRAT-1738](https://issues.redhat.com/browse/ANSTRAT-1738))
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

## For ANSTRAT-1738 Discussion

This branch demonstrates:
1. **Proto-first** works for AAP APIs (not just logging)
2. **Contract-first** is achievable with protoc tooling
3. **OpenAPI generated automatically** for MCP consumption
4. **AI/LLM extensions** supported via proto annotations or post-processing
5. **Same pattern as log-schema**, just expanded to API services

Branch: `open-api-demo`

---

## References

### AI/LLM Extensions

| Resource | URL |
|----------|-----|
| OpenAPI Extensions Spec | https://spec.openapis.org/oas/v3.0.0#specification-extensions |
| Microsoft x-ai-* Catalog | https://deepwiki.com/microsoft/OpenAPI/2-openapi-extensions-catalog |
| OpenAI Consequential Flag | https://platform.openai.com/docs/actions/consequential-flag |
| Agentic API Patterns | https://agenticapi.io/docs/openapi-extensions/ |
| grpc-gateway Options | https://github.com/grpc-ecosystem/grpc-gateway/tree/main/protoc-gen-openapiv2/options |
| Model Context Protocol | https://spec.modelcontextprotocol.io/ |

### Related Documentation

- **[README.md](README.md)** - Main overview and "Why Protobuf" argument
- **[README-Structured-Logging.md](README-Structured-Logging.md)** - Original logging demo
- **`shared/gateway_user_api_with_ai.proto`** - Optional: Enhanced proto with x-ai-* annotations

