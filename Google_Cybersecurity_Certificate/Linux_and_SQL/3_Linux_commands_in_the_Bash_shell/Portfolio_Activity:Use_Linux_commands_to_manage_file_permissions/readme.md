# **Linux File Permissions Management**

## **Overview**

In this activity, you will refresh your skills in managing file permissions in Linux by reviewing a scenario, identifying misconfigured permissions, and modifying them to ensure proper access control for authorized users.

## **Scenario**

You are a security professional responsible for managing file permissions within an organization. Your task is to ensure that users on the research team have the correct permissions to files and directories, and modify any permissions that don’t match the authorization guidelines.

## **Instructions**

### Step 1: Access the Template

- Open the provided **[File permissions in Linux](./File_permissions_in_Linux.docx)** template to document the activity steps.

### Step 2: Access Supporting Materials

- The **[Instructions for including Linux commands](./Instructions_for_including_Linux_commands.docx)** document provides instructions and best practices for including samples of Linux commands in your portfolio activity.

- The **[Current file permissions](./Current_file_permissions.docx)** document demonstrates how the file structure is built for this portfolio activity. The file permissions for each file or directory are also provided.



### Step 3: Check File and Directory Details

- Use the content of Current file permissions document to determine the current permissions.
- Describe the command you can use to check permissions in the **Check file and directory** details section of the File permissions in Linux template. Type the Linux command you used directly into the template.
- Then, use the output of this command in the Current file permissions document to indicate the current permissions. Write these in the 10-character string that would be part of the command's output.

### Step 4: Describe the Permission String

- Choose one example from the output in the previous step. In the Describe the permissions string section of the File permissions in Linux template, write a short description that explains the 10-character string in the example. You should describe what the 10-character string is for and what each character represents.


### Step 5: Change File Permissions

- The organization does not allow others to have write access to any files. Based on the permissions established in Step 3, identify which file needs to have its permissions modified. Use a Linux command to modify these permissions.
- Describe the command you used and its output in the Change file permissions section of the File permissions in Linux template. Type this command directly into the template.


### Step 6: Change File Permissions on Hidden File

- The research team has archived .project_x.txt, which is why it’s a hidden file. This file should not have write permissions for anyone, but the user and group should be able to read the file. Use a Linux command to assign .project_x.txt the appropriate authorization.
- Describe the command you used and its output in the Change file permissions on a hidden file section of the File permissions in Linux template. Type this command directly into the template.

### Step 7: Change Directory Permissions

- The files and directories in the projects directory belong to the researcher2 user. Only researcher2 should be allowed to access the drafts directory and its contents. Use a Linux command to modify the permissions accordingly.
- Describe the command you used and its output in the Change directory permissions section of the File permissions in Linux template. Type this command directly into the template.

### Step 8: Finalize the Document

- To finalize the document and make its purpose clear to potential employers, be sure to complete the Project description and Summary sections of the File permissions in Linux template.
  - In the Project description section, give a general overview of the scenario and what you accomplish through Linux. Write two to four sentences.
  - In the Summary section, provide a short summary of the previous tasks and connect them to the scenario. Write approximately two to four sentences.

### Step 9: Assess Your Activity

- Complete the self-assessment by answering yes or no to each statement to review your work:
  - Include screenshots or typed versions of your commands. (1pt)y/n
  - Describe the project at the beginning of the document. (1pt)y/n
  - Provide explanations for your commands and their outputs. (1pt)y/n
  - Include a summary at the end of the document. (1pt)y/n
  - Include details on using `chmod` to update file permissions. (1pt)y/n
  - Include details on checking file permissions with `ls -la`. (1pt)y/n
  - Interpret the 10-character string that represents file permissions. (1pt)y/n
  - Address hidden files and directories. (1pt)y/n

## **What to Include in Your Response**

- Screenshots of your commands or typed versions of the commands
- Explanations of your commands
- A project description at the beginning
- A summary at the end
- Details on using chmod to update file permissions
- Details on checking file permissions with ls -la
- Details on interpreting the 10-character string that represents file permissions
- Details on hidden files and directories
