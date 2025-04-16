# **Introduction to Detection and Response**

This module introduces the fundamentals of incident detection and response. It covers how cybersecurity professionals identify, verify, and manage malicious threats, as well as the tools and processes used throughout the incident response lifecycle. Learners are reintroduced to key frameworks like NIST CSF and begin using an incident handler’s journal to track investigations.

## **Learning Objectives**

- Explain the lifecycle of an incident
- Determine the roles and responsibilities of incident response teams
- Describe tools used in the documentation, detection, and management of incidents

---

## **The Incident Response Lifecycle**

### Importance of Frameworks

- Incident response frameworks provide structure and consistency for handling incidents.
- They are customizable and help standardize processes across organizations.

### NIST Cybersecurity Framework (CSF)

- CSF consists of five core functions: **Identify, Protect, Detect, Respond, Recover**.
- This course emphasizes the final three stages:
  - **Detect** malicious activity
  - **Respond** appropriately
  - **Recover** systems and services

### NIST Incident Response Lifecycle

- A separate but related NIST framework outlines these four phases:
  1. **Preparation**
  2. **Detection and Analysis**
  3. **Containment, Eradication, and Recovery**
  4. **Post-Incident Activity**
- The process is cyclical, not linear—steps may overlap as new information surfaces.

### Defining Security Incidents

- NIST defines a security incident as any occurrence that jeopardizes confidentiality, integrity, or availability—or violates laws or policies.
- Key distinction:
  - **Events**: Observable occurrences (e.g., login attempts, password resets)
  - **Incidents**: Events that involve unauthorized actions or policy violations
  - **All incidents are events, but not all events are incidents**

### Documenting Incidents

- Analysts must track the **Who, What, When, Where, Why** of each incident.
- Final reports rely on clear documentation of findings and evidence.
- An **incident handler’s journal** is introduced as a tool to track observations and actions during investigations.

---

## **Incident Response Operations**

### Team-Based Response

- Effective incident response requires collaboration across **security and non-security professionals**.
- **Computer Security Incident Response Teams (CSIRTs)** manage incidents, provide resources for response/recovery, and help prevent future events.
- Cross-functional collaboration is key—e.g., working with legal for compliance or PR for public disclosures.

### CSIRT Roles and Structure

- CSIRTs vary by organization and may be known as CSIRT, IHT, or SIRT.
- Common roles:
  - **Security Analyst**: Investigates alerts, triages issues, escalates critical incidents.
  - **Technical Lead**: Manages technical response (e.g., containment, eradication), aligns with business priorities.
  - **Incident Coordinator**: Oversees incident process, coordinates across departments, maintains communication.
- Other possible roles: Communications Lead, Legal Lead, Planning Lead, etc.

### CSIRT Operations – Command, Control, Communication

- **Command**: Leadership and direction.
- **Control**: Managing technical response tasks.
- **Communication**: Keeping all stakeholders informed.
- Clear structure ensures efficient response and reduces confusion.

### Security Operations Center (SOC)

- A **SOC** is a team/unit focused on monitoring and responding to threats. Often a standalone unit or part of a CSIRT.
- Responsible for **blue team activities** like threat monitoring and response.
- SOC Structure:
  - **Tier 1 SOC Analyst (L1)**: Monitors alerts, triages and escalates.
  - **Tier 2 SOC Analyst (L2)**: Deeper investigation, tool configuration.
  - **Tier 3 SOC Lead (L3)**: Advanced detection techniques, team operations.
  - **SOC Manager**: Team leadership, hiring, performance management, reporting to stakeholders.
- Other specialized roles:
  - **Forensic Investigators**: Analyze digital evidence.
  - **Threat Hunters**: Identify new or advanced threats using intelligence.

### Incident Response Plans

- **Incident Response Plan**: Formal document outlining procedures to handle incidents.
- Based on organizational needs (size, mission, industry, etc.).
- Common components:
  - **Procedures**: Step-by-step response guidance.
  - **System Info**: Network diagrams, logging, asset inventory.
  - **Docs**: Contact lists, templates, forms.
- Plans must be **reviewed and tested regularly** using tabletops or simulations.
- Exercises identify process gaps and ensure team familiarity.

---

## **Incident Response Tools**

Like a carpenter with various tools, security analysts rely on multiple tools to detect, analyze, and document incidents.

### Tool Categories

- **Documentation Tools**: Collect, compile, and preserve evidence.
- **Detection & Management Tools**: Monitor systems to flag events for investigation.
- **Investigative Tools**: Analyze events (e.g., packet sniffers).

#### 🧰 Documentation Tools

- **Purpose**: Record and communicate important incident-related info (the 5 W’s: who, what, where, when, and why).
- **Forms**: Audio, digital, handwritten, or video formats.
- **Examples**:
  - Word processors: Google Docs, OneNote, Notepad++
  - Ticketing systems: Jira
  - Others: Google Sheets, audio recorders, cameras, handwritten notes
- **Types of Documentation**:
  - Playbooks
  - Incident handler’s journal
  - Policies, plans, final reports
- **Effective Documentation**:
  - Reduces confusion during incidents.
  - Must be **clear, consistent, and accurate**.

#### 🕵️‍♂️ Detection Tools

