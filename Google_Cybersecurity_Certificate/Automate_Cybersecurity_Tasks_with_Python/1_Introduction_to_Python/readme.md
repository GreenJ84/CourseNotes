# **Introduction to Python**

This module introduces the Python programming language and its applications in cybersecurity. You will learn fundamental programming concepts, including data types, variables, conditional statements, and iterative statements.

Python, like any language, consists of structured instructions that allow communication with a computer. In this module, you will explore the fundamental components of Python programming, understand why security analysts use Python, and build a strong foundation for writing and executing Python scripts.

By automating repetitive tasks, Python enhances productivity, reduces human error, and allows security professionals to focus on problem-solving and engineering challenges. Let’s begin programming in Python!

## **Learning Objectives**

By the end of this module, you will be able to:

- Explain how Python is used in cybersecurity.
- Describe and work with various data types in Python.
- Use variables in Python code.
- Write conditional statements to incorporate logic into programs.
- Implement iterative statements to automate repetitive tasks.

## **Introduction to Python Programming in Cybersecurity**

Security professionals use programming to create instructions that automate tasks and enhance efficiency. Python, a general-purpose language, is widely used in cybersecurity to automate security tasks, analyze data, and improve workflow efficiency.

### Why Python?

Python is chosen for cybersecurity because:

- It automates repetitive tasks, reducing manual effort.
- It is easy to read and write, resembling human language.
- It has extensive built-in libraries for various cybersecurity tasks.
- It has strong community support and documentation.

### How Python is Used in Cybersecurity

Python helps security analysts by automating and streamlining tasks such as:

- **Log analysis** – Quickly filtering and extracting useful information from logs.
- **Malware analysis** – Identifying and analyzing malicious software patterns.
- **Access control management** – Automating user access and permissions.
- **Intrusion detection** – Identifying unauthorized activities in networks.
- **Compliance checks** – Ensuring security policies are enforced.
- **Network scanning** – Detecting vulnerabilities and threats.

### Programming Fundamentals

Computers process instructions using binary numbers (0s and 1s). Programming languages like Python simplify this process, allowing users to write readable code. Python programs must be translated into machine instructions using an **interpreter**, which executes code line by line.

#### Python Versions

- Python has multiple versions with differences in syntax.
- This course uses **Python 3**, which is the latest version.

### Python Environments

Python can be run in different environments, including:

#### 1. Notebooks

- Online interfaces for writing, storing, and running Python code.
- Contain two types of cells:
  - **Code cells** – Used for writing and running Python code.
  - **Markdown cells** – Used for writing formatted text and documentation.
- Examples: **Jupyter Notebook, Google Colaboratory (Google Colab).**

#### 2. Integrated Development Environments (IDEs)

- Software applications that assist with writing, debugging, and organizing code.
- Provide tools like syntax highlighting and error detection.

#### 3. Command Line Interface (CLI)

- A text-based interface for running Python scripts directly.
- Allows access to system files and directories through commands.

## **Core Python Components**

In this section, you'll explore essential Python components—data types and variables—that form the backbone of programming in cybersecurity. Understanding these elements helps you write clear, efficient, and error-free code.

### Data Types

Python categorizes data into various types. Think of data types like kitchen ingredients: each type has its own way of being handled.

#### Primary Data Types

- **String**:
  An ordered sequence of characters enclosed in quotation marks.

  ```python
    # Example:
    print("Hello Python!")
  ```

  *Note: Omitting quotation marks causes syntax errors.*

- **Integer**:
  Whole numbers without a decimal point.

  ```python
  # Example:
  print(5)
  ```

- **Float**:
  Numbers with a decimal point, used for more precise calculations.

  ```python
  # Example:
  print(1.2 + 2.8) outputs 4.0
  ```

  *Note: The `/` operator returns a float, while `//` rounds down to the nearest whole number.*

- **Boolean**:
  Represents one of two values: `True` or `False`.

  ```python
  # Example:
  print(9 > 10) outputs False
  ```

- **List**:
  An ordered collection of items enclosed in square brackets.

  ```python
  # Example:
  print(["user1", "user2", "user3"])
  ```

#### Additional Data Types

- **Tuple**:
  An immutable (unchangeable) collection of items enclosed in parentheses.

  ```python
  # Example:
  ("item1", "item2", "item3")
  ```

- **Dictionary**:
  A collection of key-value pairs enclosed in curly braces.

  ```python
  # Example:
  {1: "East", 2: "West"}
  ```

- **Set**:
  An unordered collection of unique items enclosed in curly braces.

  ```python
  # Example:
  {"user1", "user2", "user3"}
  ```

### Variables

Variables are like labeled containers that store data for later use in your code.

#### Key Concepts

- **Assignment**:
  Creating a variable and giving it a value.

  ```python
  # Example:
  username = "nzhao"
  ```

- **Reassignment**:
  Changing the value stored in a variable while keeping the same name.

  ```python
  # Example:
  username = "nzhao"
  username = "zhao2"
  ```

- **Using Variables**:
  When calling a variable, do not use quotation marks.

  ```python
  # Example:
  device_ID = "h32rb17"
  print(device_ID)
  ```

