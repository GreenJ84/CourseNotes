# **Cybersecurity Incident Investigation**

## **Overview**

In this activity, you will take on the role of a cybersecurity analyst investigating a security incident affecting **yummyrecipesforme.com**. Visitors reported being prompted to download a suspicious file, which redirected them to a malicious website. Your task is to analyze network traffic, document the incident, and recommend a security measure to prevent future attacks.

## **Scenario**

A former employee executed a **brute force attack** to access the website’s admin panel, leveraging a weak default password. After gaining access, they embedded **JavaScript malware** that prompted users to download an executable file. Running the file redirected users to **greatrecipesforme.com**, a fraudulent site containing malware. The incident was discovered when multiple customers reported suspicious activity, and the website owner was locked out of the admin panel. Your team must analyze network traffic using **tcpdump**, document the attack, and propose a security measure to prevent similar breaches.

## **Instructions**

### Step 1: Access the template

- Use the provided link to access the **[Incident report analysis](./Incident-report-template.docx)** template.

### Step 2: Access the supporting materials

- **[tcpdump traffic log](./tcpdump-traffic-log.docx)**
- **[How to read the tcpdump log](./How-to-read-the-tcpdump-traffic-log.docx)**

### Step 3: Identify the Network Protocol

- Analyze the **tcpdump traffic log** to determine which protocol was used in the attack.
- Refer to the **TCP/IP model** to classify the protocol.

### Step 4: Document the Incident

- Summarize the **attack method**, **affected components**, and **network behavior** observed in the logs.
- Ensure documentation is factual, detailing how the attack was discovered and verified.

### Step 5: Recommend a Security Measure

- Propose a **preventative measure** for brute force attacks, such as **strong passwords, two-factor authentication, login monitoring, or login attempt limits**.
- Justify why your chosen security measure is effective.

## **What to Include in Your Response**

- Name one **network protocol** identified during the investigation.
- Provide a **detailed incident report** based on network analysis.
- Recommend **one security measure** to mitigate future attacks.

## **Key Takeaways**

As a security analyst, you might not always know exactly what is the primary cause of a network issue or a possible attack. But being able to analyze the protocols involved will help you make an informed assumption about what happened. This will allow you and your team to begin resolving the issue.

