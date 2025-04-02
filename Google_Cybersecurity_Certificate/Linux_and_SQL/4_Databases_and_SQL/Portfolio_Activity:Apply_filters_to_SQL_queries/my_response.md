
# **Apply Filters to SQL Queries**

## **Project Description**

This project demonstrates the use of SQL filtering techniques to analyze login attempts and employee records for security purposes. By applying `AND`, `OR`, and `NOT` operators, we extract relevant data to investigate suspicious login activities, identify employees by department, and filter login attempts based on various criteria. This analysis helps strengthen security measures by detecting anomalies in login behavior and ensuring system integrity.

## **Retrieve After-Hours Failed Login Attempts**

To identify unauthorized access attempts occurring after business hours, we query the `log_in_attempts` table for failed login attempts (`success = FALSE`) that occurred after 18:00.

```sql
SELECT * FROM log_in_attempts
WHERE login_time > '18:00'
AND success = FALSE;
```

This query retrieves all failed login attempts after 6:00 PM, helping to detect potential security incidents occurring outside of normal work hours.

## **Retrieve Login Attempts on Specific Dates**

To investigate a suspicious event on **May 9, 2022**, and the day before, we filter for login attempts on both dates.

```sql
SELECT * FROM log_in_attempts
WHERE login_date = '2022-05-08' OR  login_date = '2022-05-09';
```

This query retrieves all login attempts that occurred on **May 8 and May 9**, allowing security teams to analyze login patterns during the specified timeframe.

## **Retrieve Login Attempts Outside of Mexico**

To analyze login attempts that did not originate from Mexico, we exclude records where `country = 'Mexico'`.

```sql
SELECT * FROM log_in_attempts
WHERE country <> 'Mexico';
```

This query filters out logins from Mexico, helping to identify unauthorized access attempts from other regions.

## **Retrieve Employees in Marketing**

To get information about employees in the **Marketing department** working in the **East building**, we filter the `employees` table.

```sql
SELECT * FROM employees
WHERE department = 'Marketing'
AND office LIKE 'East%';
```

This query ensures only employees in Marketing located in any **East building office** are retrieved.

## **Retrieve Employees in Finance or Sales**

To identify employees in either the **Finance** or **Sales** department, we use the `OR` operator.

```sql
SELECT * FROM employees
WHERE department = 'Finance'
OR department = 'Sales';
```

This query retrieves employees in **either Finance or Sales**, ensuring security updates can be applied to their machines.

## **Retrieve All Employees Not in IT**

To filter employees **excluding the IT department**, we use the `NOT` operator.

```sql
SELECT * FROM employees
WHERE department <> 'IT';
```

This query returns all employees **who are not part of IT**, ensuring security updates are applied only to relevant departments.

## **Summary**

This analysis involved filtering SQL queries to identify **after-hours login attempts, suspicious login activity on specific dates, login attempts outside Mexico, and employees based on department criteria**. By leveraging SQL filtering techniques, we effectively extracted meaningful security insights that can help organizations detect unauthorized access attempts and apply necessary security updates to employee machines.

