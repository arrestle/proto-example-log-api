# Spec-Driven API Development: Alternatives to Protobuf

**Created:** November 2025
**Purpose:** Compare industry-adopted spec-driven approaches for AAP's needs

---

## All Industry Options

| Approach | Spec-First? | REST Native? | Server Gen Quality | AAP Has Deps? | Breaking Change Prevention |
|----------|-------------|--------------|-------------------|---------------|---------------------------|
| **Protobuf** | ✅ | Via annotations | ✅ Excellent | ✅ Yes (K8s, OTEL, Gateway) | ✅ Field numbers |
| **OpenAPI-First** | ✅ | ✅ | ⚠️ Immature (Django) | ⚠️ drf-spectacular | ❌ No |
| **GraphQL** | ✅ | ❌ | ✅ Good | ❌ No | ⚠️ Limited |
| **Smithy** (AWS) | ✅ | ✅ | ⚠️ Limited | ❌ No | ✅ Yes |
| **Thrift** (Meta) | ✅ | ❌ | ✅ Good | ❌ No | ✅ Yes |

---

## Detailed Comparison

### **1. OpenAPI-First (Hand-Written YAML)**

**How it works:** Write OpenAPI spec → Generate server code

**Pros:**
- REST-native (HTTP methods, paths built-in)
- Industry standard for REST APIs
- MCP/LLM tools expect OpenAPI
- Human-readable YAML

**Cons:**
- Server generation immature for Django (Pablo noted: "might need custom tool")
- No compile-time validation
- Breaking changes not prevented
- Manual maintenance burden

**For AAP:** This is what Pablo ideally wants, but tooling gap exists.

---

### **2. Protobuf (gRPC) - This Demo**

**How it works:** Write .proto → Generate server + client + OpenAPI

**Pros:**
- Mature Python/Go server generation
- Compile-time validation
- Breaking change prevention (field number immutability)
- AAP already depends on it (Gateway gRPC, K8s, OTEL)
- Generates OpenAPI with REST annotations

**Cons:**
- RPC-focused (need google.api.http for REST paths)
- Learning curve for teams
- Binary format less debuggable than JSON

**For AAP:** Best fit for polyglot architecture, existing dependencies, December timeline.

---

### **3. GraphQL**

**How it works:** Write schema → Implement resolvers

**Pros:**
- Spec-first enforced
- Single endpoint
- Strong typing
- Client controls data shape

**Cons:**
- Not REST (different paradigm)
- Doesn't solve OpenAPI requirement
- Not AAP's architecture

**For AAP:** Wrong paradigm - AAP is REST-based, MCP needs OpenAPI not GraphQL.

---

### **4. Smithy (Amazon)**

**How it works:** Write .smithy → Generate code

**Pros:**
- Modern (2020+)
- REST-first design
- Generates OpenAPI

**Cons:**
- Very new, limited adoption
- Small ecosystem
- Not in AAP's dependency chain

**For AAP:** Too risky for platform-wide adoption.

---

### **5. Thrift (Meta/Facebook)**

**How it works:** Write .thrift → Generate code

**Pros:**
- Similar to protobuf
- Mature generation

**Cons:**
- Smaller ecosystem than proto
- Less active development
- No OpenAPI generation

**For AAP:** Proto is more popular with better tooling.

---

## AAP-Specific Evaluation

### **What AAP Needs**

| Requirement | Best Option |
|-------------|-------------|
| Contract-first development | Protobuf or OpenAPI-First |
| Python + Go polyglot | **Protobuf** (proven at scale) |
| OpenAPI 3.0.3 output | **Protobuf** (generates + converts) |
| Mature server generation | **Protobuf** (OpenAPI-first immature for Django) |
| No new dependencies | **Protobuf** (already in Gateway, Controller) |
| REST endpoint documentation | OpenAPI-First or **Protobuf** (with annotations) |
| December 2025 timeline | **Protobuf** (works today) |

---

## Honest Assessment

**Protobuf is not the only option** - OpenAPI-first, GraphQL, Smithy, and Thrift all exist.

**But for AAP's constraints:**
- OpenAPI-first requires building custom Django generator (months)
- GraphQL wrong paradigm (not REST)
- Smithy too new/risky
- Thrift less popular, same learning curve

**Protobuf scores highest** for AAP's polyglot architecture, existing dependencies, and timeline.

---

## References

- **OpenAPI Specification:** https://spec.openapis.org/oas/v3.0.3
- **Protocol Buffers:** https://protobuf.dev/
- **GraphQL:** https://graphql.org/
- **Smithy:** https://smithy.io/
- **Apache Thrift:** https://thrift.apache.org/
- **grpc-gateway:** https://github.com/grpc-ecosystem/grpc-gateway (proto → REST)

