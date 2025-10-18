#!/bin/bash

# Task Management API - Complete Test Script
# This script tests all endpoints in sequence

BASE_URL="http://localhost:3000/api"
echo "🚀 Testing Task Management API at $BASE_URL"
echo "================================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠️  Warning: 'jq' is not installed. Install it for better JSON parsing.${NC}"
    echo -e "${YELLOW}   On Windows Git Bash: Download from https://stedolan.github.io/jq/download/${NC}"
    echo -e "${YELLOW}   On Mac: brew install jq${NC}"
    echo -e "${YELLOW}   On Linux: sudo apt-get install jq${NC}"
    echo ""
    
    # Fallback function to extract id without jq
    extract_id() {
        echo "$1" | grep -o '"id":[0-9]*' | grep -o '[0-9]*' | head -1
    }
else
    extract_id() {
        echo "$1" | jq -r '.id' 2>/dev/null
    }
fi

# Function to print test results
print_test() {
    echo -e "\n${BLUE}TEST: $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ PASSED${NC}"
    ((TESTS_PASSED++))
}

print_failure() {
    echo -e "${RED}✗ FAILED${NC}"
    ((TESTS_FAILED++))
}

display_json() {
    if command -v jq &> /dev/null; then
        echo "$1" | jq '.' 2>/dev/null || echo "$1"
    else
        echo "$1"
    fi
}

# 1. Check API Root
print_test "1. GET /api - Check API Root"
response=$(curl -s -w "\n%{http_code}" "$BASE_URL")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "200" ]; then print_success; else print_failure; fi

# 2. Create Task #1
print_test "2. POST /tasks - Create Task with all fields"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Complete project documentation",
    "description": "Write comprehensive README and API docs",
    "dueDate": "2025-12-31T23:59:59Z"
  }')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
TASK_ID_1=$(extract_id "$body")
echo -e "${YELLOW}[DEBUG] Captured TASK_ID_1: $TASK_ID_1${NC}"
if [ "$http_code" = "201" ]; then print_success; else print_failure; fi

# 3. Create Task #2 (minimal fields)
print_test "3. POST /tasks - Create Task with minimal fields"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Review code architecture"
  }')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
TASK_ID_2=$(extract_id "$body")
echo -e "${YELLOW}[DEBUG] Captured TASK_ID_2: $TASK_ID_2${NC}"
if [ "$http_code" = "201" ]; then print_success; else print_failure; fi

print_test "4. POST /tasks - Create Overdue Task (should fail validation)"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Fix critical bug",
    "description": "This task has a past due date",
    "dueDate": "2020-01-01T00:00:00Z"
  }')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "400" ]; then print_success; else print_failure; fi

print_test "4b. POST /tasks - Create Task with near-future due date"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/tasks" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Urgent task",
    "description": "This will be used for overdue testing",
    "dueDate": "2025-10-25T12:00:00Z"
  }')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
TASK_ID_3=$(extract_id "$body")
echo -e "${YELLOW}[DEBUG] Captured TASK_ID_3: $TASK_ID_3${NC}"
if [ "$http_code" = "201" ]; then print_success; else print_failure; fi

# 5. List All Tasks
print_test "5. GET /tasks - List All Tasks"
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/tasks")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "200" ]; then print_success; else print_failure; fi

# 6. List Tasks by Status - PENDING
print_test "6. GET /tasks?status=PENDING - Filter by PENDING"
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/tasks?status=PENDING")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "200" ]; then print_success; else print_failure; fi

# 7. Update Task Status to IN_PROGRESS
print_test "7. PATCH /tasks/$TASK_ID_1/status - Update to IN_PROGRESS"
if [ -z "$TASK_ID_1" ]; then
    echo -e "${RED}ERROR: TASK_ID_1 is empty. Cannot proceed with test.${NC}"
    print_failure
else
    response=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE_URL/tasks/$TASK_ID_1/status" \
      -H "Content-Type: application/json" \
      -d '{"status": "IN_PROGRESS"}')
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    display_json "$body"
    if [ "$http_code" = "200" ]; then print_success; else print_failure; fi
fi

# 8. Update Task Status to DONE
print_test "8. PATCH /tasks/$TASK_ID_2/status - Update to DONE"
if [ -z "$TASK_ID_2" ]; then
    echo -e "${RED}ERROR: TASK_ID_2 is empty. Cannot proceed with test.${NC}"
    print_failure
else
    response=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE_URL/tasks/$TASK_ID_2/status" \
      -H "Content-Type: application/json" \
      -d '{"status": "DONE"}')
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    display_json "$body"
    if [ "$http_code" = "200" ]; then print_success; else print_failure; fi
fi

# 9. List Tasks by Status - IN_PROGRESS
print_test "9. GET /tasks?status=IN_PROGRESS - Filter by IN_PROGRESS"
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/tasks?status=IN_PROGRESS")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "200" ]; then print_success; else print_failure; fi

# 10. List Overdue Tasks
print_test "10. GET /tasks/overdue - List Overdue Tasks"
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/tasks/overdue")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "200" ]; then print_success; else print_failure; fi

# 11. Delete Task
print_test "11. DELETE /tasks/$TASK_ID_1 - Delete Task"
if [ -z "$TASK_ID_1" ]; then
    echo -e "${RED}ERROR: TASK_ID_1 is empty. Cannot proceed with test.${NC}"
    print_failure
else
    response=$(curl -s -w "\n%{http_code}" -X DELETE "$BASE_URL/tasks/$TASK_ID_1")
    http_code=$(echo "$response" | tail -n1)
    if [ "$http_code" = "204" ]; then print_success; else print_failure; fi
fi

# 12. Verify Task Deleted
print_test "12. GET /tasks - Verify Task Deleted"
response=$(curl -s -w "\n%{http_code}" "$BASE_URL/tasks")
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "200" ]; then print_success; else print_failure; fi

# Error Cases
echo -e "\n${BLUE}=== Testing Error Cases ===${NC}"

# 13. Create Task without title
print_test "13. POST /tasks - Missing required field (should fail)"
response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/tasks" \
  -H "Content-Type: application/json" \
  -d '{"description": "Missing title"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "400" ]; then print_success; else print_failure; fi

# 14. Update with invalid status
print_test "14. PATCH /tasks/$TASK_ID_2/status - Invalid status (should fail)"
if [ -z "$TASK_ID_2" ]; then
    echo -e "${RED}ERROR: TASK_ID_2 is empty. Cannot proceed with test.${NC}"
    print_failure
else
    response=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE_URL/tasks/$TASK_ID_2/status" \
      -H "Content-Type: application/json" \
      -d '{"status": "INVALID_STATUS"}')
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    display_json "$body"
    if [ "$http_code" = "400" ]; then print_success; else print_failure; fi
fi

# 15. Update non-existent task
print_test "15. PATCH /tasks/99999/status - Non-existent task (should fail)"
response=$(curl -s -w "\n%{http_code}" -X PATCH "$BASE_URL/tasks/99999/status" \
  -H "Content-Type: application/json" \
  -d '{"status": "DONE"}')
http_code=$(echo "$response" | tail -n1)
body=$(echo "$response" | head -n-1)
display_json "$body"
if [ "$http_code" = "404" ]; then print_success; else print_failure; fi

# Summary
echo -e "\n${BLUE}================================================${NC}"
echo -e "${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo -e "${BLUE}================================================${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi
