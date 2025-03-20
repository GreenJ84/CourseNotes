# **Linux Commands in the Bash Shell**

## **Overview**

This module introduces **Linux commands** as entered through the **Bash shell**. You'll learn to:

- **Navigate and manage** the file system.
- **Authenticate and authorize** users.
- **Modify file permissions** to control access.
- **Use `sudo`** for root privileges.
- **Find resources** for learning Linux commands.

The **command line** provides powerful capabilities for interacting with the OS efficiently. Mastering **Bash commands** is essential for security analysts, enabling them to manage systems, control user access, and perform administrative tasks effectively.

## **Learning Objectives**

By the end of this module, you will be able to:

1. **Navigate** the file system using Linux commands.
2. **Manage** files and directories via the Bash shell.
3. **Understand and modify** Linux file permissions.
4. **Authenticate and authorize** users.
5. **Use `sudo`** to execute commands with root privileges.
6. **Access resources** for learning new Linux commands.

Through hands-on practice, you'll develop essential skills for working with **Linux as a security analyst**.


## **Navigate the Linux File System**

Security analysts use the command line to manage the file system and its conetns remotely without a graphical interface.

### Filesystem Hierarchy Standard (FHS)

- **Root Directory (`/`):**
  The top-level directory from which all other directories branch.
- **Standard Directories:**
  - `/home`: Contains user-specific directories.
  - `/bin`: Stores executable files.
  - `/etc`: Houses system configuration files.
  - `/tmp`: Holds temporary files (often modified by all users).
  - `/mnt`: Used for mounting external media.
- **User-Specific Subdirectories:**
  Often represented with a tilde (`~`), e.g., `~/logs` for `/home/username/logs`.

### File Paths

- **Absolute Path:**
  Full path starting from the root (e.g., `/home/analyst/projects`).
- **Relative Path:**
  Path relative to the current directory, using:
  - `.` for the current directory
  - `..` for the parent directory

### Command Fundamentals

- **Commands & Arguments:**
  - A command tells the OS to perform an action.
  - Arguments provide additional information for a command (e.g., `echo "You are doing great!"`).
  - Linux commands and filenames are case-sensitive.

### Key Navigation Commands

- **`pwd`:**
  Displays the current working directory (e.g., `/home/analyst`).
- **`ls`:**
  Lists files and directories in the current (or specified) directory.
- **`cd`:**
  Changes the current directory.
  - Use `cd subdirectory` for relative paths.
  - Use `cd /path/to/directory` for absolute paths.
  - Use `cd ..` to move up one level.

### Reading File Content

- **`cat`:**
  Displays the entire content of a file.
- **`head`:**
  Shows the first 10 lines of a file by default.
  - Use `head -n 5 filename` to display a specific number of lines.
- **`tail`:**
  Shows the last 10 lines of a file, useful for viewing recent log entries.
- **`less`:**
  Opens a file for paginated viewing with navigation controls:
  - **Space:** Next page
  - **b:** Previous page
  - **Arrow keys:** Line-by-line navigation
  - **q:** Quit

## **Manage file content in Bash**

### Find and Filter Content

- **Filtering:**
  Essential for security analysts to quickly locate specific information within files.
- **Use Cases:**
  E.g., finding files with malware-related strings or filtering logs for errors.

#### grep Command

- **Purpose:**
  Searches through files and returns all lines containing a specified string.
- **Usage Example:**
  - `grep OS updates.txt`
    Searches for the string "OS" in the file `updates.txt`.
  - `grep error time_logs.txt`
    Searches for the word "error" in `time_logs.txt`.
- **Key Point:**
  - Takes two arguments: the search string and the file name.

#### Piping

- **Concept:**
  Redirects the output of one command as input to another using the pipe character (`|`).
- **Usage Example:**
  - `ls /home/analyst/reports | grep users`
    Lists contents of the `reports` directory and filters for entries containing "users".
- **Note:**
  - A versatile tool for combining commands, not limited to filtering.

#### find Command

- **Purpose:**
  Searches for files and directories that meet specific criteria.
