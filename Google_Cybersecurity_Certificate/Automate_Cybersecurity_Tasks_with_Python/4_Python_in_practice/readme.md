# **Python in Practice**

This module focuses on applying Python in real-world cybersecurity scenarios, especially for automating common tasks performed by security professionals. You'll work with files such as security logs, learn to extract useful data from them, and develop skills to identify and fix errors in your code.

As a security analyst, you’ll regularly handle large log files that are difficult to read manually. Python can help automate this process and make your workflow more efficient.

## **Learning Objectives**

- Use Python to automate cybersecurity tasks
- Open and read files with Python
- Parse files to extract targeted information
- Improve your ability to troubleshoot and fix errors in your code by recognizing common Python error types and learning how to resolve them

Here’s a cleaned-up and organized **Markdown summary** for **Section 1: Python for Automation** of **Module 4: Python in Practice**, formatted to your specifications:

---

## **Python for Automation**

Automation is essential in cybersecurity to efficiently monitor systems, detect unusual behavior, and apply security policies at scale. Python is a powerful tool for automating such tasks. This section explores how to use Python to automate real-world security workflows and introduces how automation supports CI/CD pipelines through DevSecOps practices.

### Real-World Automation Use Cases

#### 1. Login Timeout Policy

- **Scenario:** Healthcare company with sensitive data
- **Goal:** Lock out users who take more than 3 minutes to log in (to prevent password guessing)
- **Solution:** Use Python to track username entry and time until correct password entry.

#### 2. Suspicious Login Monitoring

- **Scenario:** Law firm under attack
- **Goal:** Detect login anomalies such as odd hours, foreign locations, or dual IP usage.
- **Solution:** Use Python to check timestamps, IP addresses, and locations for each login.

#### 3. Failed Login Attempts Detection

- **Scenario:** Organization enhancing login security
- **Goal:** Flag users with 3+ failed login attempts within 30 minutes.
- **Solution:** Use Python to parse log files and apply logic to flag suspicious activity.

---

## **Python in CI/CD Automation (DevSecOps)**

- DevSecOps means integrating **security into development and operations** from the start.
- Python allows for automation of security checks **inside the pipeline**.

### Why Use Python for CI/CD Security Tasks?

- **Faster releases:** Python automates checks without slowing down deployment.
- **Early detection:** Finds vulnerabilities during development, when they’re easier to fix.
- **Consistency:** Scripts apply checks the same way every time.
- **Reduced workload:** Frees teams to focus on complex issues.
- **Culture of security:** Makes security a shared responsibility.

### CI/CD Security Tasks to Automate with Python

- **Security Testing**
  - **SAST:** Launch tools, read results, halt builds if critical issues found.
  - **DAST:** Run test-environment scans and collect results.
  - **SCA:** Scan dependencies, set policies, generate reports.
- **Vulnerability Scanning:** Containers, infrastructure, and pipeline components.
- **Compliance Checks:** Validate against secure coding and infrastructure policies.
- **Secrets Management:** Prevent credentials in code and fetch secrets securely.
- **Policy Enforcement:** Stop pipeline if rules are broken.

#### Example: Count Logins for Flagged User

**Problem:** Investigate how many times a flagged user logged in today.

**Python Solution:**

- Use a `for` loop to go through each login.
- Apply an `if` statement to check if login matches the flagged user.
- Use a `counter` variable to tally matches.
- Wrap logic in a **function** for reuse.

```python
def count_user_logins(username, login_list):
    count = 0
    for login in login_list:
        if login == username:
            count += 1
    return count
```

### Python CI/CD Tools

- Works with Jenkins, GitLab CI, CircleCI, etc.
- Use Python to:
  - Run automated scripts
  - Call APIs for CI/CD and security tools
  - Use add-ons/extensions for integration

### Python Secures More Than Just Code

- **Set Up Environments:** Automate secure staging/test setups.
- **Code Quality Checks:** Use linters and syntax checkers.
- **Secure Releases:** Enforce best practices for production rollouts.

---

## **Python Components for Automation**

To automate security tasks, these core Python components are essential:

### Variables

- Store data for reuse across automation tasks

```python
username = "user123"
```

### Conditional Statements

- Execute logic only if certain conditions are met

```python
if login_attempts > 3:
    flag_user()
```

### Iterative Statements

- Repeat tasks without rewriting code
- `for` and `while` loops automate repetition

```python
for user in user_list:
    print(user)
```

### Functions

- Reusable code blocks that simplify complex tasks

```python
def count_logins(user, logins):
    return logins.count(user)
```

### String Techniques

- Strings are common in logs; Python helps manipulate them

```python
username[0:3]  # slicing
len(username)  # length
```

### List Techniques

