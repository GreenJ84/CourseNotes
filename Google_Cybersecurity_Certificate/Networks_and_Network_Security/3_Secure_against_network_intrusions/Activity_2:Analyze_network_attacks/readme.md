# **Network Intrusion Analysis Activity**

## **Overview**

In this activity, you will analyze a security incident affecting a company's website. You will identify the likely cause of the service interruption, explain how the attack occurred, and describe its negative impact on the network. This exercise will help you understand how network attacks affect performance and how to mitigate future incidents.

## **Scenario**

You are a security analyst for a travel agency that relies on its website for advertising promotions and assisting employees in finding vacation packages. One afternoon, an automated monitoring alert notifies you of a web server issue. When you attempt to access the website, you receive a connection timeout error.

Using a packet sniffer, you detect an unusually high number of **TCP SYN requests** from an unfamiliar IP address, causing the server to become overwhelmed and unresponsive. Recognizing a **potential SYN flood attack**, you take the web server offline temporarily for recovery and configure the firewall to block the attacker’s IP. However, you know this solution is temporary, as attackers can spoof different IP addresses. You must report this incident to your manager, explaining the attack type and its impact while suggesting next steps to prevent future disruptions.

## **Instructions**

### Step 1: Access the Cybersecurity Incident Report Template

- **[Cybersecurity Incident Report Template](./Incident-report-template.docx)**.

### Step 2: Review Supporting Materials

- **[Wireshark TCP/HTTP log](./Wireshark-TCP_HTTP-log.csv)**
- **[How to read a Wireshark TCP/HTTP log](./How-to-read-a-Wireshark-TCP_HTTP-log.docx)**

### Step 3: Identify the Type of Attack

- Reflect on different network intrusion attacks.
- Consider symptoms such as excessive **TCP SYN requests** and a **connection timeout error** when diagnosing the issue.
- Determine whether the attack is a **Denial of Service (DoS) or Distributed Denial of Service (DDoS)**.
- Record your findings in **Section 1** of the Cybersecurity Incident Report.

### Step 4: Explain the Attack's Impact

- Analyze the **Wireshark log** and explain how the SYN flood attack is affecting the web server.
- Describe how this attack disrupts network performance, preventing employees from accessing the website.
- Discuss potential security measures to **prevent** similar attacks in the future.
- Record your analysis in **Section 2** of the Cybersecurity Incident Report.

## **What to Include in Your Response**

- The **name of the attack** (e.g., **SYN flood attack**).
- A **description of how it negatively impacts network performance** and **prevents normal website access**.
- Optional: Recommendations for **preventing future attacks**.
