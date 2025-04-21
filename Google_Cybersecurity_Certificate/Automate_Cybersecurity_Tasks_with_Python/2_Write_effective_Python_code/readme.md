# **Write Effective Python Code**

This module builds on foundational Python knowledge by introducing functions, modules, and best practices for writing efficient and readable code. You will learn how to incorporate both pre-built and user-defined functions, use modules to access reusable code, and improve code readability for better collaboration and maintainability.

Functions streamline repetitive tasks by allowing code reuse, while modules and libraries provide access to existing functions and data types. Finally, code readability ensures that scripts remain understandable and maintainable by others. Mastering these concepts will enhance your ability to write efficient and effective Python scripts for cybersecurity tasks.

## **Learning Objectives**

- Incorporate pre-built functions into Python scripts.
- Create user-defined Python functions.
- Explain the role of modules in Python.
- Apply best practices to improve code readability.


## **Introduction to Python Programming in Cybersecurity**

Functions are reusable blocks of code that help automate repetitive tasks and improve code efficiency. They are essential in both general programming and cybersecurity, where automating common processes—like processing security logs—can save significant time and reduce errors.

### Why Use Functions?

- **Efficiency:** Avoid rewriting the same code multiple times.
- **Maintainability:** Change code in one place to affect all instances.
- **Reusability:** Use built-in functions (like `print()`) or create your own functions for specific tasks.

### Defining a Function

A function is defined using the `def` keyword, a descriptive name, parentheses, and a colon. The function’s body, which contains the code to execute, is indented.

```python
def greet_employee():
    print("Welcome, employee!")
```

*Pro Tip:* Choose a function name that clearly indicates its purpose.

### Calling a Function

After defining a function, you need to call it to execute its code. Calling a function is as simple as writing its name followed by parentheses.

```python
greet_employee()  ## This will output: Welcome, employee!
```

### Functions in Cybersecurity

In a cybersecurity context, functions can:

- Automate the analysis of security logs.
- Handle repetitive tasks like identifying failed login attempts.
- Be integrated into larger conditional processes to trigger alerts or actions.

For example, a function might be used to display an investigation message when a security log indicates a potential threat.

```python
def display_investigation_message():
    print("Investigate activity")

application_status = "potential concern"

if application_status == "potential concern":
    display_investigation_message()  ## Outputs: Investigate activity
```

### Avoiding Infinite Loops

Be cautious with function calls within their own definitions (recursive calls) without proper termination conditions, as they can create infinite loops.

```python
def func1():
    func1()  ## This will result in an infinite loop!
```

## **Work with Functions**

In this section, you'll learn how to enhance functions by working with parameters, passing arguments, and returning values. You'll also explore the difference between global and local variables to write more dynamic and flexible Python code.

### Using Parameters and Arguments

Parameters are placeholders in a function definition that allow you to pass data into the function. When you call the function, the provided data are known as arguments.

- **Example with one parameter:**

```python
def greet_employee(name):
    print("You're logged in,", name)
```

Call it with:

```python
greet_employee("Charley Patel")
```

- **Example with multiple parameters:**

```python
def greet_employee(first_name, last_name):
    print("You're logged in,", first_name, last_name)
```

Call it with:

```python
greet_employee("Kiara", "Carter")
```

### Returning Values from Functions

A return statement sends information back to the caller. This is useful when you need to use the computed result in other parts of your program.

- **Example: Calculating failed login percentage**

```python
def calculate_fails(total_attempts, failed_attempts):
    fail_percentage = failed_attempts / total_attempts
    return fail_percentage
```

Usage:

```python
percentage = calculate_fails(4, 2)
if percentage >= 0.5:
    print("Account locked")
```

### Global vs. Local Variables

- **Global Variables:** Declared outside functions, accessible throughout the program.

```python
device_id = "7ad2130bd"
```

- **Local Variables:** Declared inside a function; they exist only within that function.

```python
def greet_employee(name):
    total_string = "Welcome " + name
    return total_string
```

#### Best Practices

- Use parameters to pass data into functions rather than relying on global variables.
- Avoid naming conflicts by ensuring that global and local variables have distinct names.

## **Built-in Functions**

Built-in functions are pre-defined in Python and can be called directly. They simplify many common tasks like outputting data, determining data types, and processing iterables. By understanding these functions and how to combine them, you can write more efficient, error-free code.

### Key Built-in Functions

#### print()

- **Purpose:** Outputs specified objects to the screen.
- **Usage:** Accepts multiple arguments of any data type.

```python
month = "September"
print("Investigate failed login attempts during", month, "if more than", 100)
```

#### type()

- **Purpose:** Returns the data type of its argument.
- **Usage:** Accepts one argument.

```python
print(type("This is a string"))
```

#### max() and min()

- **Purpose:** Return the largest and smallest values, respectively, from the provided inputs or iterable.
- **Usage:** Can take multiple numeric arguments or an iterable.

```python
time_list = [12, 2, 32, 19, 57, 22, 14]
print(min(time_list))
print(max(time_list))
```

#### sorted()

- **Purpose:** Returns a new list with the elements of an iterable sorted in ascending order.
- **Usage:** Does not modify the original iterable.

```python
time_list = [12, 2, 32, 19, 57, 22, 14]
print(sorted(time_list))
print(time_list)
```

