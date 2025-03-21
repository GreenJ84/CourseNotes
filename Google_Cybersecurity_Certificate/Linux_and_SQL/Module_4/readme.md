# **Databases and SQL**

## **Overview**

In this module, you'll practice using SQL to interact with databases. You'll learn to query databases, filter results, and join tables to extract meaningful information. SQL is a powerful tool that enables security analysts to quickly analyze large datasets and derive actionable insights.

## **Learning Objectives**

By the end of this module, you will be able to:

1. Understand how SQL is used in the security profession.
2. Describe the structure of a relational database.
3. Retrieve data from a database using SQL queries.
4. Apply filters to refine SQL query results.
5. Combine multiple tables using SQL joins.

## **Introduction to Databases**

- **Purpose:**
  Databases store large volumes of data in an organized manner for fast and efficient access.
- **Comparison to Spreadsheets:**
  Unlike spreadsheets (designed for single users or small teams), databases support multi-user access, massive data sets, and complex operations.

### Relational Databases

- **Structure:**
  Organized into tables, which consist of:
  - **Columns (Fields):** Define the type of data (e.g., employee_id, username).
  - **Rows (Records):** Contain individual data entries.
- **Relationships and Keys:**
  - **Primary Key:** A unique identifier for each record (e.g., employee_id in the employees table).
  - **Foreign Key:** A column that links to a primary key in another table, establishing relationships (e.g., linking employees to their machines).

### Introduction to SQL

- **SQL (Structured Query Language):**
  A language used to create, manage, and query relational databases.
- **Queries:**
  Requests for data from one or more tables.
- **Applications in Security:**
  - Quickly retrieving logs and records.
  - Filtering large datasets to pinpoint issues (e.g., misconfigured machines, unusual access patterns).
  - Joining tables to combine related information from different sources.

### SQL Filtering vs. Linux Filtering

- **Purpose:**
  - **Linux Filtering:** Manages files and directories on a system.
  - **SQL Filtering:** Manipulates and retrieves structured data stored in databases.
- **Syntax and Structure:**
  - **Linux:** Uses various commands (e.g., find, grep) with less structured output.
  - **SQL:** Uses standardized clauses (e.g., SELECT, WHERE, JOIN) for organized, columnar results.
- **Joining Tables:**
  SQL allows joining multiple tables to aggregate related data, a capability not available in Linux filtering.
- **Best Uses:**
  - Use SQL for structured data within databases.
  - Use Linux filtering for data in unstructured text files.

## **Basic SQL Querying**

Execute basic SQL queries to retrieve specific data from a database.

### Basic SQL Query Structure

- **Essential Keywords:**
  - **SELECT:** Specifies the columns to return.
  - **FROM:** Specifies the table to query.
- **Syntax Example:**

  ```sql
  SELECT employee_id, name
  FROM employees;
  ```

- **Key Points:**
  - Keywords are case-insensitive (capitalization improves readability).
  - Use commas to separate multiple columns.
  - End the query with a semicolon (`;`).

### Selecting All Columns

- **Purpose:**
  Retrieve every column from a table.
- **Syntax Example:**

  ```sql
  SELECT *
  FROM employees;
  ```


### Organizing Output with ORDER BY

- **ORDER BY:**
  Sorts the query results based on one or more columns.
- **Sorting Examples:**
  - **Ascending Order (default):**

    ```sql
    SELECT customerid, city, country
    FROM customers
    ORDER BY city;
    ```

  - **Descending Order:**

    ```sql
    SELECT customerid, city, country
    FROM customers
    ORDER BY city DESC;
    ```

  - **Multiple Columns:**
  
    ```sql
    SELECT customerid, city, country
    FROM customers
    ORDER BY country, city;
    ```



## **String SQL Query Filtering**

- **What is Filtering?**
  Filtering selects data that match a specified condition, narrowing down results.
  - **WHERE Clause:**
    Adds a filter condition to a query.
    - **Syntax Example:**
    Filtering login attempts from a specific country like Canada.

    ```sql
    SELECT *
    FROM log_in_attempts
    WHERE country = 'CN';
    ```

