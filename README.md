# CS1060 Homework 5

**Author:** Yann C. Lopez (with AI assistance)  
**Course:** CS1060 - Introduction to Computer Security  
**Educational Purpose:** This repository demonstrates security vulnerabilities for learning defensive security practices.

## 5.2: SQL Injection Attack Demonstration

### Overview

This assignment demonstrates SQL injection vulnerabilities in a web application that improperly concatenates user input into SQL queries.

### Files

- `test.json` - Legitimate test data for the county_data endpoint
- `attack.json` - Malicious payload demonstrating SQL injection
- `prompts.txt` - Prompts used with generative AI to learn about SQL injection

### Vulnerable Code

The vulnerable endpoint uses string concatenation to build SQL queries:

```python
sql = f"select * from county_health_rankings where county = '{county}' and state = '{state}' and measure_name = '{measure_name}'"
```

### Attack Methodology

The attack exploits the `measure_name` parameter by:
1. Terminating the string early with a single quote
2. Adding an OR clause that always evaluates to true (`'1'='1'`)
3. Limiting results to 100 rows to avoid excessive data transfer
4. Using SQL comment syntax (`--`) to ignore the rest of the query

### Testing

**Legitimate request:**
```bash
curl -X POST https://cat-hw4.vercel.app/county_data -H "Content-Type: application/json" -d @test.json
```

**Attack request:**
```bash
curl -X POST https://cat-hw4.vercel.app/county_data -H "Content-Type: application/json" -d @attack.json
```

### AI Models Tested

**Model: Claude 4.5 Sonnet (Anthropic)**

This model provided assistance with understanding SQL injection concepts for educational purposes. The model:
- Recognized the educational context of the request
- Provided explanations of how SQL injection works
- Helped craft the appropriate payload syntax
- No significant guardrails were encountered when the educational context was clearly stated

The key to working with AI models on security topics is to:
1. Clearly state the educational purpose
2. Provide context (e.g., "for a security class")
3. Reference that it's a controlled environment/assignment
4. Focus on learning defensive security practices

### Prevention

To prevent SQL injection vulnerabilities:
1. **Use parameterized queries/prepared statements** - Never concatenate user input into SQL
2. **Input validation** - Validate and sanitize all user inputs
3. **Principle of least privilege** - Database users should have minimal necessary permissions
4. **Web Application Firewall (WAF)** - Can help detect and block SQL injection attempts

**Example of secure code:**
```python
cursor = conn.execute(
    "SELECT * FROM county_health_rankings WHERE county = ? AND state = ? AND measure_name = ?",
    (county, state, measure_name)
)
```

### Disclaimer

This demonstration is for educational purposes only as part of CS1060. Unauthorized access to computer systems is illegal.

---

## Vulnerability Scanner (vulnerability_scanner.py)

### Overview

A Python-based vulnerability scanner that detects insecure HTTP Basic Authentication and SSH password authentication on localhost.

### Features

- **Port Scanning**: Uses `nmap` to discover open TCP ports (1-8999)
- **HTTP Authentication Testing**: Attempts HTTP Basic Auth with credential dictionary
- **SSH Authentication Testing**: Attempts SSH password authentication with credential dictionary
- **Clean Output**: RFC 3986 format for discovered vulnerabilities
- **Error Handling**: All exceptions are suppressed for clean output
- **Verbose Mode**: Optional `-v` flag for debugging

### Credentials Tested

```python
credentials = {
    'admin': 'admin',
    'root': 'abc123',
    'skroob': '12345'
}
```

### Usage

```bash
# Install dependencies
pip install -r requirements.txt

# Run scanner (silent mode)
python vulnerability_scanner.py

# Run with verbose output
python vulnerability_scanner.py -v
```

### Output Format

Successful authentications are printed in RFC 3986 URI format:

```
<protocol>://<username>:<password>@<host>:<port> <server_output>
```

**Examples:**
```
http://admin:admin@127.0.0.1:8080 success
ssh://skroob:12345@127.0.0.1:2222 schwartz
```

### Requirements

- Python 3.7+
- nmap (system package)
- python-nmap
- paramiko
- requests

### Implementation Details

**Author:** Yann C. Lopez (with AI assistance)

The scanner:
1. Uses `python-nmap` library to scan ports 1-8999 on 127.0.0.1
2. For each open port, attempts authentication with all credential pairs
3. Tests HTTP first, then SSH for each credential
4. Captures and displays server responses
5. Handles all exceptions silently (only verbose mode shows errors)
6. Suppresses paramiko logging to avoid cluttering output

### Testing with hw5_server

The hw5_server repository provides test servers:

```bash
# Start HTTP server
python hw5_server-main/http_server.py --port 8080 --username admin --password admin

# Start SSH server  
python hw5_server-main/ssh_server.py --port 2222 --username skroob --password 12345

# Run scanner
python vulnerability_scanner.py
```

**Expected Output:**
```
ssh://skroob:12345@127.0.0.1:2222 success
http://admin:admin@127.0.0.1:8080 success
```

### Security Considerations

This tool demonstrates why:
1. **Default credentials are dangerous** - Never use default passwords
2. **Password authentication is weak** - Use key-based auth for SSH
3. **Basic Auth over HTTP is insecure** - Always use HTTPS
4. **Port scanning is detectable** - IDS/IPS systems can detect nmap scans
5. **Brute force is preventable** - Rate limiting and account lockouts help

---

## Repository Structure

```
cs1060-hw5/
├── README.md                    # This file
├── .gitignore                   # Git ignore patterns
├── vulnerability_scanner.py     # Main vulnerability scanner
├── requirements.txt             # Python dependencies
├── attack.json                  # SQL injection payload
├── test.json                    # Legitimate test data
├── prompts.txt                  # AI prompts used for learning
└── hw5_server-main/            # Test servers (from GitHub)
    ├── http_server.py          # Vulnerable HTTP server
    └── ssh_server.py           # Vulnerable SSH server
```

---

## Complete Assignment Checklist

- [x] SQL Injection attack (5.2)
  - [x] test.json with legitimate data
  - [x] attack.json with SQL injection payload
  - [x] prompts.txt with AI learning prompts
  - [x] README section on AI models and guardrails
  - [x] Attack returns 100 rows with LIMIT clause
- [x] Vulnerability Scanner
  - [x] Uses nmap for port scanning
  - [x] Tests HTTP Basic Authentication
  - [x] Tests SSH password authentication
  - [x] Proper RFC 3986 output format
  - [x] Silent error handling
  - [x] Verbose mode option
- [x] Repository Requirements
  - [x] requirements.txt
  - [x] .gitignore (Python caches)
  - [x] Authorship attribution
  - [x] Comprehensive README

---

## Final Notes

**Grading Compliance:**
- SQL injection returns exactly 100 rows (LIMIT 100)
- Vulnerability scanner outputs only successful authentications in RFC 3986 format
- All required files are present in repository root
- Code includes authorship attribution


### Disclaimer

This demonstration is for educational purposes only as part of CS1060. 