- Useful for managing data like login attempts

```python
logins.append("user123")
logins.remove("user456")
```

---

## **Working with Files**

Security logs are often stored in `.txt` or `.csv` files.

- `.csv`: Comma-separated values (structured)
- `.txt`: Flexible formatting (often unstructured)

Python can read, parse, and structure data from both formats, which is vital for log analysis and automation.

### 📁 Why Working with Files Matters for Security Analysts

Security professionals often review log files, which can contain thousands of entries. Automating file reading and parsing with Python can significantly increase efficiency when analyzing:

- Login attempts (e.g., brute force detection)
- Application failures (e.g., post-breach analysis)

### 📖 Opening and Reading Files in Python

#### 🔑 `with` Statement

Manages external resources like files and ensures proper cleanup (auto-closes files). Preferred over manually opening and closing files.

```python
with open("update_log.txt", "r") as file:
    updates = file.read()
print(updates)
```

- `"r"`: read mode (default if omitted)
- `"w"`: write mode (overwrites file)
- `"a"`: append mode (adds to end of file)

#### 📌 File Paths

- Use relative paths if the file is in the same directory.
- Use absolute paths if the file is in a different location.

```python
with open("/home/analyst/logs/access_log.txt", "r") as file:
    logs = file.read()
```

### 🖊️ Writing and Appending to Files

#### `write()` Method

Writes a string to a file. Must be used within a `with` block to ensure data is properly saved.

- `"w"` creates or overwrites a file.
- `"a"` appends data without deleting existing content.

```python
line = "jrafael,192.168.243.140,4:56:27,True"
with open("access_log.txt", "a") as file:
    file.write(line)
```

### 🧩 Parsing Files in Python

- The process of converting data into a more readable or usable format.
  - Useful for both programmatic processing and human interpretation.
  - Essential when working with file contents.

#### `read()` ➝ Converts file content into a string

- **Purpose**: Reads the entire content of a file and returns it as a single string.
- **Syntax**: `file.read(size)`

  - `size` (optional): Number of bytes to read. If omitted, reads the entire file.
- **Example**:

  ```python
  with open("example.txt", "r") as file:
      content = file.read()
  print(content)
  ```
- **Usage with files**:

  - Ideal for small files where the entire content can be loaded into memory.
  - Combine with string methods like `.split()` for further processing.

##### Practical Example: Reading a Log File

```python
with open("access_log.txt", "r") as file:
    log_data = file.read()
    log_entries = log_data.split("\n")  # Split into lines for processing

print(log_entries)
```

- **Key Note**: Avoid using `read()` for very large files, as it loads the entire content into memory.

#### 🔍 `.split()` Method

- **Purpose**: Converts a string into a list.
- **Syntax**: `string.split(separator)`

  - If no separator is provided, Python uses whitespace characters (spaces, tabs, newlines).
- **Example**:

  ```python
  approved_users = "elarson,bmoreno,tshah"
  approved_users = approved_users.split(",")
  # Result: ['elarson', 'bmoreno', 'tshah']
  ```
- **Usage with Files**:

  ```python
  with open("update_log.txt", "r") as file:
      updates = file.read()
  updates = updates.split()
  ```

---

#### 🔗 `.join()` Method

- **Purpose**: Converts a list into a single string.
- **Syntax**: `"separator".join(list)`
- **Example**:

  ```python
  approved_users = ["elarson", "bmoreno", "tshah"]
  approved_users = ",".join(approved_users)
  # Result: "elarson,bmoreno,tshah"
  ```
- **Usage with Files**:

  ```python
  updates = " ".join(updates)
  with open("update_log.txt", "w") as file:
      file.write(updates)
  ```

Used to break a long string (e.g., contents of a log) into manageable chunks.

#### Example: Split file contents by line (newline is whitespace by default)

```python
with open("user_log.txt", "r") as file:
    content = file.read()
    usernames = content.split()

print(usernames)
```

---

#### 🧪 Practical Application: Suspicious Login Detector

**Problem**: Detect if a user has had 3+ failed login attempts using a log file (one username per line).

**Solution Strategy**:

1. Read the file.
2. Parse the file contents into a list using `.split()`.
3. Count occurrences of the username using a loop.
4. Trigger alert if count ≥ 3.

**Python Implementation**:

```python
def login_check(login_list, current_user):
    counter = 0
    for i in login_list:
        if i == current_user:
            counter += 1
    if counter >= 3:
        print("Account locked due to suspicious activity.")
    else:
        print("Login permitted.")
```

**Usage Example**:

```python
with open("login_log.txt", "r") as file:
    usernames = file.read().split()

login_check(usernames, "eraab")
```

---

## **Debug Python Code**

