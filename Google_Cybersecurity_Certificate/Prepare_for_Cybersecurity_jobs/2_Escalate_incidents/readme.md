# **Escalate Incidents**


This module focuses on the **importance of incident escalation** in cybersecurity. It introduces learners to escalation procedures, how to recognize and classify incidents, and the potential impact of both escalated and neglected issues. Effective escalation prevents minor events from becoming major breaches.

## **Learning Objectives**

- Define incident escalation from a security analyst’s perspective
- Understand the various security incident classifications
- Recognize how incidents impact business operations
- Know **when and how to escalate** security incidents

---

## **What Is Incident Escalation?**

- **Incident Escalation** = Identifying → Triaging → Handing off to the appropriate team/individual
- Not all issues need to be escalated, but it's crucial to know **what to escalate and when**.
- Your job: Recognize signs, follow processes, and **alert the right people**.

> “Even the smallest incident can grow into a major threat if left unaddressed.”

### Skills Needed to Escalate

1. **Attention to Detail**
   Spot small inconsistencies or suspicious behavior.
2. **Following Protocols**
   Every org has its own escalation guidelines—know and follow them carefully.

#### Escalation Tips

- **Know your escalation policy**
- **Follow it consistently**
- **Ask questions when in doubt**
- **Prioritize based on asset criticality**

### Roles & Responsibilities in Escalation

Knowing the right contact helps ensure fast and appropriate responses.

| **Role** | **Responsibility** | **Escalation Scenario** |
|----------|---------------------|--------------------------|
| **Data Owner** | Manages access and use of data; accountable for classification and protection | Unauthorized access to software |
| **Data Controller** | Decides how personal/customer data is used and processed | Breach of sensitive customer data |
| **Data Processor** | Processes data per data controller’s instructions; often a third party | Vendor fails to secure customer data |
| **Data Custodian** | Implements security controls, grants/revokes access, creates data handling policies | Security controls are compromised |
| **Data Protection Officer (DPO)** | Ensures legal and regulatory data compliance; audits internal controls | Privacy policy violations or compliance issues |

#### Roles in Large Orgs

Even in big orgs, every role counts. From the **CISO** to **PR** and **legal**, escalation touches multiple departments depending on the incident's nature and scope.

- **Smaller orgs** may have just 1–2 security people, so **every action matters even more**.
- **Security is like an assembly line**—your decisions impact everyone down the chain.

---

## **Incident Escalation Process**

Each company has a **unique policy**, but general components include:

- **Who to notify** when a security alert occurs
- **Escalation chain** if the first contact is unavailable
- **Communication method** (e.g., IT desk, Slack, ticketing system)

### Breach Notification Laws

- Most regions require **legal notification** if **PII** is exposed
- PII = personal ID numbers, medical records, addresses, etc.
- As a security analyst, you should be familiar with **current local regulations**

---

### **To Escalate or Not to Escalate**

This section focuses on identifying **incident types** and understanding **who to notify** based on the nature of the issue. It also highlights how **roles and responsibilities** within the security team influence the escalation process.

### Incident Classification Types

#### 1. **Malware Infection**

- **Definition**: When malicious software (malware) infiltrates a system.
- **Examples**:
  - **Phishing** – simpler, trick-based malware
  - **Ransomware** – more advanced; locks critical data, demands ransom
- **Signs**: Sluggish network, system performance issues, blocked access to files
- **Always escalate**, as malware threatens organizational integrity and sensitive data.


#### 2. **Unauthorized Access**

- **Definition**: When someone gains digital or physical access without permission.
- **Common Cause**: Brute force attacks using trial-and-error password cracking.
- **Must be escalated**, but **urgency depends on how critical the system is**.


#### 3. **Improper Usage**

- **Definition**: When employees violate Acceptable Use Policies (AUP)
- **Examples**:
  - Accessing software for personal use
  - Viewing or tampering with others’ data
- **Complexity**:
  - **Unintentional** – e.g., unaware of a policy
  - **Intentional** – e.g., knowingly misusing resources
- **Always escalate to a supervisor**—intent is often unclear and needs further investigation.

### Incident Criticality Levels

- **Initial escalation**: Based on what the analyst knows, usually marked as **medium** if unclear.
- **Post-review**: An incident handler may **adjust** the criticality level (↑ or ↓) based on deeper analysis.

---

## **Timing is Everything**

This section emphasizes the importance of **escalating incidents in a timely manner**, following your organization’s **escalation policy**, and understanding which incidents deserve **urgent attention** based on their potential business impact.

### What Happens If You Wait?

- **Delayed escalation** can result in small issues snowballing into major incidents.
- **Example scenario**:
  - Unusual log activity in a banned app is noticed but not reported.
  - Days later → **Data breach** at a manufacturing site traced back to the same app.
  - **Outcome**: Operations halted, financial loss, and reputational damage.


### Incident Impact Depends on the Asset

| **Incident Type** | **Example** | **Urgency** |
|-------------------|-------------|-------------|
| Forgotten password | Repeated failed logins | Low |
| Unauthorized access to manufacturing software | Disrupts operations | High |
| Malware on unused legacy system | Doesn’t affect core functions | Low to Medium |
| Exposure of PII | Customer data at risk | High |

**Tip**: Understand which **assets** are essential to business operations. The more critical the asset, the **higher the priority**.


---

## **Your Role in Escalation**

### Your decisions matter

- Analysts must quickly decide **what to escalate and when**.
- Good decisions = Protection of data, systems, and operations.

### Trust your instincts—but ask questions

- Don’t hesitate to **ask supervisors** for clarity.
- Confidence grows with understanding the **escalation process**.

### Know your priorities

- Review onboarding materials and security policies to learn which assets are mission-critical.
- Apply that knowledge when assessing **incident severity**.

---

## **Key Takeaways**

- Escalating incidents protects business operations and customer data.
- Low-level issues are **not always harmless**—they may indicate a bigger problem.
- Familiarize yourself with your org’s **escalation protocol** and **legal obligations**.
- Your decisions in incident handling help keep the business safe.

- Know the **types of incidents** and **which are urgent**.
- Some issues (e.g., malware, unauthorized access) must be **escalated immediately**.
- **Improper usage** may seem minor but should always be escalated for review.
- Understand the roles on your team—even if you report to a direct supervisor, knowing the bigger picture helps you escalate smarter.

- Timely incident escalation can **prevent serious damage**.
- Understand your org's **escalation policy** and **asset priorities**.
- Entry-level analysts are expected to know **what to escalate, when, and to whom**.
- If you're unsure, **always ask**—better to clarify than miss something important.
