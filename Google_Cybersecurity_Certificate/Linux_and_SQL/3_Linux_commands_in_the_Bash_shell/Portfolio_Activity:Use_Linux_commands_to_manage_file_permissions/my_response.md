
# **File Permissions in Linux**

## **Check File and Directory Details**

Use the content of the Current file permissions document to determine the current permissions. To check these permissions, type the following command directly into the template:

```bash
ls -la /home/researcher2/projects
```

The output will display the permissions in a 10-character string format for each file and directory, as follwing:

```bash
-rw-rw-rw- 1 researcher2 users 1024 Apr  1 12:34 project_k.txt
-rw-r----- 1 researcher2 users 1024 Apr  1 12:35 project_m.txt
-rw-rw-r-- 1 researcher2 users 1024 Apr  1 12:36 project_r.txt
-rw-rw-r-- 1 researcher2 users 1024 Apr  1 12:37 project_t.txt
-rw--w---- 1 researcher2 users 1024 Apr  1 12:38 .project_x.txt
drwx--x--- 2 researcher2 users 4096 Apr  1 12:39 drafts
```

## **Describe the Permissions String**

Choose one example from the output above, such as the permission string for `project_m.txt`: `-rw-r-----`.

- The first character `-` indicates that it is a regular file. (As opposed to the value d tp indicate a directory)
- The next three characters `rw-` indicate that the **user** has read and write permissions.
- The following three characters `r--` show that the **group** has read-only permission.
- The last three characters `---` mean that **others**  have no permissions.


## **Change File Permissions**

The file that needs an update to the its permissions is `project_k.txt`. The following command will help modify this file's permissions:

```bash
chmod o-w /home/researcher2/projects/project_k.txt
```

This command removes write access for "others" from the specified file.


## **Change File Permissions on a Hidden File**

The research team has archived `.project_x.txt`, which is a hidden file. This file should not have write permissions for anyone except the user and group should have read access. To assign the appropriate authorization, type:

```bash
chmod 110 /home/researcher2/projects/.project_x.txt
```

This command sets the permissions so that:

- **User** = read
- **Group** = read
- **Other** = none


## **Change Directory Permissions**

Only the owner, `researcher2`, should have full access to the `drafts` directory and its contents. To modify the permissions accordingly, type:

```bash
chmod 700 /home/researcher2/projects/drafts
```

This command changes the directory permissions so that:

- **User** = read, write, execute
- **Group** = none
- **Other** = none

## **Project Description**

As a response analyst, our task was to assess and manage file and directory permissions within the `/home/researcher2/projects` directory to ensure proper access control. By utilizing Linux commands, I verified current permissions, interpreted permission strings, and implemented necessary changes to secure sensitive files. 

## **Summary**

In this response analysis, I reviewed the file and directory permissions within the `/home/researcher2/projects` directory to identify potential security risks. After analyzing the permissions, I applied the appropriate Linux commands to modify access permissions, ensuring compliance with security policies. These actions helped protect organizational data by limiting unauthorized access and reducing the risk of potential security breaches.