- **Criteria Examples:**
  - **By Name:**
    - `find /home/analyst/projects -name "*log*"`
      Finds files with "log" in their name (case-sensitive).
    - `find /home/analyst/projects -iname "*log*"`
      Finds files with "log" in their name (case-insensitive).
  - **By Modification Time:**
    - `find /home/analyst/projects -mtime -3`
      Finds files modified within the last 3 days.
    - Use `-mmin` for specifying minutes instead of days.
- **Usage Note:**
  - The first argument is the starting directory, followed by options (starting with `-`) to set search criteria.

### Create and Manage Directories and Files

- Organizing files and directories is key to maintaining a structured system.
- Efficient management of directories and files simplifies tracking and securing data.

#### Directory Management

##### Creating Directories with `mkdir`

- **Command:** `mkdir`
- **Usage:**
  - Absolute path: `mkdir /home/analyst/logs/network`
  - Relative path: `mkdir network` (when already in the target directory)
- **Tip:** Use `ls` to confirm the new directory was created.

##### Removing Directories with `rmdir`

- **Command:** `rmdir`
- **Usage:**
  - Remove an empty directory: `rmdir oldreports`
- **Note:**
  - `rmdir` only works on empty directories.

#### File Management

##### Creating Files with `touch`

- **Command:** `touch`
- **Usage:**
  - Create an empty file: `touch permissions.txt`

##### Removing Files with `rm`

- **Command:** `rm`
- **Usage:**
  - Delete a file: `rm permissions.txt`
- **Warning:**
  - Deleted files are hard to recover.

##### Moving and Copying Files

- **Moving with `mv`:**
  - Move a file: `mv email_policy.txt /home/analyst/drafts`
  - Rename a file: `mv permissions.txt perm.txt`
- **Copying with `cp`:**
  - Copy a file while retaining the original: `cp vulnerabilities.txt /home/analyst/projects`

#### Editing Files with nano

- **nano Editor:**
  - Open a file for editing: `nano OS_patches.txt`
  - Save changes with `Ctrl+O` and exit with `Ctrl+X`
- **Note:**
  - nano is user-friendly for beginners. Alternatives include Vim and Emacs.

#### Standard Output Redirection

- **Using `echo` with Redirection Operators:**
  - **Overwrite a File:**
    - `echo "time" > permissions.txt`
      (Replaces file content)
  - **Append to a File:**
    - `echo "last updated date" >> permissions.txt`
      (Adds to the end of the file)
- **Tip:**
  - If the file does not exist, these operators will create it.



## **Authenticate and Authorize users**

### File Permissions and Ownership

- **Purpose:**
  Learn how Linux controls access to files and directories through permissions and ownership.
- **Core Concept:**
  Authorization is about granting minimal, need-to-know access to protect sensitive data.

#### Permission Types

- **Read (r):**
  - Files: View file content.
  - Directories: List contained files.
- **Write (w):**
  - Files: Modify file content.
  - Directories: Create or delete files.
- **Execute (x):**
  - Files: Run executable programs.
  - Directories: Enter and access directory contents.

#### Owner Categories

- **User (u):**
  The file's owner.
- **Group (g):**
  A set of users sharing common access rights.
- **Other (o):**
  All remaining users on the system.

#### Permission Representation

- **Format:**
  A 10-character string (e.g., `drwxrwxrwx`) where:
  - **1st character:** File type (`d` for directory, `-` for file).
  - **Characters 2-4:** Permissions for the user.
  - **Characters 5-7:** Permissions for the group.
  - **Characters 8-10:** Permissions for others.

#### Checking Permissions

- **Commands:**
  - `ls -l`: Lists files with detailed permission information.
  - `ls -a`: Displays hidden files.
  - `ls -la`: Combines both options to show all files and their permissions.

#### Changing Permissions with chmod

- **Command:** `chmod` (change mode)
- **Symbolic Mode Syntax:**
  `chmod [owner][+|-|=][permissions] <file>`
  - **Operators:**
    - `+` adds permission.
    - `-` removes permission.
    - `=` sets exact permissions.
- **Example:**
  `chmod g+w,o-r access.txt`
  (Adds write permission for the group and removes read permission for others.)

#### Principle of Least Privilege in Action

- **Concept:**
  Only grant the minimal permissions required.
- **Example:**
  For a confidential file (e.g., `bonuses.txt`), adjusting permissions to remove unnecessary group or other access minimizes security risks.

### User Management

