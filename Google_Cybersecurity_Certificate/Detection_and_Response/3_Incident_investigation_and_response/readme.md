# **Incident Investigation and Response**

This module explores the full lifecycle of incident detection, investigation, analysis, and response, following the NIST framework. Learners practice using tools like VirusTotal to investigate suspicious file hashes, learn documentation and evidence handling practices, and reconstruct timelines based on incident artifacts.

---

## **Learning Objectives**

- Perform artifact investigations to analyze and verify security incidents.
- Illustrate documentation best practices during the incident response lifecycle.
- Assess alerts using evidence and determine the appropriate triaging steps.
- Identify steps to contain, eradicate, and recover from an incident.
- Describe the processes and procedures involved in the post-incident phase.

---

## **Detection and Analysis Phase of the Lifecycle**

- Detection is the prompt identification of potential security events.
- Not all events are incidents, but all incidents begin as events.
- Intrusion Detection Systems (IDS) and Security Information and Event Management (SIEM) tools collect and correlate event data to detect anomalies.
- Analysis involves validating and investigating alerts to confirm if a true security incident has occurred.

### Methods of Detection

| Method                            | Description                                                                                                                      |
| --------------------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| Intrusion Detection Systems (IDS) | Detect suspicious network traffic and generate alerts.                                                                           |
| SIEM Tools                        | Collect, normalize, and analyze security data from multiple sources.                                                             |
| Threat Hunting                    | Proactive, human-led searches for threats not caught by automated tools.                                                         |
| Threat Intelligence               | Evidence-based data from sources like industry reports, government advisories, and threat feeds that provide context on threats. |
| Cyber Deception                   | Techniques like honeypots and decoy files used to lure attackers and trigger alerts.                                             |

### Challenges in Detection

- Detection tools can miss incidents due to misconfiguration or limited deployment.
- High alert volumes are common and often caused by overly broad alerting rules or legitimate malicious activity.
- False positives are frequent and require skilled analysis to triage accurately.

### Monitoring Techniques

- **Comprehensive Logging**: Monitor execution, access, code commit, and deployment logs.
- **SIEM Integration**: Centralizes anomaly detection, alerting, and rule-based monitoring.
- **Real-time Alerting**: Notifies security teams of critical pipeline anomalies.
- **Performance Monitoring**: Identifies indirect signs of attack (e.g., slowdowns or resource issues).
- **Continuous Vulnerability Scanning**: Detects outdated or vulnerable tools and plugins used in CI/CD.

#### Monitoring CI/CD Pipelines

Continuous monitoring of CI/CD pipelines is critical to detect threats in the software supply chain. This includes unauthorized code changes, suspicious deployments, and exposed secrets.

---

## **Indicators of Compromise**

Understanding and analyzing IoCs helps improve detection, response, and contextual understanding during incident investigations.

### Common Indicators of Compromise (IoCs)

- Unauthorized or suspicious code changes
- Deployments to unexpected environments
- Introduction of vulnerable or unofficial dependencies
- Anomalies in pipeline execution (e.g., failures, delays, order changes)
- Attempts to access hardcoded or unapproved secrets

#### Indicators of Compromise (IoCs) vs. Indicators of Attack (IoAs)

| Type           | Description                                                                                                                                              |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **IoCs** | Observable evidence of a potential security incident (e.g., malicious file names, IP addresses). Useful after an event has occurred.                     |
| **IoAs** | Behavioral indicators that suggest an ongoing attack (e.g., a process initiating a suspicious network connection). Focus on attacker methods and intent. |

> Note: IoCs alone do not confirm a security incident; they may also result from system issues or human error.

### Pyramid of Pain

Developed by David J. Bianco, the **Pyramid of Pain** categorizes IoCs by the difficulty they impose on attackers when blocked.

| Indicator Type                                       | Description                                               | Difficulty to Evade |
| ---------------------------------------------------- | --------------------------------------------------------- | ------------------- |
| **Hash Values**                                | Unique identifiers for known malicious files.             | Easy                |
| **IP Addresses**                               | IPs used by attackers (e.g.,`192.168.1.1`).             | Easy                |
| **Domain Names**                               | Web addresses used by attackers.                          | Easy                |
| **Network Artifacts**                          | Evidence in network protocols (e.g., User-Agent strings). | Medium              |
| **Host Artifacts**                             | Evidence on infected hosts (e.g., malicious filenames).   | Medium              |
| **Tools**                                      | Software used by attackers (e.g., password crackers).     | Hard                |
| **Tactics, Techniques, and Procedures (TTPs)** | Behavioral patterns of attackers.                         | Very Hard           |

Blocking higher-level indicators causes more disruption for attackers and improves defense effectiveness.

### Analyzing IoCs with Investigative Tools

Blocking a single IoC may not be enough. Security analysts must **add context** to IoCs to form a more complete picture of a potential incident.

