# **Vulnerability Assessment Report**

**`1st January 2025`**

---

## **System Description**

The server hardware consists of a powerful CPU processor and 128GB of memory. It runs on the latest version of the Linux operating system and hosts a MySQL database management system. It is configured with a stable network connection using IPv4 addresses and interacts with other servers on the network. Security measures include SSL/TLS encrypted connections.

---

## **Scope**

The scope of this vulnerability assessment relates to the current access controls of the system. The assessment will cover a period of three months, from June 20XX to August 20XX. NIST SP 800-30 Rev. 1 is used to guide the risk analysis of the information system.

---

## **Purpose**

The purpose of this vulnerability assessment is to evaluate the security controls surrounding the database server, a critical asset for the organization. The server stores valuable operational and customer data that is essential for day-to-day business functions. Securing the data is paramount to prevent unauthorized access, data breaches, and potential downtime that could disrupt services. A compromised server could lead to financial losses and damage to the company’s reputation.

---

## **Risk Assessment**

| **Threat Source**          | **Threat Event**                        | **Likelihood** | **Severity** | **Risk** |
| -------------------------------- | --------------------------------------------- | :------------------: | :----------------: | :------------: |
| Hacker (Outsider)                | Conduct "man-in-the-middle" attack            |          3          |         3         |       9       |
| Competitor                       | Obtain sensitive information via exfiltration |          1          |         2         |       2       |
| Advanced Persistent Threat (APT) | Install persistent network sniffers           |          2          |         3         |       6       |

*`Risk Score = Likelihood × Severity`*

---

## **Approach**

In this assessment, a qualitative method was used to determine the potential risks by evaluating the intent and capability of various threat sources. The selected threats—conducting a man-in-the-middle attack, exfiltration of sensitive data, and installation of network sniffers—were chosen based on their likelihood and potential impact on the system. These events were deemed significant due to the critical nature of the data stored and the possible disruption to business operations. This approach allows decision-makers to prioritize security measures based on both the probability and severity of the threats.

---

## **Remediation Strategy**

To mitigate these risks, it is recommended to implement a multi-layered security strategy. This includes robust authentication, authorization, and auditing mechanisms to ensure only legitimate users access the system. Additional controls such as multi-factor authentication (MFA), role-based access control, and IP allow-listing for corporate offices should be employed. Enhancing encryption protocols by moving from SSL to TLS for data in transit further strengthens the security posture, reducing the chance of interception and unauthorized access.
