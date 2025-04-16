# **Threats to Asset Security**

In this module, you'll explore common types of threats to digital asset security. You'll learn about tools and techniques cybercriminals use to target assets and be introduced to the threat modeling process, helping security professionals stay ahead of security breaches.

## **Learning Objectives**

- Identify forms of social engineering.
- Identify different types of malware.
- Identify forms of web-based exploits.
- Summarize the threat modeling process.

## **Social Engineering**


Social engineering is a manipulation technique that exploits human error to gain private information, access, or valuables. Attackers use psychological manipulation to bypass security procedures, leading to data exposures, malware infections, or unauthorized access. These attacks can happen online, in-person, and through various interactions.

Phishing and other social engineering tactics have evolved over time, becoming more sophisticated. While there's no perfect solution, spreading awareness and educating others is a critical defense against these attacks. Security professionals should focus on prevention, detection, and response strategies to minimize the impact of social engineering threats.

### Stages of Social Engineering Attacks

1. **Preparation**: Attackers gather information about their target.
2. **Establishing Trust (Pretexting)**: Attackers use gathered data to create false trust.
3. **Persuasion**: Attackers manipulate the target into sharing sensitive information.
4. **Disconnect**: Attackers cover their tracks and end communication.

### Defense Strategies

- **Managerial Controls**: Policies, standards, and procedures (e.g., NIST 800-40).
- **Security Awareness**: Educate employees and customers on recognizing social engineering tactics.
- **Technological Controls**: Implement firewalls, MFA, email filtering, and intrusion prevention systems.

### Key Social Engineering Tactics

- **Baiting**: Tricking victims into compromising security, e.g., infected USB drives.
- **Phishing**: Using digital communication to steal sensitive data, often through email.
- **Quid Pro Quo**: Offering rewards in exchange for access or information.
- **Tailgating**: Unauthorized individuals following authorized personnel into restricted areas.
- **Watering Hole**: Attacking websites frequented by a specific group to deploy malware.

#### Signs of an Attack

- Look for suspicious communications, especially emails with spelling errors or unfamiliar addresses.
- Be cautious about sharing personal information, especially on social media.


#### Types of Phishing

1. **Email Phishing**: Pretending to be a trusted source to steal sensitive data.
2. **Smishing**: Using text messages to trick victims into revealing private information.
3. **Vishing**: Using voice communication (calls or messages) to deceive targets.
4. **Spear Phishing**: Targeting specific individuals or groups with customized attacks.
5. **Whaling**: A form of spear phishing aimed at high-ranking executives.

##### Recent Trends in Phishing

- **Angler Phishing**: Attackers impersonate customer service representatives on social media to exploit customer complaints.


## **Malware**

Malware, short for malicious software, is designed to harm devices or networks. It can be spread in various ways, often targeting devices connected to the internet. When infected, malware disrupts normal operations and allows attackers to control systems without permission.

### Common Types of Malware

- **Virus**
  - Malicious code that damages data and software.
  - Typically requires user activation (e.g., opening an infected file).
  - Often spread through phishing emails.
- **Worm**
  - Malware that can spread automatically across systems.
  - Unlike viruses, worms don't need user action to propagate.
  - Can exploit network vulnerabilities to infect other devices.
- **Trojan**
  - Malware disguised as a legitimate file or program.
  - Often used to install other malicious software like ransomware.
- **Ransomware**
  - Encrypts data and demands payment for decryption.
  - Common in recent attacks, and often involves a demand for cryptocurrency.
- **Spyware**
  - Malware used to secretly collect sensitive information.
  - Can steal login credentials, PINs, and personal data.
- **Adware**: Displays unwanted ads, sometimes bundled with legitimate software.
- **Scareware**: Uses fear tactics to trick users into infecting their devices.
- **Fileless Malware**: Runs in memory without leaving traces on the hard drive.
- **Rootkits**: Provides remote administrative access to systems.
- **Botnets**: Networks of infected devices controlled by a bot-herder.

### Emerging Malware Threat: Cryptojacking

Cryptojacking malware hijacks a device's resources to mine cryptocurrencies without the user's knowledge. It can cause system slowdowns, crashes, and high electricity costs. Detection systems like IDS help identify cryptojacking infections.

## **Web-Based Exploits**

Web-based exploits target coding flaws in web applications. Attackers use malicious code to gain unauthorized access to sensitive information, often through injection attacks, such as Cross-Site Scripting (XSS) and SQL injection.

### Injection Attacks

Injection attacks involve inserting malicious code into a vulnerable application, which runs in the background without the user knowing. These vulnerabilities arise from improper handling of user inputs.

