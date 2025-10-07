#!/bin/bash
# Quick test runner - runs only fast unit tests, skips slow integration tests

echo "Running quick test suite (unit tests only)..."
echo "This skips integration tests that are slow due to nmap port scanning."
echo ""

source venv/bin/activate

# Run only unit tests, excluding integration and real server tests
python -m pytest test_vulnerability_scanner.py \
    -v \
    -k "not Integration and not RealHW5Servers and not OutputFormat and not ExceptionHandling and not VerboseMode and not EdgeCases" \
    --tb=short \
    -n auto

echo ""
echo "Quick tests complete! These verify core functionality."
echo "For full validation, manually test with hw5_server as described in TEST_SUMMARY.md"

