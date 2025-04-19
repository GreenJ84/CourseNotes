
# Phishing Incident response

---

**Ticket ID**: A-2703
**Alert Message**: SERVER-MAIL Phishing attempt possible download of malware
**Severity**: Medium
**Details**: The user may have opened a malicious email and opened attachments or clicked links.
**Ticket status**: **Escalated**

**Ticket comments**:

> *"Employee downloaded password-protected attachment `bfsvc.exe` (SHA256: `54e6ea47eb04634d...`), confirmed malicious via threat intelligence. Email sender (`76tguyhh6tgrt7tg.su`) exhibits red flags: suspicious domain, grammatical errors, and impersonation of a job applicant. Escalating due to:
>
> 1. **Confirmed malware** (matching known malicious hash).
> 2. **High-risk context**: Targeted HR department with executable file.
> 3. **Sender anomalies**: Mismatched domain/IP (`114.114.114.114`)."*

---

### **Key Actions Taken**:

1. Validated attachment hash against threat feeds (pre-confirmed malicious).
2. Reviewed sender/receiver details (suspicious domain, HR target).
3. Followed playbook **Step 3.2** for escalation due to active threat
