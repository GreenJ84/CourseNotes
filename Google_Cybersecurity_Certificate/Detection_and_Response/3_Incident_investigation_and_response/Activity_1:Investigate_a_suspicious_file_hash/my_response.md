# **Respond to a Phishing Incident**

## **Has the file been identified as malicious? Explain.**

**Yes**, the file has been identified as malicious.

**Explanation**:

- **Vendors’ Ratio**: A majority (58/72) of security vendors in VirusTotal flagged the file as malicious.
- **Community Score**: The community score is negative, indicating widespread consensus on malicious intent.
- **Detection Tab**: Vendors labeled the file with known malware names (e.g., `trojan.flagpro/fragtor`).
- **Behavioral Evidence**: Sandbox reports show suspicious actions (e.g., creating unauthorized executables, registry modifications).

---

## **A Table of IoCs**

| **Indicator Type**       | **Example**                                                                                        | **Source (VirusTotal Tab)** |
| ------------------------------ | -------------------------------------------------------------------------------------------------------- | --------------------------------- |
| **Hash Value (SHA-1)**   | `54e6ea4...bab527f6b`                                                                                  | Details                           |
| **IP Address**           | `114.114.114.114` (flagged by 3 vendors)                                                               | Relations → Contacted IPs        |
| **Domain Name**          | `http://org.misecure.com` (flagged by 12 vendors)                                                      | Relations → Domains              |
| **Network Artifact**     | `C:\Program Files (x86)\Google\GoogleUpdater\0fb9af77-100f-44a7-87c8-0a442d1da1db.tmp` (created file)  | Behavior → Sandbox Reports       |
| **TTP (MITRE ATT&CK®)** | -`Excecution` (TA0002)<br />- `Priviledge Escalation` (TA0004)<br />- `Cridential Access` (TA0006) | Behavior → MITRE ATT&CK          |
