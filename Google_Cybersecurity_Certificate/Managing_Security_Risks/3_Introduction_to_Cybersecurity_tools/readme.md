# **Introduction to Cybersecurity Tools**

## **Module Overview**

In this module, you will explore industry-leading **Security Information and Event Management (SIEM)** tools that security professionals use to **protect business operations**. You’ll learn how **entry-level security analysts** interact with SIEM dashboards in their daily work.

## **Learning Objectives**

By the end of this module, you will be able to:

- **Identify and define** commonly used SIEM tools.
- **Describe** how SIEM tools protect business operations.
- **Explain** how entry-level security analysts utilize SIEM dashboards.

## **SIEM Dashboards Overview**

### Role of Security Analysts

Security analysts are responsible for analyzing log data to manage threats, risks, and vulnerabilities. Logs provide a record of events that happen within an organization's systems and networks. Common log sources include:

- **Firewall Logs**: Record of incoming and outgoing network connections.
- **Network Logs**: Track devices and connections entering or leaving the network.
- **Server Logs**: Record events related to services like websites and emails, including login attempts and user requests.

By monitoring these logs, security teams can identify vulnerabilities and potential data breaches. SIEM tools rely on logs to monitor systems and detect security threats.

### What are SIEM Tools?

A **Security Information and Event Management (SIEM)** tool collects and analyzes log data, providing real-time visibility, event monitoring, analysis, and automated alerts. SIEM tools centralize log data, reducing the need for manual review and increasing efficiency.

### Customization of SIEM Tools

SIEM tools must be customized to meet each organization's unique security needs. As new threats emerge, SIEM tools need constant adjustments to ensure threats are detected and addressed quickly.

### SIEM Dashboards

SIEM tools allow the creation of **dashboards** that help security analysts quickly access security-related data in an easily digestible format (charts, graphs, tables). Dashboards help monitor security posture and provide real-time information on potential threats.

### Example: Using a Dashboard for Suspicious Activity

A security analyst may receive an alert for a suspicious login attempt. By using a dashboard, they can quickly identify:

- 500 login attempts in 5 minutes
- Login attempts from unusual locations and times

This visual representation helps analysts determine if the activity is suspicious.

### Metrics in SIEM Dashboards

SIEM dashboards can also display **metrics** such as response time, availability, and failure rate. These metrics help assess the performance of security applications and can be customized based on the needs of different team members.

### Future of SIEM Tools

SIEM tools are evolving to accommodate new technologies, especially cloud-hosted and cloud-native environments. As cybersecurity threats increase, the need for tools that can handle vast amounts of data from interconnected devices (IoT) grows. Future advancements will include:

- **Cloud-hosted** SIEM tools: Managed by vendors, ideal for organizations without infrastructure maintenance needs.
- **Cloud-native** SIEM tools: Designed for scalability, flexibility, and availability in cloud environments.
- **Automation**: The future will see more automated responses to common security incidents through **Security Orchestration, Automation, and Response (SOAR)**. This will reduce the need for manual intervention, allowing analysts to focus on complex incidents.

## **SIEM Tools**

### Types of SIEM Tools

1. **Self-hosted SIEM Tools**: Managed internally by an organization, ideal for those who need control over confidential data.
2. **Cloud-hosted SIEM Tools**: Managed by the vendor, ideal for organizations without infrastructure maintenance needs.
3. **Hybrid SIEM Solutions**: Combines both self-hosted and cloud-hosted solutions to balance data control and cloud flexibility.

### Common SIEM Tools

#### Splunk

- Types:
  - **Splunk Enterprise**: A self-hosted tool for log data retention, analysis, and real-time alerts.
  - **Splunk Cloud**: A cloud-hosted tool for collecting, searching, and monitoring log data in cloud or hybrid environments.

- Dashboards:
  1. **Security Posture Dashboard**: Displays recent security events to help identify if policies are working correctly.
  2. **Executive Summary Dashboard**: Provides an overview of an organization's security health for stakeholders.
  3. **Incident Review Dashboard**: Displays timelines of events leading to security incidents for further analysis.
  4. **Risk Analysis Dashboard**: Helps identify risks by analyzing behavioral changes in users, computers, or IP addresses.

#### Google Chronicle

A cloud-native SIEM tool designed for log retention, analysis, and searching, leveraging cloud computing for scalability and flexibility.

- Dashboards:
  1. **Enterprise Insights Dashboard**: Highlights alerts and suspicious domain names (IOCs) with confidence scores.
  2. **Data Ingestion and Health Dashboard**: Ensures the log data is being processed correctly.
  3. **IOC Matches Dashboard**: Identifies trends related to top threats, helping prioritize security efforts.
  4. **Main Dashboard**: Provides a high-level summary of data ingestion, alerts, and event activities.
  5. **Rule Detections Dashboard**: Displays statistics on triggered alerts from specific detection rules.
  6. **User Sign-in Overview Dashboard**: Monitors user access behavior to identify unusual login patterns.

### Open-source vs. Proprietary Tools

- **Open-source Tools**:
  - Free, collaborative, and customizable.
  - Examples: **Linux** (operating system), **Suricata** (network analysis and threat detection).
  - Open-source tools often become more secure due to community collaboration.

- **Proprietary Tools**:
  - Paid, developed and owned by specific companies.
  - Examples: **Splunk**, **Chronicle**.
  - Typically, these tools offer limited customization but provide vendor-specific support and updates.

## **Key Takeaways**

- SIEM tools are essential for monitoring and managing an organization's security.
- Cloud functionality, integration with other applications, and automation are key future trends in SIEM development.
- As a security analyst, understanding SIEM dashboards and staying updated on advancements will be crucial to your role.
