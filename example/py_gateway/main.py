import sys
import os
import json

# Add generated code path
sys.path.insert(0, os.path.abspath("../../gen/python"))

from shared import gateway_user_api_pb2

def main():
    print("=== REST Endpoint Mapping ===")
    print("These proto messages map to REST endpoints via google.api.http annotations:")
    print("  GET    /api/gateway/v1/users/{id} → GetUser")
    print("  GET    /api/gateway/v1/users      → ListUsers")
    print("  POST   /api/gateway/v1/users      → CreateUser")
    print()

    # Example 1: Create a User
    user = gateway_user_api_pb2.User(
        id=1,
        username="alice",
        email="alice@example.com",
        first_name="Alice",
        last_name="Smith",
        is_superuser=False,
        created="2025-10-29T10:00:00Z",
        modified="2025-10-29T10:00:00Z"
    )

    print("=== Example: User Message ===")
    # Convert to dict for JSON serialization
    user_dict = {
        "id": user.id,
        "username": user.username,
        "email": user.email,
        "firstName": user.first_name,
        "lastName": user.last_name,
        "isSuperuser": user.is_superuser,
        "created": user.created,
        "modified": user.modified,
    }
    print(json.dumps(user_dict, indent=2))

    # Example 2: List Users Request
    list_request = gateway_user_api_pb2.ListUsersRequest(
        page=1,
        page_size=25,
        search="alice"
    )

    print("\n=== Example: ListUsers Request ===")
    request_dict = {
        "page": list_request.page,
        "pageSize": list_request.page_size,
        "search": list_request.search,
    }
    print(json.dumps(request_dict, indent=2))

    # Example 3: List Users Response
    list_response = gateway_user_api_pb2.ListUsersResponse(
        count=1,
        next="",
        previous="",
        results=[user]
    )

    print("\n=== Example: ListUsers Response ===")
    response_dict = {
        "count": list_response.count,
        "next": list_response.next,
        "previous": list_response.previous,
        "results": [user_dict]
    }
    print(json.dumps(response_dict, indent=2))

    # Type safety demonstration
    print("\n=== Type Safety Demo ===")
    print(f"User ID: {user.id} (type: int)")
    print(f"Username: {user.username} (type: str)")
    print(f"Is Superuser: {user.is_superuser} (type: bool)")

if __name__ == "__main__":
    main()

