# **Network Traffic and Logs Using IDS and SIEM Tools**

In this module, learners will explore the importance of logs and their role in supporting Intrusion Detection Systems (IDS) and Security Information and Event Management (SIEM) tools. The module begins with a conceptual overview of how logs are created, read, and analyzed in the context of security investigations.

Learners will develop a foundational understanding of IDS tools, with a focus on Suricata, and will learn how IDS rules generate alerts, events, and logs when malicious traffic is detected. The module also introduces SIEM tools like Splunk and Google SecOps (Chronicle), showcasing their features and demonstrating how to use search queries to investigate events of interest.

## **Learning Objectives**

- Discuss the importance of logs during incident investigation.
- Determine how to read and analyze logs during incident investigation.
- Describe how common IDS tools provide security value.
- Interpret the basic syntax and components of signatures and logs in IDS and NIDS tools.
- Describe how SIEM tools collect, normalize, and analyze log data.
- Perform queries in SIEM tools to investigate an incident.

---

## **Overview of Logs**


- Logs are records of events occurring on systems or networks.
- Essential to identifying, investigating, and responding to security incidents.
- Nearly every device can generate logs, and these logs help analysts understand what happened, when, where, and who was involved.
- *Note*: Due to the high volume of log data, it's critical to log efficiently—only capturing what’s relevant.

Logs are collected using log forwarders and centralized in repositories (like SIEM tools) for easier analysis and correlation. Analysts examine logs to detect unusual or malicious activity and reconstruct incidents using timestamps, actions, and user/system identifiers. Logs come in various formats like JSON, Syslog, XML, and CSV, each suited to different use cases.

Proper log management—collection, storage, retention, and protection—is crucial. Overlogging can lead to performance and cost issues, while underlogging risks missing critical data. Logs also need to be safeguarded against tampering, often through centralized log servers.

### Key Log Concepts

- **Event**: Any observable occurrence in a system or network.
- **Log**: A file or record that contains entries about events.
- **Log entry**: A single record detailing a specific event.
- **Log analysis**: The process of examining logs to identify events of interest.
- **Log forwarder**: A tool that collects and sends logs to a centralized location.
- **SIEM**: Security Information and Event Management tool that collects, aggregates, and analyzes log data.
- **Log formats**: The structure in which logs are recorded; varies by system and use case.

### Best Practices

- **Be selective in logging**: Capture only the most relevant data to reduce noise and improve performance.
- **Avoid overlogging**: Excessive logs can slow down searches and increase costs.
- **Protect log integrity**: Store logs on centralized servers to prevent tampering.
- **Use retention policies**: Especially important for compliance in regulated industries.
- **Normalize logs**: Convert diverse formats into a standard format for easier analysis.

### Types of Logs

| **Log Type**       | **Source**                                             |
|--------------------|--------------------------------------------------------|
| Network logs       | Firewalls, routers, switches, proxies                  |
| System logs        | Operating systems (Windows, macOS, Linux)              |
| Application logs   | Software applications                                  |
| Security logs      | IDS/IPS, antivirus software                            |
| Authentication logs| Login events (successful/failed)                       |

### Common Log Formats

| **Format** | **Description**                                                                                          |
|------------|----------------------------------------------------------------------------------------------------------|
| **JSON**   | Human-readable, uses key-value pairs, common in web/cloud environments.                                  |
| **Syslog** | Standard Unix format; includes header, structured-data, and message. Often used with centralized logging.|
| **XML**    | Uses tags to structure data; native to Windows systems.                                                  |
| **CSV**    | Data values separated by commas; lightweight and simple.                                                 |
| **CEF**    | Common Event Format; structured using key-value pairs with pipe `\|` separators.                          |


#### Log Example Breakdown

**Example: Network Log**:

```text
ALLOW source=192.168.1.1 destination=google.com timestamp=2024-04-08T12:45:30Z
```

- `ALLOW`: Action taken
- `source`: Originating IP address
- `destination`: Target (e.g., domain or IP)
- `timestamp`: When the event occurred

---

## **Overview of Intrusion Detection Systems (IDS)**

### Telemetry vs. Logs

- **Telemetry**: Real-time data about system/network activity (e.g., packet captures).
- **Logs**: Record past events and actions on systems/devices.
- Both are critical for security investigations.

### Types of Intrusion Detection Systems (IDS)

| IDS Type | Description | Example |
|----------|-------------|---------|
| **HIDS (Host-Based IDS)** | Monitors internal activity on a single endpoint (like a laptop or server). Installed as an agent. | Detects unauthorized app installations. |
| **NIDS (Network-Based IDS)** | Analyzes network traffic at specific points in the network. Functions like a packet sniffer. | Detects malicious inbound/outbound traffic at the perimeter. |

- **Deployment**: Multiple NIDS sensors can be placed throughout a network for broader visibility.
- **Combination**: Using both HIDS and NIDS provides layered defense and a fuller view of system/network activity.