**Example:**
Blocking a malicious IP does little without understanding related activity (e.g., abnormal network connections, associated processes).

#### Investigative Tools for IoC Analysis

| Tool                                                            | Description                                                                                                                         |
| --------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **[VirusTotal](https://www.virustotal.com/gui/home)**        | Analyzes files, IPs, domains, and URLs. Provides details, detection verdicts, related artifacts, behaviors, and community comments. |
| **[Jotti&#39;s Malware Scan](https://virusscan.jotti.org/)** | Free malware scanning service using multiple antivirus engines.                                                                     |
| **[Urlscan.io](https://urlscan.io/)**                        | Scans and reports on URLs.                                                                                                          |
| **[MalwareBazaar](https://bazaar.abuse.ch/browse/)**         | Malware sample repository for research and threat intelligence.                                                                     |

> **Note**: Data uploaded to these tools may be publicly shared. Avoid submitting personal or sensitive information.

##### VirusTotal Report Tabs

- **Detection**: Shows verdicts from multiple security vendors.
- **Details**: Metadata (hashes, file type, size, timestamps).
- **Relations**: Connected artifacts (e.g., IPs, URLs).
- **Behavior**: Actions observed in sandbox environments.
- **Community**: Insights from other analysts.
- **Vendor Ratio & Community Score**: Overall risk score based on detections and community input.

### Threat Intelligence & Crowdsourcing

- **Threat Intelligence**: Evidence-based data (e.g., attack details, actor profiles) used to understand threats and guide response actions.
- **Crowdsourcing**: Global sharing of threat data from vendors, governments, and researchers enhances detection and defense.

Examples:

- **ISACs**: Share industry-specific threat intel (e.g., energy, healthcare).
- **OSINT**: Gathers info from public sources about threats and actors.

> Crowdsourced data is key in stopping repeat attacks by alerting others to new threats.

---

## **Create and Use Documentation**

Documentation improves operations and legal readiness, with special emphasis on the **chain of custody** and **playbooks**.

### Benefits of Documentation

- **Transparency**

  - Creates an audit trail of actions taken during security incidents.
  - Helps demonstrate compliance with regulations and legal requirements.
  - Example: *Chain of custody forms* help track and prove integrity of evidence.
- **Standardization**

  - Establishes repeatable processes for consistency and quality.
  - Helps train new staff and ensures continuity.
  - Example: *Incident response plans* outline predefined procedures for responding to incidents.
- **Clarity**

  - Ensures teams understand roles, actions, and expectations.
  - Clear documentation avoids confusion, especially during high-stress incidents.
  - Example: *Playbooks* offer detailed, actionable guidance.

### Best Practices for Creating Documentation

- **Know your audience**
  Tailor language and detail level based on the reader (e.g., SOC analyst vs CEO).
- **Be concise**
  Keep documentation focused and to-the-point. Use summaries for quick consumption.
- **Update regularly**
  Documentation must evolve with new threats, tools, and lessons from incidents.

### Chain of Custody

- **Definition**: Process of documenting the possession and control of evidence throughout an incident lifecycle.
- **Purpose**: Maintains evidence integrity for legal proceedings and internal accountability.
- **Steps**:
  1. Evidence is write-protected and hashed.
  2. Each transfer of evidence is logged.
  3. Any tampering can be detected via hash verification.
- **Form Contents**:
  - Description (e.g., hostname, MAC/IP address)
  - Custody log: who transferred/received, date/time, reason for transfer
- **Broken Chain**: Missing or incorrect entries compromise legal admissibility.

### Playbooks

- **Definition**: Step-by-step guides for incident response.
- **Purpose**: Reduce guesswork and increase efficiency during an incident.

#### Types

1. **Non-automated** – Fully manual (e.g., DDoS detection with manual log review)
2. **Automated** – Tasks handled by tools (e.g., SIEM/SOAR gathering logs)
3. **Semi-automated** – Combines automation with human oversight

- **Features**:
  - May include flowcharts, checklists
  - Useful in incidents like ransomware, DDoS, malware, data breaches
  - Must be updated regularly, especially after incidents (post-incident activity)

---

## **Response and Recovery**

### Incident Response Lifecycle: Contain, Eradicate, Recover

- **Containment**:

  - Stop the spread of threats (e.g., isolate infected systems).
  - Defined in the incident response plan.
- **Eradication**:

  - Fully remove malicious components (e.g., vulnerability scans, patching).
- **Recovery**:

  - Restore systems to normal operations (e.g., reimage systems, reset credentials, reconfigure firewalls).
  - Focus on **business impact** and **service continuity**.

### Triage in Incident Response

- Triage is used to **prioritize security alerts** based on urgency and impact, similar to how hospitals triage patients.
- **Purpose**: Optimize limited resources and ensure critical threats are addressed first.

#### Triage Process Steps

1. **Receive and Assess**

   - Determine alert validity: false positive vs true positive.
   - Consider alert history, known vulnerabilities, and severity.
2. **Assign Priority**
   Based on:

   - **Functional impact** (effect on business operations)
   - **Information impact** (confidentiality, integrity, availability)
   - **Recoverability** (feasibility and cost-effectiveness of recovery)
3. **Collect and Analyze**

   - Gather and document evidence.
   - Perform external research.
   - Escalate if necessary (to Tier 2 or manager).

#### Benefits of Triage

- **Efficient resource management**.
- **Standardized response** using documented playbooks.
- Ensures high-priority incidents are investigated thoroughly and quickly.

### Business Continuity Considerations

**Business Continuity Plan (BCP)**:

- Documents how to **maintain operations during and after incidents**.
- Ensures **critical business functions** can resume quickly.
- Different from **Disaster Recovery Plan (DRP)**, which focuses specifically on restoring IT systems after major disasters.

#### Example: Ransomware in Healthcare

- Can halt operations by encrypting critical data (e.g., medical records).
- Highlights importance of BCPs to ensure **essential services** continue.

#### Site Resilience Strategies

To ensure **availability during disruptions**:

- **Hot Site**: Fully operational duplicate; immediate switchover.
- **Warm Site**: Partially ready with updated systems; moderate activation time.
- **Cold Site**: Infrastructure present but not ready for immediate use.

---

## **Post-Incident Actions**

- The final phase of the NIST Incident Response Lifecycle.
- It focuses on reviewing the incident, identifying gaps, and making improvements to future incident response efforts.

### Post-Incident Activity Phase (NIST Lifecycle)

- Focused on identifying areas of improvement after an incident.
- Includes the development of important documentation such as the final report.
- Helps prevent similar incidents in the future through reflection and planning.

#### Key Terms

| Term                              | Definition                                                                                                                    |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| **Post-Incident Activity**  | The phase following containment, eradication, and recovery that involves review and improvement.                              |
| **Lessons Learned Meeting** | A post-mortem session involving all incident responders to evaluate the incident and determine how to improve future efforts. |
| **Final Report**            | A comprehensive document that details the timeline, investigation, and recommended actions following an incident.             |
| **Executive Summary**       | A concise overview of the incident and key findings, tailored for non-technical stakeholders.                                 |

#### Key Concepts

- **Final reports** and **lessons learned meetings** are central to this phase, enabling organizations to document findings, improve playbooks, and implement better controls.
- This phase is a learning-focused process, not about assigning blame, and is essential for strengthening an organization’s security posture.

##### Lessons Learned Meeting

- Should be conducted within two weeks after incident recovery.
- Involves all participants who played a role in the incident response.
- Aims to answer questions like:
  - What happened?
  - When did it occur?
  - Who discovered it?
  - How was it contained?
  - What were the recovery steps?
  - What could have been done differently?

Benefits:

- Fosters cross-functional learning and collaboration.
- Generates actionable recommendations for better incident handling.

Preparation Tips:

- Develop and share a meeting agenda in advance.
- Assign roles such as a moderator and a scribe to guide the discussion and record key takeaways.
- Reserved for major incidents such as ransomware attacks or large-scale breaches.

##### Final Report

- Captures all essential details of the incident based on the "who, what, where, when, and why" approach.
- Format and depth may vary depending on the intended audience.

Common Components:

- **Executive Summary**: High-level summary of the incident and key outcomes.
- **Timeline**: Chronological breakdown of events with specific timestamps.
- **Investigation**: Details of how the incident was detected and analyzed.
- **Recommendations**: Suggested steps for preventing similar incidents in the future.

Writing Tip:

- Tailor the content and tone of the report to suit the intended audience, especially if it's going to non-technical stakeholders.

---

## **Key Takeaways**

- Automated monitoring and threat detection in CI/CD pipelines improves incident response and limits attacker impact.
- Understanding and reacting to IoCs enables a proactive security posture.
- Integrating detection into development workflows supports fast and secure software delivery.
- IoCs and IoAs offer critical insight into threat detection and response.
- The Pyramid of Pain helps prioritize indicators by their defensive value.
- Adding context and using crowdsourced intelligence improves incident response effectiveness.
- Tools like VirusTotal help analyze IoCs and broaden understanding of threats.
- Effective documentation supports legal defensibility, operational consistency, and clarity during incident response.
- Chain of custody is essential when dealing with potential legal evidence.
- Playbooks help reduce response times and errors in chaotic situations.
- Documentation should always be clear, relevant, concise, and current.
- Triage is vital to handle alerts efficiently and mitigate risks.
- The response phase includes **containment**, **eradication**, and **recovery**.
- **BCPs and site resilience** ensure continuity of operations even during severe incidents.
- Post-incident actions are critical for improving future incident response efforts.
- Lessons learned meetings help teams reflect, share feedback, and align on improvements.
- Final reports serve as comprehensive records and can be used to support strategic decision-making and training.
