# Code Style

## Variables

Variables always start with prepending the role name:
```
role: access --> access_admin_group, access_admin_users,...
```
We always use lowercase and with underscores. 

Role variables should always have defaults unless undefined is checked for legacy reasons (but then should be explained).
Variables are documented in the vars file and in the role README.md.

### Tags

Tags are lowercase and should be documented in the tags.md file in the root of docs/.
Tags can be used across roles and should never be prepended with rolenames nor specific to roles only.