### SQL Operators

- **Operators** are symbols or keywords that represent operations. Common examples include:
  - **Equal to operator (`=`):**
    Filters records that exactly match a value.

    ```sql
    SELECT *
    FROM log_in_attempts
    WHERE country = 'USA';
    ```

  - **LIKE operator:**
    Used to search for a pattern in a column.

    ```sql
    SELECT *
    FROM employees
    WHERE country LIKE 'E%';
    # Matches all country codes starting with E, (Ecuador - EC, Egypt - EG, Spain - ES, etc.)
    ```


### Filtering for Patterns with LIKE

- **Pattern Matching with LIKE:**
  If inconsistencies exist, like 'US' vs 'USA', the `LIKE` operator can be used with wildcards to match both.

  ```sql
  SELECT *
  FROM log_in_attempts
  WHERE country LIKE 'US%';
  ```

### Wildcards in SQL

- **Common Wildcards:**
  - **% (percent sign):** Matches any sequence of characters.
  - **_ (underscore):** Matches exactly one character.
- **Pattern Matching Example:**
  To find all offices starting with 'East':

  ```sql
  SELECT *
  FROM employees
  WHERE office LIKE 'East%';
  ```

  - **`'a%'`** could match 'apple123', 'art', 'a', etc.
  - **`'a_'`** could match 'as', 'an', 'a7', etc.
  - **`'%a%'`** could match 'again', 'back', 'a', etc.

## **Filtering Numeric and Date/Time Data**

SQL filters apply not only to strings but also to numeric and date/time data.

### Common Data Types in Databases

- **String Data:** Ordered sequences of characters (e.g., usernames like `analyst10`).
- **Numeric Data:** Numbers that support mathematical operations (e.g., login attempt counts).
- **Date and Time Data:** Values representing timestamps (e.g., login times, patch dates).

### Comparison Operators for Numeric & Date Data

Operators are commonly used to filter numeric and date/time data.

| Operator | Description                 |
|----------|-----------------------------|
| `<`      | Less than                    |
| `>`      | Greater than                 |
| `=`      | Equal to                     |
| `<=`     | Less than or equal to        |
| `>=`     | Greater than or equal to     |
| `<>` or `!=` | Not equal to          |

### Filtering by Time

Example: To find login attempts made after 6 PM, use the greater than (`>`) operator.

  ```sql
  SELECT *
  FROM log_in_attempts
  WHERE time > '18:00';
  ```

### Filtering for a Date Range with BETWEEN

Example: To find machines patched between March 1, 2021, and September 1, 2021:

  ```sql
  SELECT *
  FROM machines
  WHERE OS_patch_date BETWEEN '2021-03-01' AND '2021-09-01';
  ```

### Inclusive vs. Exclusive Operators

- **`>`** is **exclusive** (excludes the given value).
- **`>=`** is **inclusive** (includes the given value).
- **BETWEEN** is **inclusive** (includes both start and end dates).

Example: Finding employees hired between January 1, 2002, and January 1, 2003:

  ```sql
  SELECT firstname, lastname, hiredate
  FROM employees
  WHERE hiredate BETWEEN '2002-01-01' AND '2003-01-01';
  ```


## **Advanced SQL Filtering: Combining Conditions**

In real-world cybersecurity scenarios, vulnerabilities often depend on multiple factors. For instance, a security vulnerability might be linked to machines running a specific email client on a particular operating system. To identify affected machines, we must filter for both conditions simultaneously.

### **Logical Operators in SQL**

SQL provides three logical operators to refine queries:

- **AND**: Both conditions must be met.
- **OR**: At least one condition must be met.
- **NOT**: Negates a condition.

---

### **Using the AND Operator**

The **AND** operator is used when all conditions must be true. For example, if we need to find machines running both **OS 1** and **Email Client 1**, we use:

  ```sql
  SELECT *
  FROM machines
  WHERE operating_system = 'OS 1' AND email_client = 'Email Client 1';
  ```