- **Checking Data Types**:
  Use the `type()` function to determine a variable's data type.

  ```python
  # Example:
  data_type = type(device_ID)
  print(data_type)
  ```

#### Common Errors

- **Type Errors**:
  Occur when combining incompatible data types (e.g., adding a string to an integer).

### Best Practices for Naming Variables

- Use descriptive, meaningful names (e.g., `device_id` instead of `x`).
- Use only letters, numbers, and underscores.
- Remember that variable names are case-sensitive.
- Avoid Python reserved keywords (e.g., `if`, `True`, `False`).
- Maintain consistency (e.g., `login_attempts` or `loginAttempts`, but not both).

## **Conditional Statements**

Conditional statements allow you to incorporate logic into your code by evaluating conditions and executing specific actions based on whether those conditions are met. They are essential for automation in cybersecurity tasks.

### Using the if Statement

- The `if` keyword starts a conditional statement.
- A condition is specified after `if`, followed by a colon.
- The indented block (body) contains the code to run if the condition is True.

  ```python
  # Example:
  if failed_attempts > 5:
      print("account locked")
  ```

*Key point:* Python evaluates the condition (True/False) and executes the indented action if True.

### Comparison Operators

Common operators used in conditions include:

- **==** (equal to)

  ```python
  # Example:
  if operating_system == "OS 2":
  ```

- **!=** (not equal to)

  ```python
  # Example:
  if operating_system != "OS 2":
  ```

- **>**, **<**, **>=**, **<=** for numerical comparisons

### Using else and elif

- **else**: Executes if the preceding `if` condition is False.

  ```python
  # Example:
  if operating_system == "OS 2":
      print("updates needed")
  else:
      print("no updates needed")
  ```

- **elif**: Checks additional conditions if the previous ones are False. Multiple `elif` statements can be used.

  ```python
  # Example:
  if status == 200:
      print("OK")
  elif status == 400:
      print("Bad Request")
  elif status == 500:
      print("Internal Server Error")
  else:
      print("check other status")
  ```

### Logical Operators

These operators combine multiple conditions:

- **and**: Both conditions must be True.

  ```python
  # Example:
  if status >= 200 and status <= 226:
      print("successful response")
  ```

- **or**: Only one condition needs to be True.

  ```python
  # Example:
  if status == 100 or status == 102:
      print("informational response")
  ```

- **not**: Inverts the result of a condition. Use parentheses to group conditions.

  ```python
  # Example:
  if not(status >= 200 and status <= 226):
      print("check status")
  ```


## **Iterative Statements**

Iterative statements, or loops, allow you to execute a block of code repeatedly, which is essential for automating repetitive tasks in cybersecurity.

### For Loops

- **Purpose:** Iterate over a predetermined sequence (e.g., lists, strings, or numbers).
- **Structure:**
  - **Header:** Begins with the `for` keyword, a loop variable, the `in` operator, and a sequence, ending with a colon.
  - **Body:** Indented code block executed on each iteration.

  ```python
  # Example:
  for i in [1, 2, 3, 4]:
      print(i)
  ```

- **Using range():**
  - Generates a sequence of numbers.

  ```python
  # Example:
  for i in range(10):
      print("cannot connect to the destination")
  ```

### While Loops

- **Purpose:** Execute code repeatedly as long as a specified condition remains True.
- **Structure:**
  - **Header:** Begins with the `while` keyword and a condition, ending with a colon.
  - **Body:** Contains code that must update the loop variable to eventually break the loop.

```python
# Example:
i = 1
while i < 5:
    print(i)
    i = i + 1
```

### Managing Loops

- **break:** Exits the loop immediately when a condition is met.

```python
# Example:
computer_assets = ["laptop1", "desktop20", "smartphone03"]
for asset in computer_assets:
    if asset == "desktop20":
        break
    print(asset)
```

- **continue:** Skips the current iteration and proceeds with the next.

```python
# Example:
computer_assets = ["laptop1", "desktop20", "smartphone03"]
for asset in computer_assets:
    if asset == "desktop20":
        continue
    print(asset)
```

- **Infinite Loops:** Loops that never terminate. Use keyboard interrupts (e.g., CTRL-C) to stop them.

## **Key Takeaways**

- **Python is essential for automating cybersecurity tasks.**
- It simplifies programming through its readability and built-in libraries.
- Security analysts use Python for log analysis, intrusion detection, and network scanning.
- Python can be executed in notebooks, IDEs, or the command line.
- **Data Types**: Familiarize yourself with strings, integers, floats, Booleans, and lists, along with additional types like tuples, dictionaries, and sets.
- **Variables**: They store data, can be reassigned, and are essential for clean, efficient code.
  - **Best Practices**: Use clear naming conventions and check data types to prevent errors and enhance code readability.
- **if** statements evaluate conditions to execute code blocks.
- Use **else** for alternative actions when the if condition is not met.
- Use **elif** for multiple alternative conditions.
- Combine conditions with logical operators: **and**, **or**, and **not**.
- Proper indentation and the colon (:) are critical for correct syntax.
- **For loops** are ideal for iterating over a fixed sequence.
- **While loops** repeat as long as a condition is True.
- **break** and **continue** offer control over loop execution.
- Mastery of loops is essential for automating tasks and managing repetitive operations in cybersecurity.
