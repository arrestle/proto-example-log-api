# Proto-First API Development for AAP

**TL;DR:** This repo demonstrates protobuf as an implementation approach for [ANSTRAT-1738](https://issues.redhat.com/browse/ANSTRAT-1738) OpenAPI standardization. Working demo of real AAP APIs (Gateway + Controller) generating Go, Python, and OpenAPI from single proto source.

---

## Why Consider Protobuf?

**What Teams Need:**
Controller needs OpenAPI 3.0.3 | MCP needs specs by Dec | ATF needs contract stability

**What Protobuf Offers:**
- **Contract-first by design** - Proto file required before code generation
- **Compatibility protection** - Field number immutability prevents breaking changes 
- **REST + gRPC from one source** - HTTP annotations generate full REST endpoints + gRPC service
- **OpenAPI 3.0.3 with REST paths** - Generates Swagger 2.0 with endpoints, converts to 3.0.3
- **Polyglot support** - One proto → Go and Python code (AAP already uses via K8s)
- **OpenTelemetry compatibility** - OTEL uses protobuf (structured logging demo)
- **Future performance opportunities** - 10x CPU, 2x bandwidth (Kubernetes experience)

### AAP's Existing Protobuf Dependencies

**AAP components already use protobuf:**
- **Gateway** - Runs gRPC server (grpcio==1.68.1) for Envoy communication. Uses protobuf-generated code (external_auth_pb2_grpc, cluster_pb2, listener_pb2)
- **Controller/AWX** - Has protobuf==6.32.1, grpcio==1.75.1, opentelemetry-proto==1.37.0 (for OpenTelemetry)
- **Kubernetes APIs** - Receptor (Go), Controller (Python), Gateway (Python) use K8s clients. K8s proto definitions generate clients for both languages - polyglot pattern in production
- **Operator Deployments** - AAP via operators uses Kubernetes protobuf APIs

**No new dependencies** - Gateway and Controller already use protobuf/gRPC in production.

---

## 🚨 Stakeholder Concerns → Proto Solutions

| Who | Their Problem | Proto Solution | Evidence |
|-----|---------------|----------------|----------|
| **Tami (MCP)** | "Controller spec not in v3 format yet" | Proto → OpenAPI 3.0.3 auto | `make gen-awx` |
| **Alan** | "Need code to get spec" | Proto is contract-first (enforced) | Won't compile without .proto |
| **Pablo** | "AAP 2.6 breaking changes" | Field numbers prevent breaks | Compile-time protection |
| **elyezer** | "What's the point of contract if it changes?" | Proto = immutable contract | Can only extend, not modify |

**All concerns addressed with working code, not theory.**

---

## ⏰ December 2025 Deadlines (3 Weeks!)

| Initiative | Date | Needs OpenAPI? |
|-----------|------|----------------|
| [ANSTRAT-1646](https://issues.redhat.com/browse/ANSTRAT-1646) MCP Phase 1 | Dec 10 | ✅ Yes |
| [ANSTRAT-1738](https://issues.redhat.com/browse/ANSTRAT-1738) Testathon | Dec 16 | ✅ Yes |
| [ANSTRAT-505](https://issues.redhat.com/browse/ANSTRAT-505) BYOLLM | Dec 19 | ✅ Yes |

**Proto delivers:** Mature tooling (protoc 33.0), works today, no custom development needed.

---


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
✅ **Single source of truth** - All artifacts generated from same proto source  
✅ **Real AWX/Controller APIs** - Works for actual production APIs (Job Templates)

## Connection to ANSTRAT-1738

Demonstrates implementation approach for [ANSTRAT-1738](https://issues.redhat.com/browse/ANSTRAT-1738) OpenAPI standardization.

**See [README-Open-API.md](README-Open-API.md)** for detailed mapping to [Contract-Driven Development SDP (PR #870)](https://github.com/ansible/handbook/pull/870) problem statements.

---

## Repository Structure

| Directory | Purpose |
|-----------|---------|
| `shared/` | Proto source files (logging, Gateway API, AWX API) |
| `example/` | Working examples in Go and Python |
| `gen/` | Generated code (Go, Python, OpenAPI) - not committed |
| `third_party/` | Dependencies (opentelemetry-proto) |

## Key Files

| File | Purpose |
|------|---------|
| `shared/log_attributes.proto` | Logging structure definition |
| `shared/gateway_user_api.proto` | AAP Gateway User API |
| `shared/awx_job_template.proto` | AWX Job Template API (real Controller API) |
| `gen/openapi/shared/gateway_user_api.swagger.json` | Auto-generated OpenAPI (Gateway) |
| `gen/openapi/shared/awx_job_template.swagger.json` | Auto-generated OpenAPI (AWX/Controller) |

Run `make help` for all available Makefile targets.

---

## 📚 References & Citations

### This Repository Documentation

- **[README-Structured-Logging.md](README-Structured-Logging.md)** - Original logging demo
- **[README-Open-API.md](README-Open-API.md)** - API demonstrations (Gateway + AWX)
- **`shared/gateway_user_api_with_ai.proto`** - Optional: Enhanced proto with x-ai-* annotations

### Ansible Engineering Handbook

- **[SDP-0050: Contract-Driven Development](https://github.com/ansible/handbook/blob/main/The%20Ansible%20Engineering%20Handbook/System%20Design%20Plans/0050-Contract-Driven-Development-Initial-OpenAPI-Specification-Adoption.md)** (PR #870) - Andrew Potozniak's SDP defining contract-driven approach for AAP
- **[Proposal 0067: Architecture Review Responsibilities](https://github.com/ansible/handbook/blob/main/The%20Ansible%20Engineering%20Handbook/proposals/0067-Architecture%20Review%20Responsibilities.md)** - FA/PDT 3IB governance structure
- **[Architectural Principle 7: API First](https://github.com/ansible/handbook/blob/main/The%20Ansible%20Engineering%20Handbook/Architecture/Principles.md#architectural-principle-7-application-development-is-api-first)** - AAP's API-first development principle

### Primary Initiatives

**[ANSTRAT-901](https://issues.redhat.com/browse/ANSTRAT-901) - Implement standard REST API-first development process across AAP**
> "Move to an API-first design process in which each service's API is created first, then the service is developed according to its API spec."
- **Parent initiative** for platform-wide API-first development
- **Status:** New (early refinement)
- **Assignee:** Andrew Potozniak
- **Goal:** 100% of platform services have OpenAPI3 specs, automated validation, API-first training for all teams
- ANSTRAT-1738 was split from this initiative

**[ANSTRAT-1738](https://issues.redhat.com/browse/ANSTRAT-1738) - Collecting, Centralizing and Enforcing OpenAPI Spec for AAP Services**
> "A central repository where all the existing OpenAPI specs are stored is agreed upon, and the current OpenAPI specs are added/updated. Format of OpenAPI spec is agreed upon. A tool is implemented and adopted to ensure that the centrally stored OpenAPI specifications and those generated by the source code match."
- **Due:** December 10, 2025
- **Assignee:** Andrew Potozniak
- **Components:** Gateway, Controller, EDA, Hub, Lightspeed
- Child of ANSTRAT-901 (split for focused execution)

**[ANSTRAT-1646](https://issues.redhat.com/browse/ANSTRAT-1646) - Enhancing Automation through Agentic Orchestration**
> "Initiative 1: Released in-product during 2.6 async prior to December 17, 2025."
- **MCP Server needs:** Standardized OpenAPI specifications for AI tooling
- **Timeline:** December 2025 (Phase 1)

**[ANSTRAT-505](https://issues.redhat.com/browse/ANSTRAT-505) - BYOLLM for AL on VScode Ansible Extension**
> "Remove heavily coupled IBM LLM requirement. Users can bring their own LLM into the Vscode extension settings."
- **Target:** December 19, 2025
- **Status:** SDP in review (PR #901)

### Key Stakeholder Feedback

**[Contract-Driven Development SDP (PR #870)](https://github.com/ansible/handbook/pull/870)** (Andrew Potozniak)
- **SDP:** [0050-Contract-Driven-Development-Initial-OpenAPI-Specification-Adoption.md](https://github.com/ansible/handbook/blob/main/The%20Ansible%20Engineering%20Handbook/System%20Design%20Plans/0050-Contract-Driven-Development-Initial-OpenAPI-Specification-Adoption.md)

**Alan Coding (Controller team):**
> "You have to implement it to get the OpenAPI spec. All the tooling mentioned generates the spec from the code."
- Current tooling (drf-spectacular) is code-first, not contract-first

**Pablo Hiro (ATF team):**
> "We can change how our contract is implemented. We cannot change our existing contract, only extend it."
- Advocates for Open-Closed Principle and contract-first development

**elyezer:**
> "Some API changed for AAP 2.6 that broke some UI functionality, also impacted the ATF clients"
- Real pain from breaking changes without contract enforcement

**Tami Takamiya (MCP team, Nov 11 2025):**
> "The biggest problem was on Controller spec, which was not in v3 format yet while others were already v3.0.3."
- Controller Swagger 2.0 is blocker for MCP Phase 1

### Industry Adoption

**[Google Protocol Buffers](https://protobuf.dev/overview/)**
> "Protocol Buffers are language-neutral, platform-neutral extensible mechanisms for serializing structured data. You define how you want your data to be structured once, then you can use special generated source code to easily write and read your structured data."
- Used internally at Google for millions of RPC definitions
- Reference: [Protocol Buffers Overview](https://protobuf.dev/overview/)

**[Netflix gRPC/Protobuf Usage](https://netflixtechblog.com/practical-api-design-at-netflix-part-1-using-protobuf-fieldmask-35cfdc606518)**
> "At Netflix, we use protobuf as the IDL (Interface Definition Language) for our gRPC services."
- Polyglot microservices: Java, Python, Go, Node.js
- Reference: Netflix Tech Blog

**[Uber Protobuf for Microservices](https://www.uber.com/blog/prototool/)**
> "Uber uses Protocol Buffers extensively. Prototool is our Swiss Army Knife for working with protobufs at scale."
- Manages thousands of proto files across polyglot services
- Reference: Uber Engineering Blog

**[Lyft Envoy + Protobuf](https://www.envoyproxy.io/docs/envoy/latest/configuration/overview/overview)**
> "Envoy's configuration and APIs are defined using Protocol Buffers (protobuf)."
- **AAP uses Envoy** - already depends on protobuf ecosystem
- Reference: Envoy Proxy Documentation

### Performance Evidence

**[Kubernetes Protobuf Migration](https://kubernetes.io/blog/2021/09/03/apis-with-protobuf/)**
> "The new protobuf serialization is about 10x faster for CPU, uses about 50% of the wire size compared to JSON."
- 10x CPU reduction
- 2x wire size reduction
- Proven at enterprise scale (OpenShift, Red Hat deployments)

### Technical Documentation

**[Protocol Buffers Official Docs](https://protobuf.dev/)**
- Proto3 syntax and best practices
- Language guides (Python, Go, Java, etc.)

**[grpc-gateway](https://github.com/grpc-ecosystem/grpc-gateway)**
- Generates REST/HTTP gateways from proto definitions
- Generates OpenAPI/Swagger specs from proto

**[protoc-gen-openapiv2](https://github.com/grpc-ecosystem/grpc-gateway/tree/main/protoc-gen-openapiv2)**
- Generates Swagger 2.0 / OpenAPI from proto
- Used in this demo

### Related AAP Work

**[AAP-53326](https://issues.redhat.com/browse/AAP-53326) - Cultural Change for API-First Development**
- Parent: ANSTRAT-1738
- Epic for training and team enablement

**[AAP-56421](https://issues.redhat.com/browse/AAP-56421) - Create SDP for API-First Development**
- PR #870 (Contract-Driven Development SDP by Andrew Potozniak)
- In review
