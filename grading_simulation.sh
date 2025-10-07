#!/bin/bash
# Grading Simulation Script - Tests exactly what the graders will test
# Author: Yann C. Lopez (with AI assistance)

echo "========================================="
echo "CS1060 HW5 GRADING SIMULATION"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

POINTS=0
MAX_POINTS=50

# Test 1: SQL Injection (10 points)
echo "TEST 1: SQL Injection Attack (10 points)"
echo "-----------------------------------------"
echo "Running: curl -X POST https://cat-hw4.vercel.app/county_data -H \"Content-Type: application/json\" -d @attack.json"
ROWS=$(curl -X POST https://cat-hw4.vercel.app/county_data -H "Content-Type: application/json" -d @attack.json 2>/dev/null | python3 -c "import sys, json; data = json.load(sys.stdin); print(len(data))" 2>/dev/null)

if [ "$ROWS" == "100" ]; then
    echo -e "${GREEN}✓ PASS: Returns exactly 100 rows (LIMIT 100 verified)${NC}"
    POINTS=$((POINTS + 10))
else
    echo -e "${RED}✗ FAIL: Expected 100 rows, got $ROWS${NC}"
fi
echo ""

# Test 2: Scanner with standard hw5_server (20 points)
echo "TEST 2: Standard hw5_server (20 points)"
echo "-----------------------------------------"
echo "Starting HTTP server on port 8080 (admin:admin)..."
python3 hw5_server-main/http_server.py --port 8080 --username admin --password admin &>/dev/null &
HTTP_PID=$!
sleep 1

echo "Starting SSH server on port 2222 (skroob:12345)..."
python3 hw5_server-main/ssh_server.py --port 2222 --username skroob --password 12345 &>/dev/null &
SSH_PID=$!
sleep 2

echo "Running vulnerability scanner..."
OUTPUT=$(python3 vulnerability_scanner.py 2>/dev/null)

# Check for HTTP vulnerability
if echo "$OUTPUT" | grep -q "http://admin:admin@127.0.0.1:8080 success"; then
    echo -e "${GREEN}✓ Found HTTP vulnerability: admin:admin@127.0.0.1:8080${NC}"
    POINTS=$((POINTS + 10))
else
    echo -e "${RED}✗ FAIL: Did not find HTTP vulnerability with correct format${NC}"
    echo "Expected: http://admin:admin@127.0.0.1:8080 success"
fi

# Check for SSH vulnerability  
if echo "$OUTPUT" | grep -q "ssh://skroob:12345@127.0.0.1:2222"; then
    echo -e "${GREEN}✓ Found SSH vulnerability: skroob:12345@127.0.0.1:2222${NC}"
    POINTS=$((POINTS + 10))
else
    echo -e "${RED}✗ FAIL: Did not find SSH vulnerability with correct format${NC}"
    echo "Expected: ssh://skroob:12345@127.0.0.1:2222 success"
fi

# Cleanup
kill $HTTP_PID $SSH_PID 2>/dev/null
sleep 1
echo ""

# Test 3: Modified servers with different credentials and responses (20 points)
echo "TEST 3: Modified Servers (20 points)"
echo "-----------------------------------------"
echo "Starting HTTP server on port 8081 (root:abc123) with response 'graded'..."
python3 hw5_server-main/http_server.py --port 8081 --username root --password abc123 &>/dev/null &
HTTP_PID=$!
sleep 1

echo "Starting SSH server on port 2223 (admin:admin) with response 'graded'..."  
python3 hw5_server-main/ssh_server.py --port 2223 --username admin --password admin &>/dev/null &
SSH_PID=$!
sleep 2

echo "Running vulnerability scanner..."
OUTPUT=$(python3 vulnerability_scanner.py 2>/dev/null)

# Check for modified HTTP
if echo "$OUTPUT" | grep -q "http://root:abc123@127.0.0.1:8081"; then
    echo -e "${GREEN}✓ Found modified HTTP: root:abc123@127.0.0.1:8081${NC}"
    POINTS=$((POINTS + 10))
else
    echo -e "${RED}✗ FAIL: Did not find modified HTTP vulnerability${NC}"
    echo "Expected: http://root:abc123@127.0.0.1:8081 [any response]"
fi

# Check for modified SSH
if echo "$OUTPUT" | grep -q "ssh://admin:admin@127.0.0.1:2223"; then
    echo -e "${GREEN}✓ Found modified SSH: admin:admin@127.0.0.1:2223${NC}"
    POINTS=$((POINTS + 10))
else
    echo -e "${RED}✗ FAIL: Did not find modified SSH vulnerability${NC}"
    echo "Expected: ssh://admin:admin@127.0.0.1:2223 [any response]"
fi

# Cleanup
kill $HTTP_PID $SSH_PID 2>/dev/null
sleep 1
echo ""

# Summary
echo "========================================="
echo "GRADING SUMMARY"
echo "========================================="
echo ""
echo "Test 1 (SQL Injection):        $([ $POINTS -ge 10 ] && echo "${GREEN}10/10${NC}" || echo "${RED}0/10${NC}")"
echo "Test 2 (Standard Servers):     $([ $POINTS -ge 30 ] && echo "${GREEN}20/20${NC}" || echo "${RED}$((POINTS - 10))/20${NC}")"
echo "Test 3 (Modified Servers):     $([ $POINTS -eq 50 ] && echo "${GREEN}20/20${NC}" || echo "${RED}$((POINTS - 30))/20${NC}")"
echo ""
echo -e "TOTAL SCORE: ${GREEN}$POINTS/$MAX_POINTS${NC}"
echo ""

if [ $POINTS -eq 50 ]; then
    echo -e "${GREEN}★★★ PERFECT SCORE! READY FOR SUBMISSION ★★★${NC}"
else
    echo -e "${RED}⚠ WARNING: Not all tests passed. Review failures above.${NC}"
fi
echo ""