#### Cross-Site Scripting (XSS)

XSS is an attack where malicious scripts are inserted into a web page, exploiting HTML and JavaScript to steal sensitive information like session cookies and geolocation.

##### Types of XSS

1. **Reflected XSS**: Malicious script is sent to the server, which returns the script to the user’s browser.
2. **Stored XSS**: The malicious script is stored on the server and activated when the user visits the site.
3. **DOM-based XSS**: Malicious code is embedded directly in the page’s source code (HTML), activated by the browser.

#### SQL Injection

SQL injection occurs when malicious input is used to exploit vulnerable database queries. Attackers can manipulate, steal, or delete data by injecting harmful SQL code into input fields.

##### SQL Injection Categories

1. **In-band SQL Injection**: Uses the same channel to launch the attack and retrieve results (e.g., search boxes).
2. **Out-of-band SQL Injection**: Uses a separate channel to send and receive attack data.
3. **Inferential SQL Injection**: No direct feedback from the system; attackers infer results based on system responses.

##### Prevention Techniques for SQL Injection

- **Prepared Statements**: Executes SQL statements before passing them to the database.
- **Input Sanitization**: Removes harmful user input.
- **Input Validation**: Ensures input meets system requirements to prevent attacks.

## **Threat Modeling**

Threat modeling is a critical process for identifying assets, vulnerabilities, and how each is exposed to threats. It involves assessing systems, applications, or business processes from a security perspective to anticipate potential attacks.

### Key Concepts

- **Threat Actors**: Internal or external individuals or groups who pose security risks to assets.
- **Attack Tree**: A diagram that maps threats to assets, helping identify attack vectors.
- **PASTA Framework**: A seven-stage threat modeling framework used to simulate and analyze threats.

### Threat Modeling Process Steps

1. **Define Scope**: Create an inventory of assets and classify them.
2. **Identify Threats**: Define potential threat actors (internal and external).
3. **Characterize the Environment**: Apply an attacker mindset and consider how users and partners interact with the environment.
4. **Analyze Threats**: Review existing protections, identify gaps, and rank threats.
5. **Mitigate Risks**: Decide how to defend against threats (avoid, transfer, reduce, or accept risks).
6. **Evaluate Findings**: Document findings, apply fixes, and record lessons learned.

### Effective Threat Models

Threat modeling is a strategic approach combining vulnerability management, threat analysis, and incident response to proactively reduce risks. It’s essential in securing applications, identifying threats, and defending against cyberattacks.

### Common Threat Modeling Frameworks

- **STRIDE**: Developed by Microsoft to identify vulnerabilities in six attack vectors (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, and Elevation of Privilege).
- **PASTA**: A risk-centric framework focusing on evidence-based threat analysis and simulation.
- **Trike**: An open-source tool focused on security permissions and privilege models.
- **VAST**: An automated framework for agile and visual threat modeling.

#### PASTA Framework

1. **Define business and security objectives** - understand how PII information is handled.
2. **Define the technical scope** - Identify the application components that must be evaluated.
3. **Deompose the application** - Identify the existing controls that will protect user data from threats.
4. **Perform a threat analysis** - Get into the attacker mindset. research is done to collect the most up-to-date information on the type of attacks being used.
5. **Perform a vulnerability analysis** - deeply investigate potential vulnerabilities by considering the root of the problem.
6. **Conduct attack modeling** - Test the vulnerabilities that were analyzed in stage five by simulating attacks. (creating an attack tree)
7. **Analyze risk and impack** - assemble all the information collected make informed risk management recommendations to business stakeholders that align with their goals.

##### Example**

A fitness company performs threat modeling using PASTA before launching mobile app. The seven stages of the PASTA process help the team assess risk, analyze vulnerabilities, and test attacks to ensure customer data protection

## **Key Takeaways**

- Social engineering exploits human nature, relying on curiosity, generosity, and excitement.
- Attacks like phishing are easy to carry out and can bypass technological defenses.
- Awareness and multi-layered defenses (both technological and human) are essential to prevent these attacks.
- Malware is a complex and evolving threat.
  - Understanding its different types and how they spread is critical for a security professional.
  - Regular updates, training, and security tools are necessary to defend against these threats.
- Injection attacks, especially SQL injections and XSS, are common threats targeting web applications.
  - Collaboration with developers is crucial to mitigate these risks by using preventive techniques like input validation, sanitization, and prepared statements.
- Threat modeling is crucial for securing applications and systems.
- The process involves a deep understanding of the environment and potential threats.
- Even inexperienced security analysts can contribute by asking the right questions and applying an attacker mindset.
