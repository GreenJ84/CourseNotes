# **Splunk Cloud Data Analysis Activity**

In this activity, you'll be introduced to the Splunk platform. You'll use Splunk Cloud to upload data, perform basic searches, and answer questions about security events. This optional activity won't affect your course completion.

You'll apply your knowledge of SIEM tools and Splunk's Search Processing Language (SPL) to identify potential security issues in mail server logs. Effective searching helps security analysts quickly find critical information during incident response.

## **Scenario**

You are a security analyst at Buttercup Games, an e-commerce store. Your task is to investigate possible mail server security issues by examining failed SSH logins for the root account.

**Note:** Use your incident handler's journal from previous activities to document findings.

## **Instructions**

### Step 1: Access supporting materials

- Download the **[tutorialdata.zip](./tutorialdata.zip)** file containing Buttercup Games' mail server and web account logs

### Step 2: Create a Splunk account

- Follow Part 1-2 of the Splunk sign-up guide to:
  - Create a Splunk Cloud account
  - Verify your email

### Step 3: Sign up for free Splunk Cloud trial

- Follow Part 3 of the Splunk sign-up guide to activate your trial
- Refer to the Splunk cloud tutorial video if you encounter issues

### Step 4: Upload data to Splunk

- Ensure tutorialdata.zip is downloaded (do not uncompress)
- Log into Splunk Cloud and navigate to Splunk Home
- Click Settings > Add Data > Upload
- Select tutorialdata.zip and configure:
  - Host: Segment in path (segment number: 1)
- Review and submit with default settings:
  - Input Type: Uploaded File
  - Source Type: Automatic
  - Index: Default

### Step 5: Perform a basic search

- Navigate to Splunk Home > Search & Reporting
- Enter query: `index="main"`
- Set time range to "All Time"
- Execute search (should return thousands of events)

### Step 6: Evaluate the fields

- Examine these fields in search results:
  - **host**: Network host origin (5 hosts including mailsv and www1-3)
  - **source**: Original filename (8 sources including /mailsv/secure.log)
  - **sourcetype**: Data format (3 types including secure-2)

### Step 7: Narrow your search

- Under SELECTED FIELDS, click host > mailsv
- Observe updated query: `index=main host=mailsv` (~9000 events)

### Step 8: Search for failed root logins

- Clear search bar
- Enter: `index=main host=mailsv fail* root`
- Wildcard (*) expands to failure/failed etc.
- Execute search (~300 events)

### Step 9: Evaluate the results

- Review all result pages
- Note Splunk's term highlighting
- Observe patterns in failed login attempts

### Step 10: Answer questions about the search results

1. How many events are contained in the main index across all time?
    - 10-99
    - 10,000
    - 100-1,000
    - Over 100,000

2. Which field identifies the name of a network device or system from which an event originates?
    - source
    - sourcetype
    - host
    - index

3. Which of the following hosts used by Buttercup Games contains log information relevant to financial transactions?
    - www2
    - vendor_sales
    - www3
    - www1

4. How many failed SSH logins are there for the root account on the mail server?
    - None
    - One
    - More than 100
    - 100

## **What to Include in your response**

- Answers to all four questions
- Notes from your incident handler's journal
- Observations about search patterns and results