- **Authentication:** Verifying a user's identity.
- **Authorization:** Granting users access only to the resources they need.
- **Key Point:** Only authorized users should have system access. When users join or leave, their accounts must be added or removed accordingly.

#### Adding and Deleting Users

- **Adding Users:**
  - Use `sudo useradd <username>` to add new users (e.g., `sudo useradd salesrep7`).
  - New users might be added due to organizational changes or new hires.
- **Deleting Users:**
  - Use `sudo userdel <username>` to remove users who no longer need access.
  - The `-r` option with `userdel` deletes the user's home directory as well (e.g., `sudo userdel -r salesrep7`).

#### Elevated Privileges: Root and sudo

- **Root User:**
  - Has unrestricted access and can modify any part of the system.
  - Logging in as root is risky due to security vulnerabilities and lack of accountability.
- **sudo Command:**
  - **Purpose:** Temporarily grants elevated privileges without logging in as root.
  - **Usage:** Prepend commands with `sudo` (e.g., `sudo useradd fgarcia`).
  - **Security:** Only users listed in the `sudoers` file can use sudo, reducing risk.

#### Advanced User Management Tools

- **usermod:**
  - Modifies existing user accounts.
  - Options:
    - `-g`: Change the primary group (e.g., `sudo usermod -g executive fgarcia`).
    - `-G`: Set supplemental groups.
    - `-a -G`: Append new groups without removing existing ones (e.g., `sudo usermod -a -G marketing fgarcia`).
    - Other options: `-d` (change home directory), `-l` (change login name), `-L` (lock the account).
- **chown:**
  - Changes file or directory ownership.
  - **Usage Examples:**
    - Change file owner: `sudo chown fgarcia access.txt`
    - Change group ownership: `sudo chown :security access.txt`

#### Best Practices

- **Use sudo Over Root:**
  Avoid logging in as root to minimize security risks and ensure accountability.
- **Principle of Least Privilege:**
  Grant only the necessary permissions to users.
- **Caution with Deletion:**
  Always verify before deleting a user account or files, and consider deactivating (using `usermod -L`) instead of deleting if file ownership retention is needed.

## **Get Help in Linux**

- Linux's open-source nature has fostered a large, supportive global community.
- Numerous online resources and forums offer solutions, tips, and tutorials.

### Online Resources

- **General Online Search:**
  - Quickly find answers and troubleshooting tips for various Linux tasks.
- **Unix & Linux Stack Exchange:**
  - A reputable Q&A site where community-voted answers help resolve complex issues.

### Integrated In-Shell Help Commands

- **man (Manual Pages):**
  - Displays detailed documentation about commands and their options.
  - *Example:* `man chown`
- **whatis:**
  - Provides a concise, one-line description of a command.
  - *Example:* `whatis nano`
- **apropos:**
  - Searches manual page descriptions for a specific keyword.
  - Use `-a` with multiple keywords to narrow down results.
  - *Example:* `apropos -a change password`


## **Key Takeaways**

- **Security:**
  - Properly setting and checking permissions is critical to safeguarding sensitive information.
  - Quickly identifying relevant data is critical for analyzing potential threats.
  - **Tools:**
    Use `ls` to inspect permissions and `chmod` to enforce the principle of least privilege.

- **Understanding FHS:**
  Familiarity with the Linux Filesystem Hierarchy Standard aids in locating and managing files and directories efficiently.
  - **Structure:**
    Directories (created with `mkdir`/removed with `rmdir`) and files (managed with `touch`, `rm`, `mv`, and `cp`) form the backbone of a well-organized system.
  - **Efficient Navigation:**
    Mastery of commands like `pwd`, `ls`, and `cd` is crucial for navigating the Linux file system.
  - **Efficiency in Filtering:**
    Commands like `grep`, piping, and `find` enable targeted searches in large file sets.
  - **File Inspection:**
    Use `cat`, `head`, `tail`, and `less` commands to effectively read and analyze file contents.

- **Editing:**
  - Use command-line editors like nano to modify file contents.
- **Redirection:**
  - Output redirection (`>` and `>>`) is useful for writing or updating file contents.
- **Community Support:**
- Utilize online communities and forums for learning and troubleshooting.
- **Command-Line Help:**
  - Leverage built-in commands like `man`, `whatis`, and `apropos` for quick, accessible documentation.