### Detection Techniques

| Technique | Description | Pros | Cons |
|----------|-------------|------|------|
| **Signature-Based Analysis** | Compares activity against known patterns or rules (signatures). | - Low false positives<br>- Efficient for known threats | - Cannot detect unknown/zero-day threats<br>- Requires frequent updates<br>- Can be evaded with slight attack variations |
| **Anomaly-Based Analysis** | Compares current behavior to a baseline of normal activity. | - Can detect new/unknown threats | - High false positives<br>- Baseline may be tainted by pre-existing compromise |


#### Signature Rules in NIDS (e.g., Suricata)

**Signatures** consist of 3 parts:

1. **Action**: What to do if a match is found (e.g., `alert`, `pass`, `reject`)
2. **Header**: Defines protocol, source/destination IPs and ports, and traffic direction
3. **Rule Options**: Fine-tunes detection (e.g., `msg`, `flow`, `content`, `sid`, `rev`)

Example:

```plaintext
alert http $HOME_NET any -> $EXTERNAL_NET any (msg:"GET on wire"; flow:established; content:"GET"; sid:1000001; rev:1;)
```

- **msg**: Alert message
- **flow**: Matches the state of traffic (e.g., `established`)
- **content**: Matches specific data in the packet (e.g., `"GET"` for HTTP GET request)
- **sid**/**rev**: Signature ID and revision number

**🧪 Pro Tip**: Signatures must be tested and tailored to your specific environment to reduce false positives and improve detection effectiveness.

## **Introduction to Suricata**

Suricata is an open-source intrusion detection system (IDS), intrusion prevention system (IPS), and network analysis tool. It's widely used in cybersecurity to monitor, analyze, and protect network environments.

### Suricata Features

Suricata can be deployed in several modes:

- **Intrusion Detection System (IDS)**: Monitors network traffic and generates alerts for suspicious or malicious activity.
- **Intrusion Prevention System (IPS)**: Not only detects but also blocks malicious traffic (requires additional configuration).
- **Network Security Monitoring (NSM)**: Produces and stores detailed network logs for forensic analysis, incident response, and testing.

### Suricata Logs and Output Formats

Suricata logs data in a format known as **EVE JSON**—short for *Extensible Event Format in JavaScript Object Notation*. This format uses **key-value pairs**, making it easier to search and extract data from log files during analysis.

Suricata generates two main types of logs:

#### 1. **Alert Logs**

- Contain information critical to security investigations.
- Generated when detection **signatures** (rules) match network activity.
- Include fields like `event_type: alert`, source/destination IPs, protocols, and rule details.
- Example: A signature triggers an alert for malware detection, logging metadata such as the rule ID and description.

#### 2. **Network Telemetry Logs**

- Provide visibility into general network activity—whether or not it's malicious.
- Example: An HTTP log showing a request to a specific website. Key fields include:
  - `event_type: http`
  - `hostname`: Website accessed
  - `user_agent`: e.g., Mozilla/5.0
  - `content_type`: Data returned (e.g., `text/html`)

These log types help analysts reconstruct incidents by building a detailed narrative of network activity.

#### Suricata Log Files

Suricata outputs logs into two primary files:

| Log File     | Purpose                                                  | Detail Level   |
|--------------|----------------------------------------------------------|----------------|
| **eve.json** | Main log file containing detailed JSON-formatted events  | Verbose        |
| **fast.log** | Minimal alert info (IP addresses, ports, etc.)           | Basic / Legacy |

- **eve.json** is ideal for detailed parsing, SIEM integration, and correlation of events using fields like `flow_id`.
- **fast.log** is lightweight and useful for basic alerting but lacks detail for incident response.


### Understanding Suricata Rules (Signatures)

Suricata uses **signatures** or **rules** to detect malicious patterns in network traffic. These rules consist of:

1. **Action**: What to do if traffic matches the rule (`alert`, `pass`, `drop`, `reject`).
2. **Header**: Network metadata like source/destination IPs, ports, protocols.
3. **Rule Options**: Custom criteria like content patterns, flow direction, or thresholds.

> 📌 Note: The order of rule options matters—they must be written in a specific sequence.

Example of a Suricata rule includes all three parts, enabling detection of specific threats.

#### Rule Processing Order

While rules appear in a certain order in configuration, Suricata internally processes them in this order:

1. `pass`
2. `drop`
3. `reject`
4. `alert`

This order influences how conflicting rules are handled.


#### Writing Custom Rules

Though Suricata includes pre-written rules, it's essential to **create or customize** rules to suit specific organizational environments. Custom rules allow:

- Tailoring detection to unique infrastructure
- Reducing false positives
- Enhancing visibility into actual threats

> ⚠️ There's no one-size-fits-all rule—organizations must test and tune rules based on their own network behavior.

---

### Configuration with `suricata.yaml`

Before Suricata can monitor anything, it must be correctly configured. Suricata uses a YAML-formatted config file:

- File name: `suricata.yaml`
- Allows customization of:
  - Logging behavior
  - Rule sets
  - Network interfaces to monitor
  - Performance tuning

### Additional Resources

- [Suricata User Guide](https://suricata.readthedocs.io/)
- [Suricata Features Overview](https://suricata.io/features/)
- [Rule Management and Writing](https://suricata.readthedocs.io/en/latest/rules/index.html)
- [Rule Performance Tuning](https://suricata.readthedocs.io/en/latest/performance/intro.html)
- [Suricata Threat Hunting Webinar](https://www.youtube.com/watch?v=kHOrzZjz9xw)
- [Writing Custom Suricata Rules](https://suricata.readthedocs.io/en/latest/rules/writing-rules.html)
- [EVE JSON + jq examples](https://redmine.openinfosecfoundation.org/projects/suricata/wiki/EveJSONOutput)

---

## **Overview of Security Information Event Management Tools**

SIEM (Security Information and Event Management) tools are crucial for security analysts to collect, normalize, analyze, and search security event data from multiple sources. They help with monitoring systems, triaging alerts, and investigating incidents.


### SIEM Data Collection Process

1. **Collect & Process**
   - Collects massive data from various systems and devices in different formats.
2. **Normalize**
   - Converts data into a standardized format to ensure consistency and readability.
3. **Index**
   - Makes normalized data searchable and accessible.


### Common SIEM Tools

| Tool      | Description |
|-----------|-------------|
| **Splunk** | A data analytics platform with SIEM capabilities. Uses SPL (Search Processing Language) to query data. Supports advanced visualizations and filters. |
| **Google Chronicle** | Google Cloud’s SIEM platform. Uses YARA-L language and UDM (Unified Data Model) for structured queries. Enables raw log search when needed. |


### Log Ingestion and Sources

- **Log Ingestion**: The process of collecting and importing data from log sources (e.g., servers, devices).
- SIEM stores a copy of log data for analysis.
- Examples of ingested data: login attempts, network activity, etc.

#### Log Forwarders

- Automate the collection and sending of log data.
- May be:
  - Native to an OS (e.g., Windows Event Forwarder).
  - Third-party tools.
  - Proprietary software from the SIEM vendor.
- Forwarders are configured to define what logs to send and to which destination.

### Searching in SIEM Tools

#### General Guidelines

- Use **specific queries** to narrow down results and improve performance.
- Use **filters, time ranges, and event IDs** to target relevant data.
- Different SIEMs have their own **query languages and search capabilities**.


#### Splunk Searches

| Concept | Example / Notes |
|--------|------------------|
| **Basic SPL Search** | `index=main fail` — searches for "fail" in the `main` index |
| **Pipe (`|`)** | `index=main fail | chart count by host` — pipes results into a chart grouped by host |
| **Wildcard** | `fail*` — matches any word starting with "fail" (e.g., failed, failure) |
| **Exact Phrase** | `"login failure"` — searches for the full phrase only |
| **Output & Filtering** | Highlighted keywords, timeline visualizations, host/device filters, and field exclusions (e.g., `host!=www1`) |


#### Chronicle (Google SecOps) Searches

| Search Type | Description |
|-------------|-------------|
| **UDM (Unified Data Model) Search** | Structured search through normalized data for speed and consistency. |
| **Raw Log Search** | Unstructured search through original log data. Useful for troubleshooting or finding unnormalized fields. |

##### UDM Search Example

```bash
metadata.event_type = "USER_LOGIN" AND security_result.action = "BLOCK"
```

- `metadata.event_type`: Specifies the event type (e.g., USER_LOGIN)
- `security_result.action`: Outcome of the event (e.g., BLOCK)

##### Chronicle Features

- **Structured Query Builder** for UDM queries
- **Graphical timeline** of event activity
- **Quick Filters** (e.g., filter by target IP, hostname, etc.)
- **Entity fields**: hostname, username, IP address
- **Raw log access** for deeper investigation

---

## **Key Takeaways**

- IDS helps detect and alert on unauthorized activity across endpoints and networks.
- HIDS is focused on host-level activity, while NIDS captures network-level activity.
- Signature-based IDS relies on known patterns, while anomaly-based IDS can detect deviations from normal but may be noisy.
- Suricata and similar IDS tools use rule-based signatures that you can customize for specific detection needs.

- Suricata is a flexible and powerful IDS/IPS/NSM tool.
- It outputs detailed logs in EVE JSON format for robust analysis.
- Understanding rule syntax and configuration is critical to leveraging Suricata effectively.
- Customizing rules and logging options improves detection accuracy and minimizes alert fatigue.

- SIEM tools centralize, normalize, and analyze security data from various sources.
- You’ll use SIEM tools for threat detection, investigation, and incident response.
- Knowing how data is ingested and queried is crucial for identifying and responding to security incidents.
- Proficiency in search syntax (SPL for Splunk, UDM/YARA-L for Chronicle) is essential for effective security operations.
