# **Analyzing Artifacts with VirusTotal and the Pyramid of Pain**

In this activity, you'll analyze an artifact using VirusTotal and capture details about its related indicators of compromise (IoCs) using the Pyramid of Pain. VirusTotal is a crowdsourced threat intelligence tool that helps security analysts identify malicious files, domains, URLs, and IP addresses. The Pyramid of Pain describes the relationship between IoCs and the difficulty malicious actors face when these IoCs are blocked.

**Important Note**: Data uploaded to VirusTotal is publicly shared. Avoid submitting personal information.

## **Scenario**

You are a Level 1 SOC analyst at a financial services company. An alert indicates an employee downloaded a suspicious password-protected spreadsheet from an email. Upon opening, the file executed a malicious payload. You’ve retrieved the file and generated its SHA256 hash. Now, you’ll use VirusTotal to uncover associated IoCs.

**Key Details**:

- **SHA256 Hash**: `54e6ea47eb04634d3e87fd7787e2136ccfbcc80ade34f246a12cf93bab527f6b`
- **Timeline**:
  - 1:11 PM: Email received with attachment.
  - 1:13 PM: File downloaded and opened.
  - 1:15 PM: Unauthorized executables created.
  - 1:20 PM: Alert triggered by intrusion detection.

## **Instructions**

### Step 1: Access the Template

- Use the [Pyramid of Pain template](./Pyramid-of-Pain.pptx).

### Step 2: Review Alert Details

- Note the SHA256 hash and event timeline provided above.

### Step 3: Search VirusTotal

- Go to [VirusTotal](https://www.virustotal.com/).
- Enter the SHA256 hash in the search box and press *Enter*.

### Step 4: Analyze the Report

Explore these tabs in the VirusTotal report:

- **Detection**: Vendor verdicts (malicious/suspicious).
- **Details**: Additional hashes (MD5, SHA-1).
- **Relations**: URLs, domains, and IPs contacted by the malware.
- **Behavior**: Sandbox reports showing file actions (e.g., registry changes, processes).

**Pro Tip**: Filter sandbox reports to identify consistent malicious behaviors.

### Step 5: Determine Maliciousness

Review these sections to assess the file:

1. **Vendors’ Ratio**: High malicious flags increase suspicion.
2. **Community Score**: Negative score suggests maliciousness.
3. **Detection Tab**: Vendor-specific malware names/details.

- In your template, state whether the file is malicious and justify your conclusion.

### Step 6: Identify IoCs for the Pyramid of Pain

Find **three** IoCs from the report and add them to the template. Choose from:

- **Hash Values**: Locate in *Details* tab (e.g., MD5/SHA-1).
- **IP Addresses/Domains**: Check *Relations* tab (prioritize flagged ones).
- **Network/Host Artifacts**: Found in *Behavior* or *Relations* (e.g., created files).
- **Tools/TTPs**: See *Behavior* tab for MITRE ATT&CK® techniques.

**Note**: Legitimate domains/IPs may appear—focus on those marked malicious.

## **What to Include in Your Response**

- A statement on the file’s maliciousness (with reasoning).
- Three IoCs (e.g., hash, IP, TTP) placed in the Pyramid of Pain template.
