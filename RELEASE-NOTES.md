# Release Notes - proto-example-log-api

**Date:** November 13, 2025
**Branch:** open-api-demo
**Version:** 2.0 (API demonstrations added)

---

## What's New

### **Major Additions**

**1. AWX Job Template API**
- Real Controller API (job execution - most commonly used)
- Proto with REST annotations
- Generates OpenAPI with full REST paths: GET/POST /api/v2/job_templates

**2. REST Annotations (google.api.http)**
- Both Gateway and AWX protos include REST mappings
- Generated OpenAPI has proper REST endpoints (not just schemas)
- OpenAPI 3.0.3 conversion with full REST paths

**3. Go Shared Library (protohelper)**
- Dynamically reads REST endpoints from proto metadata
- Uses protobuf reflection
- Both Go examples use shared code

**4. Alternatives Documentation**
- README-Alternatives.md compares Protobuf vs OpenAPI-First vs GraphQL vs Smithy vs Thrift
- Honest assessment of trade-offs

### **Improvements**

**5. Latest Tooling**
- protoc 33.0 (was 26.0)
- All Go plugins @latest
- November 2025 current versions

**6. Verified AAP Dependencies**
- Gateway: Confirmed runs gRPC server (grpcio==1.68.1)
- Controller: Has protobuf==6.32.1, grpcio==1.75.1 for OpenTelemetry
- Both: Use K8s client libraries (protobuf-based)

**7. Renamed Examples**
- `go/` → `go_logging/` (clarity)
- `py/` → `py_logging/` (clarity)

**8. ANSTRAT-901 Context**
- Added parent initiative (platform-wide API-first)
- Shows proto addresses broader goals

---

## What's Generated

**From proto source:**
- Go code (gRPC client/server)
- Python code (gRPC client/server)
- Swagger 2.0 with REST paths
- OpenAPI 3.0.3 (via conversion)

**REST endpoints:**
- Gateway: `/api/gateway/v1/users` (GET, POST)
- AWX: `/api/v2/job_templates` (GET), `/api/v2/job_templates/{id}/launch` (POST)

---

## Technical Details

**Dependencies:**
- googleapis (auto-cloned for google.api.http annotations)
- Go workspace (go.work) for shared protohelper library
- protoc 33.0 + latest Go plugins

**Proto files:**
- `gateway_user_api.proto` (158 lines) - Gateway API with REST
- `awx_job_template.proto` (262 lines) - AWX API with REST
- `gateway_user_api_with_ai.proto` (410 lines) - Reference: full AI extensions

**Examples:**
- 8 total (4 Go, 4 Python)
- Gateway/AWX Go examples use protohelper (dynamic REST display)
- Gateway/AWX Python examples show REST in comments

---

## Documentation

**Updated:**
- README.md - Added ANSTRAT-901, stronger AAP dependency argument
- README-Open-API.md - REST paths in commands, output folders
- README-Structured-Logging.md - Example paths updated
- example/README.md - Both APIs have REST annotations

**New:**
- README-Alternatives.md (155 lines) - Alternatives comparison
- CLAUDE-Knowledge-gowork.md (369 lines) - Go workspace learnings (reference)

**Total:** 674 lines (user-facing), no duplication

---

## Breaking Changes

**None** - All original examples still work.

**Renamed directories** (update paths if you referenced them):
- `example/go/` → `example/go_logging/`
- `example/py/` → `example/py_logging/`

---

## Migration Guide

**For existing users:**

**If you cloned before Nov 13, 2025:**
```bash
git pull
make clean
make gen-all
make run-all
```

**New files to .gitignore:**
```
third_party/googleapis/
go.work
go.work.sum
```

---

## What This Demonstrates

✅ **REST from proto** - google.api.http annotations generate full REST endpoints
✅ **OpenAPI 3.0.3** - With real AAP REST paths
✅ **Real Controller API** - AWX Job Template (production API)
✅ **Proto reflection** - Go examples dynamically read REST from proto metadata
✅ **AAP already uses proto** - Gateway (gRPC), Controller (OTEL), K8s clients
✅ **Alternatives addressed** - Honest comparison with other approaches

---

## For ANSTRAT-1738

**Addresses:**
- Controller Swagger 2.0 blocker (Tami) - Shows migration path
- Contract-first impossible (Alan) - Proto enforces it
- Breaking changes (Pablo) - Field numbers prevent
- Polyglot AAP (architecture) - K8s client pattern proven

**Supports:**
- ANSTRAT-901 (Platform API-first)
- ANSTRAT-1738 (OpenAPI standardization)
- ANSTRAT-1646 (MCP needs OpenAPI)
- ANSTRAT-505 (BYOLLM needs API specs)

---

## Next Steps

**Ready to:**
1. Share with coalition (Andrew, Pablo, Ron)
2. Present to teams
3. Reference in proposals
4. Use as implementation proof

**Repository:** https://github.com/arrestle/proto-example-log-api

