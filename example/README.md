# Examples

| Directory | Language | Purpose |
|-----------|----------|---------|
| `go_logging/` | Go | Basic logging (minimal) |
| `py_logging/` | Python | Basic logging (minimal) |
| `go_otlp/` | Go | OpenTelemetry OTLP format logging |
| `py_google/` | Python | Logging with Google MessageToDict library |
| `go_gateway/` | Go | Gateway User API (includes REST annotations) |
| `py_gateway/` | Python | Gateway User API (includes REST annotations) |
| `go_awx/` | Go | AWX Job Template API |
| `py_awx/` | Python | AWX Job Template API |

**Both Gateway and AWX demos** include REST annotations (google.api.http) - generate OpenAPI 3.0.3 with full REST endpoints.

**Run all:** `make run-all`

