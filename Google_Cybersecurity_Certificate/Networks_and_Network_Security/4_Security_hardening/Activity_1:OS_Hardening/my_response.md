# **Cybersecurity Incident Report**

## **Template responses**

### Section 1: Identify the Network Protocol Involved in the Incident

The network protocols involved in the incident are **DNS** and **HTTP**.

- **DNS (Domain Name System)** is used for translating domain names (like *yummyrecipesforme.com* and *greatrecipesforme.com*) into IP addresses. This is observed in the DNS queries (requests for IP addresses) and responses captured in the log (e.g., requests for `yummyrecipesforme.com` and `greatrecipesforme.com`).
- **HTTP (HyperText Transfer Protocol)** is used for web communication. It is seen in the HTTP GET requests from the browser to the websites, and the responses to those requests, indicating communication between the client machine and the web servers (both `yummyrecipesforme.com` and `greatrecipesforme.com`).

### Section 2: Document the Incident

The incident started when a user attempted to access the website *yummyrecipesforme.com*. The first step involved a DNS request from the user's machine (IP `your.machine.52444`) to resolve the domain `yummyrecipesforme.com`, which returned the IP address `203.0.113.22` from the DNS server (`dns.google.domain`). The browser then initiated an HTTP connection on port 80 and made a GET request for the website's homepage. Subsequently, a suspicious behavior occurred as the website prompted the user to download an executable file.

After the user downloaded the file, the browser was redirected to another website, *greatrecipesforme.com*, identified by another DNS request that resolved the domain to IP `192.0.2.17`. The user was redirected to this fake website, which contained malware. HTTP traffic between the user's machine and `greatrecipesforme.com` mirrored the initial HTTP request, indicating successful execution of the redirect and loading of a potentially malicious page.

This incident appears to be the result of a website compromise, likely involving a previous brute-force attack, which allowed an attacker to inject JavaScript code into the website. The code then forced users to download a malicious file that redirected them to a fake website hosting malware.

### Section 3: Recommend

To prevent similar incidents in the future, it is recommended to implement **multi-factor authentication (MFA)** for accessing the website's admin panel. This would significantly reduce the risk of brute-force attacks by requiring an additional layer of authentication beyond just a password. Additionally, ensuring that all default passwords are changed and enforcing strong password policies (e.g., length, complexity) can further mitigate the risk of unauthorized access to sensitive administrative functions.

## **Report**

In this cybersecurity incident, the network protocols involved are **DNS** and **HTTP**. DNS was used to resolve the domain names of the websites, translating *yummyrecipesforme.com* and *greatrecipesforme.com* into their respective IP addresses. HTTP was used for communication between the user's machine and the websites, with GET requests and responses observed during the process of accessing the site and the subsequent redirect.

The incident began when a user accessed *yummyrecipesforme.com*. A DNS request was made to resolve the website's IP, and after receiving the response, an HTTP connection was established. However, once the user visited the website, they were prompted to download an executable file. After downloading and running the file, the browser was redirected to *greatrecipesforme.com*, which contained malware. This was the result of a compromise of the website, likely through a brute-force attack on the admin panel, allowing the attacker to inject malicious JavaScript code that redirected users to the fake site.

To prevent future incidents, it is recommended to implement **multi-factor authentication (MFA)** for the admin panel of the website. This would add an additional layer of security beyond just the password, making it more difficult for attackers to gain unauthorized access, especially in cases like this where brute-force attacks were successful.
