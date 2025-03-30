# **Analyzing DNS and ICMP Traffic**

## **Overview**

In this activity, you will analyze DNS and ICMP traffic using data from a network protocol analyzer tool. You will determine which network protocol was affected during a cybersecurity incident by reviewing captured data packets and identifying trends in the network traffic.

By understanding how to identify potentially malicious traffic, you will develop skills to assess security risks and reinforce network security.

## **Scenario**

You are a cybersecurity analyst working at a company that provides IT services. Several customers have reported that they are unable to access the client’s website, **<www.yummyrecipesforme.com>**, and are seeing the error message **"destination port unreachable"** when attempting to load the page.

![tcpdump image](./tcpdump_image.png)

To investigate the issue, you attempt to access the website yourself and encounter the same error. Using **tcpdump**, a network analyzer tool, you capture and analyze network traffic while trying to visit the website.

Your analysis reveals that when UDP packets are sent to the DNS server, you receive ICMP packets with the error message **"udp port 53 unreachable"**. This suggests that the DNS service is unavailable, preventing users from resolving the website’s domain name.

Now, you must analyze the captured packet data and determine the impact of this incident on network services.

## **Instructions**

### Step 1: Access the Template

- Copy the **[Cybersecurity Incident Report Template](./Cybersecurity-incident-report-network-traffic-analysis.docx)**.
- Use the prompts in the template to guide your analysis and report.

### Step 2: Access Supporting Materials

- Review the **[Example of a Cybersecurity Incident Report](./Cybersecurity-Incident-Report.docx)** to understand how to document your findings effectively.

### Step 3: Provide a Summary of the Problem Found in the tcpdump Log

- Analyze the **tcpdump** log and identify patterns in the data.
- Determine which protocols were involved in the network traffic.
- Summarize key findings, such as:
  - The repeated appearance of **port 53**, indicating an issue with DNS.
  - The ICMP error messages stating **"udp port 53 unreachable"**, which suggests DNS is not responding.
- Record your findings in **Part One** of the **Cybersecurity Incident Report**.

### Step 4: Explain Your Analysis and Provide One Solution

- Explain why the ICMP error messages appeared in the **tcpdump** log.
- Detail the events leading up to the incident, including:
  - The time the issue was first reported.
  - The symptoms observed when the incident occurred.
  - The current status of the issue.
- Describe the steps taken to investigate the issue and list potential causes.
- Provide the suspected root cause of the problem and recommend a possible solution.
- Record your responses in **Part Two** of the **Cybersecurity Incident Report**.

## **What to Include in Your Response**

- A summary of the problem found in the **tcpdump** log.
- A detailed analysis of the data, including the protocols involved.
- An explanation of the cause of the incident and a proposed solution.

## **Key takeaways**

As a security analyst, you may not always know exactly what is at the root of a network issue or a possible attack. But being able to analyze the IP packets involved will help you make a best guess about what happened or potentially prevent an attack from invading the network. The network protocol and traffic logs will become the starting point for investigating the issue further and addressing the attack.