- **Purpose**: Monitor networks/systems for suspicious activity, trigger alerts, and sometimes prevent intrusions.
- **Forms**: Hardware, software, or cloud-based solutions.
- **Examples**:
  - Network-based: Zeek, Snort®, Suricata
  - Host-based: OSSEC, Wazuh
  - Cloud-based: AWS GuardDuty, Azure Sentinel
- **Types of Detection**:
  - Signature-based: Matches known patterns of malicious activity.
  - Anomaly-based: Identifies deviations from normal behavior.
  - Behavioral-based: Uses machine learning to detect unusual activity.
- **Effective Detection**:
  - Provides real-time visibility into threats.
  - Reduces response time by generating actionable alerts.

##### Detection Categories

- **True Positive**: Correct alert
- **True Negative**: No threat, no alert
- **False Positive**: Incorrect alert (non-threat)
- **False Negative**: Missed real threat (very dangerous)



#### 🔍 Investigative Tools

- **Purpose**: Analyze events, uncover root causes, and gather evidence for incident resolution.
- **Forms**: Software applications, command-line tools, or specialized hardware.
- **Examples**:
  - Packet analyzers: Wireshark, tcpdump
  - Log analysis tools: Splunk, ELK Stack
  - Forensic tools: Autopsy, FTK, EnCase
- **Types of Investigations**:
  - Network analysis: Examines traffic for anomalies.
  - Endpoint analysis: Investigates device activity.
  - Memory analysis: Analyzes volatile memory for artifacts.
- **Effective Investigation**:
  - Requires detailed documentation of findings.
  - Must follow chain-of-custody protocols for evidence handling.

---

#### 🛠️ Tool Comparison Table

| Capability                  | IDS | IPS | EDR |
|----------------------------|-----|-----|-----|
| Detects malicious activity | ✅  | ✅  | ✅  |
| Prevents intrusions        | ❌  | ✅  | ✅  |
| Logs activity              | ✅  | ✅  | ✅  |
| Generates alerts           | ✅  | ✅  | ✅  |
| Behavioral analysis        | ❌  | ❌  | ✅  |


### Common Tools

#### 🔍 IDS (Intrusion Detection System)

- **Function**: Monitors & alerts on malicious activity; **does NOT stop** it.
- **Examples**: Zeek, Suricata, Snort®, Sagan
- **Use Case**: Alerts on unusual logins (e.g., unknown IP at odd time)


#### 🔒 IPS (Intrusion Prevention System)

- **Function**: Monitors, alerts, and **actively stops** intrusions.
- **Example**: Can update router ACLs to block traffic.
- **Dual-Function Tools**: Suricata, Snort, and Sagan (IDS + IPS)


#### 💻 EDR (Endpoint Detection and Response)

- **Function**: Monitors **endpoints** (devices) for malicious behavior.
- **Advanced Features**:
  - Behavioral analysis using ML/AI
  - Automated threat mitigation
- **Examples**: Open EDR®, Bitdefender™, FortiEDR™


#### 📊 SIEM (Security Information and Event Management)

- **SIEM** collects, analyzes, and normalizes log data from multiple sources (e.g., firewalls, IDS/IPS, databases) to help detect threats in real-time.
- Works like a **car dashboard**—aggregates status from various components in one view.

- **SIEM Benefits**:
- Centralized log access
- Real-time monitoring and alerting
- Historical log storage and retention

##### Three Key Steps

1. **Collect & Aggregate** data (logs from diverse systems)
    - Example log:

      ```txt
      April 3 11:01:21 server sshd[1088]: Failed password for user nuhara from 218.124.14.105 port 5023
      ```

    - Parsed version:

      ```txt
      host = server
      process = sshd
      source_user = nuhara
      source_ip = 218.124.14.105
      source_port = 5023
      ```

2. **Normalize** data (standardizes format for analysis)
3. **Analyze** data (apply rules to detect threats)
    - May include **correlation** to identify patterns across multiple events.

##### Popular SIEM Tools

- **AlienVault® OSSIM™**
- **Chronicle**
- **Elastic**
- **Exabeam**
- **IBM QRadar®**
- **LogRhythm**
- **Splunk**


#### ⚙️ SOAR (Security Orchestration, Automation, and Response)

- Automates **incident analysis, response, and case management**.
- Complements SIEM by handling actions post-alert.
- Allows analysts to **view and manage incidents** in a centralized system.

---

## **Key Takeaways**

- Incident response is a structured, team-driven process built on foundational security knowledge.
- Frameworks like the NIST CSF and NIST IR lifecycle guide incident response procedures.
- Analysts must distinguish between general events and actual incidents.
- Documentation is vital
- Tools like an incident handler’s journal support effective investigations and reporting.
- Pattern recognition and analytical skills are essential for identifying and mitigating threats.
- CSIRTs and SOCs rely on structured roles, clear communication, and collaboration to handle incidents effectively.
- Security analysts work with both internal team members and external departments.
- Response plans are essential and must be kept current and regularly tested.
- Understanding team structure and responsibilities improves coordination during incident response.
- Detection tools are essential for gaining visibility into security events.
- **IDS** alerts, **IPS** blocks, and **EDR** uses behavioral intelligence and automation to respond.
- **SIEM tools** provide real-time visibility and alerting; **SOAR tools** help automate response and streamline workflows.
