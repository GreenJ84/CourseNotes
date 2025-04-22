# **Work with Strings and Lists**

In this module, you'll explore advanced techniques for handling strings and lists in Python. You'll learn methods to manipulate these data types, write a simple algorithm to solve a problem, and use regular expressions to search for patterns in text.

## **Learning Objectives**

- Use Python to work with strings and lists.
- Write a simple algorithm.
- Use regular expressions to extract information from text.

## **Work with Strings**

Understanding how to work with strings is essential for cybersecurity tasks, such as analyzing usernames, searching logs, and extracting information. This section revisits string fundamentals and explores key operations like indexing, slicing, and using string methods.

### **String Basics**

- A **string** is an ordered sequence of characters enclosed in **double** or **single** quotes.
- Strings can be created from other data types using the `str()` function.
- Example:

  ```python
  my_string = str(123)  # Converts 123 into "123"
  print(type(my_string))  # Output: <class 'str'>
  ```

### **Basic String Operations**

#### **Find String Length**

- The `len()` function returns the number of characters in a string.
- Useful in security for validating data formats, such as checking if an IPv4 address has more than 15 characters.

  ```python
  ip_address = "192.168.1.1"
  print(len(ip_address))  # Output: 11
  ```

#### **String Concatenation**

- The `+` operator joins two strings together.
- Example:

  ```python
  greeting = "Hello" + " " + "World"
  print(greeting)  # Output: "Hello World"
  ```

### **String Methods**

Methods are functions that belong to specific data types and are applied using dot notation.

#### **Convert Case**

- `.upper()` converts a string to uppercase.
- `.lower()` converts a string to lowercase.
- Example:

  ```python
  text = "Hello"
  print(text.upper())  # Output: "HELLO"
  print(text.lower())  # Output: "hello"
  ```

### **String Indexing and Slicing**

#### **Character Indexing**

- Each character in a string has an index starting at **0**.
- Example:

  ```python
  word = "HELLO"
  print(word[1])  # Output: "E"
  ```

#### **Negative Indexing**

- Indexing from the end of the string starts at **-1**.
- Example:

  ```python
  print(word[-1])  # Output: "O"
  ```

#### **String Slicing**

- Extract a substring by specifying a **start index** and an **end index** (exclusive).
- Example:

  ```python
  print(word[1:4])  # Output: "ELL"
  ```

### **Searching in Strings**

#### **Find First Occurrence**

- The `.index()` method returns the first occurrence of a character or substring.
- Example:

  ```python
  print("HELLO".index("L"))  # Output: 2
  ```

- If the character is not found, Python raises an error.

### **Strings in Cybersecurity**

- String manipulation is crucial in security tasks:
  - **Extracting parts of IP addresses**
  - **Validating usernames**
  - **Searching logs for suspicious activity**

Here’s your Markdown summary for **Section 2: Work with Lists and Developed Algorithms**, formatted cleanly and concisely.

---

## **Work with Strings and Lists**  

### **Section 2: Work with Lists and Develop Algorithms**  

#### **Working with Lists in Python**  

Lists allow the storage of multiple data elements in a single variable. In cybersecurity, they are commonly used for storing data like IP addresses, usernames, device IDs, or blocked applications.  

#### **Creating and Accessing Lists**  

A list is created using square brackets `[]`, with elements separated by commas.  
<!--snippet-->
my_list = ["A", "B", "C", "D", "E"]
<!--snippet-->

To access elements, use bracket notation with the index:  
<!--snippet-->
print(my_list[1])  ## Outputs: B
<!--snippet-->

- Lists are **zero-indexed**, meaning the first element has an index of `0`.  

#### **Concatenating Lists**  

Lists can be combined using the `+` operator.  
<!--snippet-->
list1 = ["A", "B", "C"]
list2 = [1, 2, 3]
combined_list = list1 + list2
print(combined_list)  ## Outputs: ['A', 'B', 'C', 1, 2, 3]
<!--snippet-->

#### **Modifying Lists**  

Unlike strings, lists are **mutable**, meaning elements can be changed, added, or removed.  

##### **Changing Elements**  
<!--snippet-->
my_list = ["A", "B", "C", "D"]
my_list[1] = 7
print(my_list)  ## Outputs: ['A', 7, 'C', 'D']
<!--snippet-->

##### **Inserting Elements** (`.insert()`)  

`insert(index, value)` places a value at a specific index.  
<!--snippet-->
my_list.insert(1, "X")
print(my_list)  ## Outputs: ['A', 'X', 7, 'C', 'D']
<!--snippet-->

##### **Removing Elements** (`.remove()`)  

Removes the **first occurrence** of a value.  
<!--snippet-->
my_list.remove("D")
print(my_list)  ## Outputs: ['A', 'X', 7, 'C']
<!--snippet-->

##### **Appending Elements** (`.append()`)  

Adds an element to the **end** of the list.  
<!--snippet-->
my_list.append("E")
print(my_list)  ## Outputs: ['A', 'X', 7, 'C', 'E']
<!--snippet-->

#### **Extracting Subsets (Slicing)**  

Slicing extracts multiple elements, creating a **sublist**.  
<!--snippet-->
sublist = my_list[0:2]  
print(sublist)  ## Outputs: ['A', 'X']
<!--snippet-->
- The slice includes the start index (`0`), but excludes the stop index (`2`).  

---

### **Developing Algorithms**  

An **algorithm** is a step-by-step method for solving a problem.  

#### **Example: Extracting Network Identifiers from IP Addresses**  

As a security analyst, you may need to extract the first three digits of IP addresses to analyze networks.  

1. **Break the problem down:**  
   - If extracting from one IP, use **string slicing**.  
   - To apply to a list, use a **loop**.  

2. **Extract from a single IP address:**  
<!--snippet-->
ip_address = "198.567.23.45"
network_id = ip_address[:3]  
print(network_id)  ## Outputs: 198
<!--snippet-->

3. **Apply to a list of IP addresses:**  
<!--snippet-->
ip_list = ["198.567.23.45", "172.245.67.89", "10.0.0.1"]
network_ids = []

for address in ip_list:
    network_ids.append(address[:3])

print(network_ids)  ## Outputs: ['198', '172', '10']
<!--snippet-->

#### **Best Practices for Writing Algorithms**  

- **Break the problem into smaller steps** before coding.  
- **Use loops and list methods** to automate repetitive tasks.  
- **Leverage list indexing and slicing** to manipulate data efficiently.  

---

This section covered **list operations and algorithms**, focusing on cybersecurity use cases such as **storing and analyzing network data**.

## **Key Takeaways**

- Strings are **immutable** (cannot be modified after creation).
- Use `len()` to check string length.
- `+` concatenates strings.
- `.upper()` and `.lower()` change case.
- `.index()` locates the first occurrence of a character or substring.
- Strings are indexed starting at **0** and support **negative indexing**.