This ensures only machines that meet **both** conditions appear in the results.

#### **Example: Security Alerts by Country and Representative**

To find customers affected by a cybersecurity issue that is handled by support representative ID 5 and located in the USA:

  ```sql
  SELECT firstname, lastname, email, country, supportrepid
  FROM customers
  WHERE supportrepid = 5 AND country = 'USA';
  ```

Both conditions must be satisfied for a record to be included.

---

### **Using the OR Operator**

The **OR** operator is used when at least one of multiple conditions should be true.
For example, if machines running **OS 1** or **OS 3** need a patch:

  ```sql
  SELECT *
  FROM machines
  WHERE operating_system = 'OS 1' OR operating_system = 'OS 3';
  ```

This query selects all machines that match **either** OS version.

#### **Example: Security Updates for Customers in North America**

If a security update affects customers in **Canada** or the **USA**, use:

  ```sql
  SELECT firstname, lastname, email, country
  FROM customers
  WHERE country = 'Canada' OR country = 'USA';
  ```

Even if both conditions use the same column, they must be explicitly stated.

---

### **Using the NOT Operator**

The **NOT** operator excludes records that match a specific condition.
For example, to find all machines **except** those running **OS 3**:

  ```sql
  SELECT *
  FROM machines
  WHERE NOT operating_system = 'OS 3';
  ```

This query returns all machines **except** those with OS 3.

#### **Example: Excluding USA Customers from a Query**

If a cybersecurity issue affects all countries **except** the USA:

  ```sql
  SELECT firstname, lastname, email, country
  FROM customers
  WHERE NOT country = 'USA';
  ```

This is more efficient than listing every country individually.

#### **Alternative Syntax for NOT**

The same query can be written using `<>` or `!=`:

  ```sql
  WHERE country <> 'USA';
  WHERE country != 'USA';
  ```

---

### **Combining Logical Operators**

Logical operators can be **combined** for complex filters.
For example, to find customers **outside** both Canada and the USA:

  ```sql
  SELECT firstname, lastname, email, country
  FROM customers
  WHERE NOT country = 'Canada' AND NOT country = 'USA';
  ```

This query ensures **neither** condition is met.

These advanced filtering techniques help security analysts refine queries, identify vulnerabilities, and extract crucial security-related data effectively.

## **SQL Joins: Combining Data Across Tables**


SQL joins allow analysts to combine data from multiple tables based on a common column. This is useful when dealing with related information, such as linking security vulnerabilities to machines in an organization.


### **Understanding Join Syntax**

When working with multiple tables, SQL needs a way to differentiate between columns with the same name. To do this, **prefix the column with the table name**, separated by a period (`.`):

```sql
employees.employee_id
machines.employee_id
```

This ensures that SQL correctly identifies which table the column belongs to.

---

### **INNER JOIN: Matching Records Between Tables**

The **INNER JOIN** returns only rows where a match exists in both tables. For example, to find employees and the machines they use:

```sql
SELECT *
FROM employees
INNER JOIN machines ON employees.device_id = machines.device_id;
```

This retrieves records where `device_id` appears in both tables.

#### **Selecting Specific Columns in INNER JOIN**

Instead of selecting all columns, we can refine the query:

```sql
SELECT username, operating_system, employees.device_id
FROM employees
INNER JOIN machines ON employees.device_id = machines.device_id;
```

Here, `username` and `operating_system` are unique to their respective tables, but `device_id` exists in both, requiring explicit table reference.

---



---

### **Outer Joins: Expanding Query Results**

Outer joins allow records to be included **even if they don’t have a match** in the other table. There are three types:

#### **LEFT JOIN: Include All Records from the Left Table**

A **LEFT JOIN** retrieves all rows from the first (left) table, with matching data from the second (right) table. If there’s no match, `NULL` is returned.

```sql
SELECT *
FROM employees
LEFT JOIN machines ON employees.device_id = machines.device_id;
```

This ensures all employees are included, even those without assigned machines.

---

#### **RIGHT JOIN: Include All Records from the Right Table**