As a security analyst, debugging is an essential skill. Errors in code can consume a lot of time, and being able to troubleshoot effectively ensures that your Python scripts run smoothly. In this section, we cover the three types of errors you'll encounter and strategies for debugging them.

### Types of Errors

There are three main types of errors in Python:

- **Syntax Errors**: Occur when the code violates Python's language rules.
- **Logic Errors**: Produce unintended results but do not generate error messages.
- **Exceptions**: Happen when Python encounters an issue that prevents the code from running, even though the syntax is correct.

#### Syntax Errors

Syntax errors occur when the code contains invalid Python syntax. Examples include missing colons after function headers or unmatched parentheses. When a syntax error occurs, Python will provide an error message indicating the location of the issue.

Example:

```python
# Syntax Error: Missing closing quotation mark
message = "You are debugging a syntax error
print(message)
```

Error: `SyntaxError: EOL while scanning string literal`.

**Fix**: Add the missing quotation mark.

##### Common Syntax Errors

- Missing colons, parentheses, or quotation marks.
- Incorrect indentation (leads to `IndentationError`).

#### Logic Errors

Logic errors occur when the code executes without generating an error, but the output is not as expected. These errors are harder to spot because they don't trigger error messages. A typical example is using the wrong comparison operator in a condition.

Example:

```python
login_attempts = 5
if login_attempts >= 5:
    print("User has not reached maximum login attempts.")
else:
    print("User has reached maximum login attempts.")
```

Error: The message printed is incorrect because the condition should be `login_attempts < 5`.

##### Strategies to Identify Logic Errors

- **Print Statements**: Insert print statements at various locations to track the flow of execution and values of variables.
- **Debuggers**: Use breakpoints to halt execution at certain points and inspect variable values.

#### Exceptions

Exceptions occur when Python can't execute a piece of code due to an issue such as invalid data types or missing variables. These errors are raised even though the syntax is valid.

Common Exceptions:

- `NameError`: Occurs when a variable is not defined.
- `IndexError`: Happens when accessing an index that doesn't exist in a sequence.
- `TypeError`: Happens when performing operations on incompatible data types.
- `FileNotFoundError`: Occurs when a file is not found.

Example:

```python
username = "elarson"
month = "March"
total_logins = 75
failed_logins = 18
print("Login report for", username, "in", month)
print("Total logins:", total_logins)
print("Failed logins:", failed_logins)
print("Unusual logins:", unusual_logins)  # This causes NameError
```

Error: `NameError: name 'unusual_logins' is not defined`.

Fix: Assign a value to `unusual_logins`.

### Debugging Strategies

#### 1. Use Print Statements

Print statements are helpful for debugging logic errors by showing where the program is reaching and the values of variables at various points.

Example:

```python
new_users = ["sgilmore", "bmoreno"]
approved_users = ["bmoreno", "tshah", "elarson"]

def add_users():
    for user in new_users:
        print("line 5 - inside for loop")
        if user in approved_users:
            print("line 7 - inside if statement")
            print(user, "already in list")
        print("line 9 - before .append method")
        approved_users.append(user)

add_users()
print(approved_users)
```

This will help identify where the code might be adding duplicate users.

#### 2. Use a Debugger

A debugger allows you to set breakpoints and inspect variables as the code runs. This helps to locate and fix errors more efficiently.

## **Example Code to Fix**

```python
def parse_log_line(line):
    parsed_line = []
    status_code = int(line.split()[0])  # Get status code from the log line
    if status_code != 200:
        parsed_line.append(line)
    else:
        print("No parsing needed for status code 200.")
    return parsed_line

log_line = "200 OK some text"
result = parse_log_line(log_line)
print(result)  # Expecting "No parsing needed for status code 200."
```

---

## **Key Takeaways**

- **Python automation is vital** for modern cybersecurity tasks.
- CI/CD pipelines benefit from Python-driven security automation.
- Mastering **variables, conditionals, loops, functions, strings, lists, and file handling** enables powerful automation workflows.
- With these tools, security analysts can scale defenses, save time, and reduce human error.
- Use `with open()` for safe and efficient file operations.
- Choose mode: `"r"` (read), `"w"` (write), or `"a"` (append).
- Use `.read()` to load content and `.write()` to save it.
- `.split()` = string ➝ list
- `.join()` = list ➝ string
- Parsing logs helps automate security tasks like identifying suspicious activity.
- Essential for reading, processing, and writing file data.
- **Syntax Errors**: Fixable through error messages.
- **Logic Errors**: Require debugging techniques like print statements and debuggers.
- **Exceptions**: Handled by ensuring variables are defined and data types are correct.
- Debuggers and print statements are crucial tools for identifying and resolving issues in code.
