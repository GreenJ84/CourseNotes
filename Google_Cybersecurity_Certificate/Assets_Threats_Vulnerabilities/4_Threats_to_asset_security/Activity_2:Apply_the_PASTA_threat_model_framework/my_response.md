# **PASTA Worksheet - Sneaker Company App Threat Model**

## **I. Define Business and Security Objectives**

Make 2-3 notes of specific business requirements that will be analyzed:

- **Seamless User Experience:** The application should allow users to easily sign up, log in, and manage their accounts while enabling direct communication between buyers and sellers.
- **Data Privacy and Security:** The app must protect user data, ensuring customers feel confident that their personal and financial information is handled responsibly.
- **Secure and Efficient Transactions:** Sales should be processed quickly and securely, supporting multiple payment options while complying with legal and industry regulations to prevent fraud and financial risks.


---

## **II. Define the Technical Scope**

List of technologies used by the application:

- **Application Programming Interface (API)**
- **Public Key Infrastructure (PKI)**
- **SHA-256**
- **Structured Query Language (SQL)**

**Technology Prioritization:**
I would evaluate the **API** first because it serves as the perimeter layer of defense with the largest attack surface. A vulnerable API could expose user data, enable unauthorized access, or be exploited for injection attacks. Proper API security can prevent many SQL-related vulnerabilities before they reach the database. Additionally, PKI and SHA-256 are widely tested and maintained by the security community, making them more robust against common threats.


---

## **III. Decompose Application**

Refer to the **PASTA Data Flow Diagram** to understand how information moves within the app. Key areas of focus include:

- How users log in and authenticate their accounts.
- How payment transactions are processed securely.
- How data is stored and retrieved from the database.

Review the diagram and consider how the technologies you evaluated relate to protecting user data in this process.

---

## **IV. Threat Analysis**

List 2 types of threats that are risks to the information being handled by the application:

- **API Exploitation & Data Exposure:** Attackers could exploit weak API authentication or input validation to gain unauthorized access to sensitive user data, leading to data breaches or account takeovers.
- **Man-in-the-Middle (MITM) Attacks on Payment Transactions:** If encryption implementation is weak or improperly configured, attackers could intercept and manipulate transaction data, leading to payment fraud or credential theft.

---

## **V. Vulnerability Analysis**

- **SQL Injection Attack:** If input validation is not properly implemented, attackers could inject malicious SQL queries to steal or modify database information.
- **Weak Authentication Mechanisms:** If the authentication system lacks multi-factor authentication (MFA), attackers could brute-force weak passwords and gain access to user accounts.

---

## **VI. Attack Modeling**

Refer to the **PASTA Attack Tree Diagram** to visualize how different attack vectors can be used to exploit vulnerabilities. Review the diagram and consider how threat actors can potentially exploit these attack vectors. Some other attack paths to consider:

- Gaining unauthorized access through an API vulnerability.
- Injecting malicious SQL queries to extract sensitive information.
- Exploiting weak encryption protocols to intercept user credentials.

---

## **VII. Risk Analysis and Impact**

List 4 security controls that can reduce risk:

1. **Implement API Rate Limiting and Strong Authentication:** Prevents abuse by restricting excessive API requests and ensures only authorized users or services can access sensitive endpoints.
2. **Use Web Application Firewalls (WAF):** Helps detect and block SQL injection, cross-site scripting (XSS), and other common web-based attacks.
3. **Enable Multi-Factor Authentication (MFA):** Adds an extra layer of security to user logins, reducing the risk of account takeovers.
4. **Conduct Regular Security Audits and Penetration Testing:** Helps identify and fix vulnerabilities before attackers can exploit them.