A **RIGHT JOIN** retrieves all rows from the second (right) table, with matching data from the first (left) table. If there’s no match, `NULL` is returned.

```sql
SELECT *
FROM employees
RIGHT JOIN machines ON employees.device_id = machines.device_id;
```

This ensures all machines are included, even if no employee is assigned to them.

**Note:** `RIGHT JOIN` results can be obtained using `LEFT JOIN` by swapping the table order.

```sql
SELECT *
FROM machines
LEFT JOIN employees ON employees.device_id = machines.device_id;
```

---

#### **FULL OUTER JOIN: Include All Records from Both Tables**

A **FULL OUTER JOIN** retrieves all rows from **both** tables, inserting `NULL` where matches are absent.

```sql
SELECT *
FROM employees
FULL OUTER JOIN machines ON employees.device_id = machines.device_id;
```

This is useful when analyzing all entities, regardless of whether they have a match in the other table.

---

#### **Handling NULL Values in Joins**

`NULL` represents missing data. In outer joins, `NULL` values appear when a record from one table **does not** have a match in the other.

## **Continuous Learning in SQL**

You've already learned how to filter data and join tables in SQL. However, SQL offers many more functionalities to enhance data analysis. One powerful feature is **aggregate functions**, which allow you to perform calculations on multiple rows and return summarized results.

---

### **Aggregate Functions**

Aggregate functions operate on multiple data points and return a single calculated value rather than individual rows. Some commonly used aggregate functions include:

- **COUNT**: Returns the number of rows in a query.
- **AVG**: Returns the average value of a numerical column.
- **SUM**: Returns the sum of all values in a numerical column.

#### **Using Aggregate Functions**

To use an aggregate function, place its keyword after `SELECT`, followed by the column to calculate within parentheses.

For example, to count the total number of customers:

```sql
SELECT COUNT(firstname)
FROM customers;
```

The result will display a single value representing the number of records in the `customers` table.

To count only customers from the USA, apply a `WHERE` clause:

```sql
SELECT COUNT(firstname)
FROM customers
WHERE country = 'USA';
```

This filters the query to count only the rows where `country = 'USA'`.

**Note:** Aggregate functions ignore `NULL` values when performing calculations.

---

### **Continuing to Learn SQL**

SQL is a widely used language with many advanced features. To deepen your SQL knowledge:

- **Explore more aggregate functions**: Functions like `MIN`, `MAX`, and `GROUP BY` offer additional ways to analyze data.
- **Practice regularly**: Apply SQL to real-world datasets to reinforce your understanding.
- **Leverage online resources**: Tutorials, documentation, and interactive SQL databases provide hands-on learning opportunities.

---

## **Key Takeaways**

- Databases are critical for storing and efficiently processing large amounts of data.
- Relational databases organize data in interrelated tables using primary and foreign keys.
- SQL is a versatile language that empowers security analysts to query, filter, and join data effectively.
- Understand the differences between SQL and Linux filtering to choose the right tool based on the data format and task.
- **WHERE Clause:** Essential for filtering records in SQL.
  - **LIKE Operator & Wildcards (`%`, `_`)**: Used for pattern matching.
  - **Comparison Operators (`<`, `>`, `=`, `BETWEEN`)**: Applied to numeric and date/time filtering.
  - **Inclusive vs. Exclusive Operators:** Determines if boundary values are included in results.
  - **Logical operators** can combine filters and be combined for more precise queries.
- Understanding joins allows security analysts to effectively correlate data across multiple tables, improving their ability to investigate and respond to security threats.
  - **INNER JOIN**: Returns only matching records from both tables.
  - **LEFT JOIN**: Returns all records from the left table and matches from the right.
  - **RIGHT JOIN**: Returns all records from the right table and matches from the left.
  - **FULL OUTER JOIN**: Returns all records from both tables, inserting `NULL` for missing matches.
- SQL is a powerful tool for cybersecurity analysts, enabling efficient data queries and analysis.
- Continuous learning and hands-on practice will help you master SQL for cybersecurity applications.
