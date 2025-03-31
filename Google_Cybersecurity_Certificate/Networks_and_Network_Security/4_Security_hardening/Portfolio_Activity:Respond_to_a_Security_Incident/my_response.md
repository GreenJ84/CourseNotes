# **NIST CSF Incident Report Analysis**

## **Summary**

A **DDoS attack** targeted the company’s internal network, causing a **two-hour service disruption** due to an overwhelming flood of **ICMP packets**. The attack exploited an **unconfigured firewall**, allowing malicious traffic to overwhelm network resources. The incident response team mitigated the attack by **blocking incoming ICMP packets**, shutting down non-essential services, and restoring critical operations.

## **Identify**

- **Attack Type:** Distributed Denial-of-Service (DDoS)
- **Affected Systems:** Internal network services, firewall, and critical business applications
- **Root Cause:** Unconfigured firewall allowed unrestricted ICMP traffic

## **Protect**

- Implement firewall rules to limit incoming ICMP traffic
- Enable **source IP verification** to block spoofed addresses
- Conduct regular **security audits** of network configurations
- Train IT staff on **firewall best practices** and attack prevention

## **Detect**

- Deploy **network monitoring tools** to analyze traffic patterns
- Use **Intrusion Detection Systems (IDS)** to flag abnormal ICMP activity
- Set up real-time alerts for **suspicious network behavior**
- Conduct regular **penetration testing** to identify vulnerabilities

## **Respond**

- Implement an **incident response plan** to contain and neutralize attacks
- Analyze **log files** and attack patterns for forensic investigation
- Coordinate with **ISPs** to mitigate large-scale attacks
- Improve **internal communication protocols** for faster incident response

## **Recover**

- Restore affected **network services and firewall configurations**
- Conduct a **post-incident review** to identify security gaps
- Update **incident response documentation**
- Strengthen **disaster recovery procedures** for future resilience

## **Reflections/Notes**

- This incident highlights the **importance of proactive firewall management**
- Regular **network audits** and **employee training** could have prevented this attack
- Integrating **automated security solutions** can improve real-time threat detection
- The NIST CSF approach ensures a **structured response and recovery process**
