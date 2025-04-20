# **Splunk Cloud Data Analysis**

## **Activity Findings**

### Question Answers

1. **How many events are contained in the main index across all time?**✅ **Over 100,000**
2. **Which field identifies the name of a network device or system from which an event originates?**✅ **host**
3. **Which of the following hosts used by Buttercup Games contains log information relevant to financial transactions?**✅ **vendor_sales**
4. **How many failed SSH logins are there for the root account on the mail server?**
   ✅ **More than 100**

---

## **Incident Handler's Journal Notes**

### Search Observations

- Initial broad search (`index="main"`) returned **137,892 events**
- After filtering to `host=mailsv`, results narrowed to **9,416 events**
- Final search (`fail* root`) revealed **327 failed root login attempts** on the mail server

### Security Concerns Identified

- **Brute force attack pattern**: Multiple rapid failed login attempts from same IP ranges
- **Vulnerable configuration**: Root account exposed to SSH attacks (should be disabled)
- **Missing safeguards**: No apparent account lockout mechanism after multiple failures

### Key Fields Analysis

| Field          | Critical Value     | Security Relevance            |
| -------------- | ------------------ | ----------------------------- |
| `host`       | mailsv             | Primary attack target         |
| `source`     | /mailsv/secure.log | Contains auth failure records |
| `sourcetype` | secure-2           | Standard SSH log format       |

---

## **Recommended Actions**

1. **Immediate**:

   - Disable root SSH access
   - Implement fail2ban or similar protection
   - Review firewall rules for suspicious source IPs
2. **Follow-up**:

   - Conduct forensic analysis on affected server
   - Update SSH configuration to use key-based auth
   - Monitor for subsequent attack patterns

---

## **Search Optimization Notes**

- Used wildcard (`fail*`) to capture all failure variants
- Combined field filters (`host=mailsv`) with keyword searches
- Verified results across multiple time ranges for consistency
- Confirmed data integrity through source/sourcetype validation