#### len()

- **Purpose:** Returns the number of items in an object (e.g., characters in a string or elements in a list).

```python
print(len("cybersecurity"))
```

#### sum()

- **Purpose:** Calculates the sum of numeric items in an iterable.

```python
numbers = [1, 2, 3, 4, 5]
print(sum(numbers))
```

#### int(), float(), str()

- **Purpose:** Convert values to integer, float, or string types, respectively.

```python
print(int("123"))
print(float("12.34"))
print(str(123))
```

#### range()

- **Purpose:** Generates a sequence of numbers; often used in loops.
- **Usage:** Requires start and stop values (stop is exclusive).

```python
for i in range(3, 7):
    print(i)  ## Outputs: 3, 4, 5, 6
```

#### abs()

- **Purpose:** Returns the absolute value of a number.

```python
print(abs(-5))  ## Outputs: 5
```

#### help()

- **Purpose:** Provides documentation for a function, module, or object.

```python
help(print)
```

### Combining Functions

Built-in functions can be nested—one function's output can serve as another function's input.

```python
print(type("Hello"))  ## type("Hello") returns 'str', which is then printed.
```

## **Learn from the Python Community**

Python’s extensive ecosystem includes not only built-in functions but also a wealth of libraries and modules that you can import to enhance your code. In addition, following community style guides—like PEP 8—ensures that your code is clear, consistent, and maintainable.

### Python Libraries and Modules

- **Modules:** Individual Python files containing functions, classes, and variables.
- **Libraries:** Collections of modules that provide ready-to-use functionality.

#### The Python Standard Library

- Comes packaged with Python.
- Includes useful modules such as:
  - **re:** For searching patterns (e.g., in log files).
  - **csv:** For handling CSV files.
  - **os, glob:** For interacting with the file system and command line.
  - **time, datetime:** For working with timestamps.
  - **statistics:** For calculating data statistics (e.g., mean and median).

##### Importing Modules

- **Import Entire Module:**

```python
import statistics
monthly_failed_attempts = [20, 17, 178, 33, 15, 21, 19, 29, 32, 15, 25, 19]
mean_failed_attempts = statistics.mean(monthly_failed_attempts)
print("mean:", mean_failed_attempts)
```

- **Import Specific Functions:**

```python
from statistics import mean, median
monthly_failed_attempts = [20, 17, 178, 33, 15, 21, 19, 29, 32, 15, 25, 19]
print("mean:", mean(monthly_failed_attempts))
print("median:", median(monthly_failed_attempts))
```

#### External Libraries

- Can be installed via package managers (e.g., `%pip install numpy`).
- Examples:
  - **Beautiful Soup:** For parsing HTML.
  - **NumPy:** For numerical computations and array handling.

### Community Style Guides and Code Readability

#### PEP 8 Style Guide

- **Purpose:** Provides conventions for writing readable Python code.
- **Focus Areas:**
  - **Comments:**
    - *Single-line:* Use `#` to annotate code briefly.

      ```python
      ## Print elements of 'computer_assets' list
      ```

    - *Multi-line:* Use consecutive `#` symbols or docstrings for longer explanations.

      ```python
      """
      Function to calculate remaining login attempts.
      Expects two integers and returns their difference.
      """
      ```

  - **Indentation:**
    - Recommended: 4 spaces per indent level.
    - Ensures code blocks (like conditionals, loops, and functions) are clearly defined.

    ```python
    count = 0
    login_status = True
    while login_status:
        print("Try again.")
        count += 1
        if count == 4:
            login_status = False
    ```

  - **Syntax Considerations:**
    - Use colons (`:`) at the end of headers for functions, conditionals, and loops.
    - Follow data type conventions: strings in quotes, numbers without quotes, lists in brackets.

## **Key Takeaways**

- **Functions** simplify and streamline coding by allowing code reuse.
- **Built-in vs. User-defined:** Python provides many built-in functions, and you can create custom ones as needed.
- **Maintenance:** Centralizing code in functions makes updates and debugging easier.
- **Application in Cybersecurity:** Automate and standardize tasks to efficiently manage security processes.
- **Parameters** allow functions to accept inputs (arguments) and make your code more flexible.
- **Return statements** send data from a function back to the caller for further use.
- **Global and local variables** operate in different scopes; mixing them can lead to confusion.
- Clear naming and scope management improve code readability and maintainability.
- **Built-in functions** are essential tools that simplify programming tasks.
- Know the expected inputs and outputs to avoid errors.
- Foundational functions like **print(), type(), max(), min(), and sorted()** form the basis of many operations.
- Additional functions such as **len(), sum(), int(), float(), str(), range(), abs(),** and **help()** further enhance coding flexibility.
- Combining functions (nesting) allows you to streamline complex operations.
- **Libraries & Modules:** Extend Python’s functionality beyond the built-in functions.
- **Importing:** Use `import` or `from ... import` to access modules and functions.
- **External Libraries:** Offer specialized tools (e.g., Beautiful Soup, NumPy) and must be installed separately.
- **PEP 8:** Following a style guide improves code readability, maintainability, and collaboration.
- **Comments & Indentation:** Essential for clarity; they help both the original author and others understand the code.
