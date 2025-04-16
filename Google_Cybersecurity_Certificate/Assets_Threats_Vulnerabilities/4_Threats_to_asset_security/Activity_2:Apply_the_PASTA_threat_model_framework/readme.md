# **PASTA Threat Modeling**

In this activity, you will practice using the Process of Attack Simulation and Threat Analysis (PASTA) threat model framework. You will determine whether a new shopping app is safe to launch.

Threat modeling is an important part of secure software development. Security teams typically perform threat models to identify vulnerabilities before malicious actors do. PASTA is a commonly used framework for assessing the risk profile of new applications.

## **Scenario**

Review the following scenario. Then complete the step-by-step instructions.

You’re part of the growing security team at a company for sneaker enthusiasts and collectors. The business is preparing to launch a mobile app that makes it easy for their customers to buy and sell shoes.

You are performing a threat model of the application using the PASTA framework. You will go through each of the seven stages of the framework to identify security requirements for the new sneaker company app.

## **Instructions**

### Part 1 - Access the resources

#### Step 1: Access the template

- Use the **[PASTA worksheet](./PASTA-worksheet.docx)** template for this activity.

#### Step 2: Access supporting materials

- The following supporting materials will help you complete this activity. Keep them open as you proceed to the next steps.
  **[PASTA data flow diagram](./PASTA-data-flow-diagram.pptx)**
  **[PASTA attack tree](./PASTA-attack-tree.pptx)**

---

### Part 2 - Complete the PASTA stages

#### Step 1: Identify the mobile app's business objectives

- The main goal of **Stage I** of the PASTA framework is to understand why the application was developed and what it is expected to do.
- Review the following description of why the sneaker company developed this app:

  **Description:**
  - Our application should seamlessly connect sellers and shoppers.
  - It should be easy for users to sign up, log in, and manage their accounts.
  - Data privacy is a big concern. Users should feel confident that their information is handled responsibly.
  - Buyers should be able to message sellers, rate them, and have multiple payment options.
  - Payment handling should be secure to avoid legal issues.

- **Task:**
  - In the **Stage I** row of the PASTA worksheet, make **2-3 notes** of business objectives identified from the description.

---

#### Step 2: Evaluate the app’s components

- In **Stage II**, the technological scope of the project is defined. Your role is to evaluate the application's architecture for security risks.

- The app will be exchanging and storing user data. The technologies used include:
  - **Application programming interface (API)** – Defines how software components interact. Uses third-party APIs to add functionality.
  - **Public Key Infrastructure (PKI)** – Uses AES for data encryption and RSA for key exchange.
  - **SHA-256** – Hash function for securing passwords and credit card numbers.
  - **SQL** – Manages data related to sneakers, sellers, and purchases.

- **Task:**
  - Consider which technology you would evaluate first.
  - In the **Stage II** row of the PASTA worksheet, write **2-3 sentences (40-60 words)** explaining why you chose that technology.

---

#### Step 3: Review the data flow diagram

- In **Stage III**, analyze how the app handles information. Each process is broken down.
- Open the **PASTA data flow diagram** and review how user data is processed and secured.

- **Task:**
  - Consider how the technologies you evaluated relate to protecting user data.

---

#### Step 4: Use an attacker mindset to analyze potential threats

- In **Stage IV**, identify potential threats to the application, including risks to the technologies listed in **Stage II** and processes from **Stage III**.

- **Example threats:**
  - The app’s authentication system could be attacked with a virus.
  - A threat actor could use social engineering to compromise an employee.

- **Task:**
  - In the **Stage IV** row of the PASTA worksheet, list **2 types of threats** that are risks to the app’s data.

💡 **Pro tip:** Internal system logs are a useful source of threat intelligence.

---

#### Step 5: List vulnerabilities that can be exploited by those threats

- In **Stage V**, analyze vulnerabilities in the technologies from **Stage II**.

- **Example vulnerability:**
  - The payment form might fail to encrypt credit card data, exposing users to data theft.

- **Task:**
  - In the **Stage V** row of the PASTA worksheet, list **2 types of vulnerabilities** that could be exploited.

💡 **Pro tip:** Use resources like the **CVE® list** and **OWASP** to find common software vulnerabilities.

---

#### Step 6: Map assets, threats, and vulnerabilities to an attack tree

- In **Stage VI**, use information from previous steps to build an attack tree.
- Open the **PASTA attack tree** and analyze how threats can exploit vulnerabilities.

📌 **Note:** Real-world applications often have complex attack trees with multiple branches.

---

#### Step 7: Identify new security controls that can reduce risk

- In **Stage VII**, implement defenses and safeguards that mitigate threats.

- **Task:**
  - In the **Stage VII** row of the PASTA worksheet, list **4 security controls** that reduce the chances of a security incident, such as a data breach.

---

## **What to Include in Your Response**

Be sure to address the following elements in your completed activity:

- **2-3 business objectives**
- **2-3 technology requirements**
- **2 potential threats**
- **2 system vulnerabilities**
- **4 defenses that limit risk**
