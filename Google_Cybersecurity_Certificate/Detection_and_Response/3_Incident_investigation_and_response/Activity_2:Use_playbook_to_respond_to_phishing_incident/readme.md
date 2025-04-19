# **Phishing Incident Response**

## **Overview**

In this activity, you will respond to a phishing incident involving a malicious file hash—the same SHA256 hash you verified as malicious in a previous activity. Following a playbook, you'll investigate and resolve the incident's alert ticket. Playbooks provide step-by-step guidance for coordinated, effective, and timely incident response, helping security teams minimize impact and reduce response time.

## **Scenario**

You are a level-one SOC analyst at a financial services company. A phishing alert was triggered due to a suspicious file downloaded on an employee's computer. The file hash has already been confirmed as malicious. Now, you must follow your organization's security policies and playbook to complete the investigation and resolve the alert.

Use the **incident handler's journal** (from a previous activity) to document findings. At the end, update the alert ticket with your conclusions.

## **Instructions**

### Step 1: Access the template

- Use the **[Alert ticket](./Alert-ticket.docx)** template for this activity.

### Step 2: Access supporting materials

- Open the **[Phishing Playbook (with flowchart)](./Phishing-incident-response-playbook.docx)**. Keep it accessible for reference.

### Step 3: Review the playbook and flowchart

- Study the **Phishing Playbook** (detailed written steps) and **Flowchart** (visual guide) to understand the response process.
- Note: Playbooks vary by organization based on policies and procedures.

### Step 4: Update the alert ticket status

- In the **Alert ticket**, set the *Ticket status* dropdown to **Investigating**.

### Step 5: Evaluate the alert

- Skip the initial alert receipt step (already done). Focus on:
  - **Alert severity**: Medium/High may require escalation.
  - **Sender details**: Check for inconsistencies (e.g., mismatched email/name).
  - **Message body**: Look for grammatical errors.
  - **Attachments/links**: Confirm malicious file attachment (previously verified).
- Answer the **5 W's** to contextualize the incident:
  - **Who** caused it?
  - **What** happened?
  - **When** did it occur?
  - **Where** was it detected?
  - **Why** did it happen?
- Document 2–3 reasons supporting the alert's legitimacy in your journal.

### Step 6: Determine escalation

- Refer to **Playbook Steps 3.0–3.1**: Confirm malicious attachment (already verified).
- If escalation is needed, proceed to **Step 3.2**. Otherwise, move to **Step 4**.

### Step 7: Update the alert ticket status

- Update the *Ticket status* to **Escalated** or **Closed**.
- In *Ticket comments*:
  - Summarize the alert and actions taken.
  - Provide 2–3 reasons for escalation/closure, citing specific alert details.

## **What to Include in your response**

- Updated *Ticket status* (dropdown selection).
- Brief description of the alert in *Ticket comments*.
- 2–3 sentences justifying escalation/closure with evidence from the alert.
