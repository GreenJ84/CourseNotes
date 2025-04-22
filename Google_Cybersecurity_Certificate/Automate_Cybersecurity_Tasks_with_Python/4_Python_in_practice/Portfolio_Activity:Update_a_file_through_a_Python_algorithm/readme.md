# **Portfolio Activity: Python Algorithm for File Updates**

In this activity, you will create a new portfolio document to demonstrate your experience using Python to develop algorithms that involve opening files and parsing their contents. This document will be a valuable addition to your cybersecurity portfolio, which you can share with prospective employers or recruiters.

## **Scenario**

You are a security professional working at a healthcare company. As part of your role, you need to regularly update a file that identifies employees who can access restricted content, based on their IP address. Your task is to create an algorithm that checks whether the allow list contains any IP addresses from the remove list, and removes those IPs from the allow list if found.

This scenario relates to the algorithm you developed in the "Create another algorithm" lab, specifically tasks 2-7. Refer to this lab for screenshots and code examples to include in your portfolio.

## **Instructions**

### Step 1: Access the Template

- Use the Algorithm for file updates in Python [template](./template.docx) for this course item.

### Step 2: Open the File Containing the Allow List

- Assign the string `"allow_list.txt"` to the `import_file` variable.
- Use a `with` statement to open the file and store it in the `file` variable while working with it.

### Step 3: Read the File Contents

- Use the `.read()` method to read the contents of the allow list file and store the result in the `ip_addresses` variable.

### Step 4: Convert the String to a List

- Use the `.split()` method to convert the `ip_addresses` string into a list of IP addresses.

### Step 5: Iterate Through the Remove List

- Set up a `for` loop to iterate through the `remove_list`, using `element` as the loop variable.

### Step 6: Remove the IP Addresses from the Allow List

- In the loop, use a conditional to check if `element` is in `ip_addresses`. If true, use the `.remove()` method to remove the IP address from the list.

### Step 7: Update the File with the Revised List of IP Addresses

- Use the `.join()` method to convert the updated list back into a string, separating elements by a new line (`"\n"`).
- Use a `with` statement and the `.write()` method to overwrite the original file with the updated list of IP addresses.

### Step 8: Finalize Your Document

- Complete the **Project description** and **Summary** sections of the template.
  - **Project description**: Provide a brief overview of the scenario and what was accomplished using Python.
  - **Summary**: Highlight the main components of the algorithm and explain how it works.

## **What to Include in Your Response**

- Screenshots or typed versions of your Python code.
- Explanations of the syntax, functions, and keywords used in the code.
- A **Project description** and **Summary**.
- Details on using the `with` statement and the `open()` function.
- Details on using the `.read()` and `.write()` methods.
- Details on using the `.split()` method.
- Details on using a `for` loop and the `.remove()` method.
