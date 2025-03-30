# **Cybersecurity Incident Report: SYN Flood Attack**

## **Template responses**

### Section 1

#### One potential explanation for the website's connection timeout error message is

- One potential explanation is a **SYN flood attack**, a type of **Denial of Service (DoS) attack** that exploits the TCP handshake process.

#### The logs show that

- The logs show that an **abnormally high number of TCP SYN requests** were sent from a single IP address (203.0.113.0), overwhelming the web server’s resources. Initially, the server responded to requests normally, but as the volume of SYN requests increased, legitimate users began experiencing failed connections, indicated by **HTTP 504 Gateway Timeout errors** and **RST, ACK packets** in the log.

#### This event could be

- This event could be classified as a **direct SYN flood attack**, originating from a single attacker rather than multiple distributed sources (DDoS). The attack simulated connection attempts without completing the TCP handshake, consuming server resources and rendering it unable to respond to legitimate users.

### Section 2

#### When website visitors try to establish a connection with the web server, a three-way handshake occurs using the TCP protocol. Explain the three steps of the handshake

1. **SYN (Synchronize):** The client sends a **SYN packet** to the server, requesting a connection.

2. **SYN-ACK (Synchronize-Acknowledge):** The server responds with a **SYN-ACK packet** to acknowledge the request.

3. **ACK (Acknowledge):** The client sends a **final ACK packet**, establishing the connection.

#### Explain what happens when a malicious actor sends a large number of SYN packets all at once

- This causes the server to open maany connections in memory, eventually exhausting its available resources.

#### Explain what the logs indicate and how that affects the server

- The logs indicate that initially, the web server was handling requests properly, but as the attack escalated, legitimate traffic (from IP 198.51.100.14) began experiencing failed connection attempts. This resulted in **504 Gateway Timeout errors** and **RST, ACK packets**, signaling that the server could not process further connections. Eventually, the server stopped responding altogether, with the logs showing only attack-related traffic.
- This confirms that the **SYN flood attack overwhelmed the web server, preventing legitimate users from accessing the website**.


## **Report**

The website's connection timeout error was caused by a **SYN flood attack**, a type of **Denial of Service (DoS) attack** that exploits the TCP handshake. Logs reveal an **abnormally high number of TCP SYN requests** from a single IP address (203.0.113.0), initially allowing normal traffic but later overwhelming the server. As the attack escalated, legitimate users experienced **504 Gateway Timeout errors** and **RST, ACK packets**, indicating failed connections. The attack consumed the server’s resources by leaving numerous half-open connections, preventing it from responding to legitimate traffic.

A normal TCP handshake involves three steps: **SYN**, **SYN-ACK**, and **ACK**, establishing a connection between the client and server. In this attack, the attacker sent **SYN packets** but never completed the handshake, forcing the server to allocate resources indefinitely. The logs show that as the attack progressed, the server struggled to keep up, leading to **denied connections for legitimate users**. Eventually, the server stopped responding entirely, confirming that it was overwhelmed by the **SYN flood attack**.
