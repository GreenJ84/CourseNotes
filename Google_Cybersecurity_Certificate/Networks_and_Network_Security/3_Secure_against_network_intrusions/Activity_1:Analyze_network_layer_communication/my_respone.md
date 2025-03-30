# **Cybersecurity Incident Report: Network Traffic Analysis**

## **Template responses**

### **Part 1**

### The UDP protocol reveals that

The network traffic analysis shows that UDP packets were sent from the client’s computer to the DNS server to resolve the domain name **<www.yummyrecipesforme.com>**. However, the response received was an ICMP error message indicating that the requested port was unreachable.

### This is based on the results of the network analysis, which show that the ICMP echo reply returned the error message

"udp port 53 unreachable"

### The port noted in the error message is used for

Port **53**, which is the standard port for **Domain Name System (DNS)** queries. This port is responsible for resolving domain names to IP addresses.

### The most likely issue is

The DNS server is either down, misconfigured, or not listening on **port 53**, preventing users from resolving domain names to IP addresses. This results in website access failures.

---

### **Part 2**

### Time incident occurred

The tcpdump log indicates that the issue was recorded at **1:24 PM, 32.192571 seconds** when the first DNS request was made and an ICMP error was returned.

### Explain how the IT team became aware of the incident

Customers reported that they were unable to access the website **<www.yummyrecipesforme.com>** and received a **"destination port unreachable"** error message. Upon attempting to visit the website, IT staff encountered the same issue, prompting further investigation.

### Explain the actions taken by the IT department to investigate the incident

1. IT staff attempted to access the website to replicate the issue.
2. A **network protocol analyzer tool (tcpdump)** was used to capture network traffic while attempting to resolve the domain.
3. The **tcpdump log** was reviewed to analyze the DNS request and response behavior.
4. The log revealed that DNS queries were sent via UDP to the DNS server, but **ICMP packets** were received in response, indicating that **port 53 was unreachable**.

### Note key findings of the IT department’s investigation (i.e., details related to the port affected, DNS server, etc.)

- **Port affected:** **Port 53 (DNS)**
- **Error message received:** **"udp port 53 unreachable"**
- **Source IP address:** **192.51.100.15 (client's computer)**
- **Destination IP address:** **203.0.113.2 (DNS server)**
- **Protocol involved:** **UDP for DNS queries, ICMP for error response**
- **Issue confirmed:** **The DNS server is not responding to requests, causing resolution failures.**

### Note a likely cause of the incident

The DNS server at **203.0.113.2** is either **offline, misconfigured, or not listening on port 53**, preventing DNS queries from resolving domain names to IP addresses. This could be due to a misconfigured firewall, server outage, or a DNS service failure.

## **Report**


The network traffic analysis reveals that UDP packets were sent from the client’s computer to the DNS server at **203.0.113.2** to resolve **<www.yummyrecipesforme.com>**, but the response received was an ICMP error message: **"udp port 53 unreachable."** Port **53** is the standard port for DNS queries, responsible for resolving domain names to IP addresses. The tcpdump log confirms that multiple DNS requests were made, all resulting in the same error. This suggests that the DNS server is either **offline, misconfigured, or not listening on port 53**, leading to resolution failures and preventing users from accessing the website.

The IT team became aware of the issue after multiple customers reported website access failures. Upon investigation using **tcpdump**, the team identified the ICMP error messages indicating that DNS queries were not reaching an active service. The likely cause of the incident is a **DNS server outage, firewall misconfiguration, or service failure**, preventing it from responding to requests. Further troubleshooting should focus on verifying the server status, checking firewall rules, and ensuring that the DNS service is running properly.
