# Mattermost

This role deploys a Mattermost instance on the Nomad Cluster.
Mattermost is the communication tool for Devfactory.
It can be tightly integrated into Gitlab via integrations and SSO.

The role will by default use the [Team edition](https://hub.docker.com/r/mattermost/mattermost-team-edition/) of Mattermost.
It designed to allow for failover of the Mattermost and/or the database by using an external CSI volume.

## Architecture

The job spec is templated in a Jinja2 template. 
The Mattermost application task and database task are within one task group. This will mean they will be scheduled to the same allocation (and therefore node). 
This has multiple benefits when deploying Mattermost with just a single instance:  
- It allows for restrictive access to Postgres by utilising the Bridge network namespace created by Nomad. The database is bound to localhost in this namespace and Mattermost can access it directly via localhost.
- The two tasks can use the same CSI volume but with different mount points. This simplifies deployment requirements. 

This role can also configure Mattermost to use Gitlab for authentication. This reduces the administration requirements of using Devfactory.

## Configuration

Most of the role's configuration is stored in the [role's defaults](./defaults/main.yml).
The majority of these variables can be left set to their default values.

## Required variables

Store these variables in `group_vars` so there accessible to all hosts in the playbook.

**Enable Role**


As this role is non-essential to the deployment of the Nomad cluster, it is necessary to explicitly enable the deployment of the Mattermost instance:

```yaml
mattermost_enabled: true
```

**CSI Volume**

Create a list in the `nomad_csi_volumes` mapping. This should be contained in the [Nomad Group Vars](../../../azure-inv/group_vars/nomad/all.yml).


For example:
```yaml
nomad_csi_volumes:
  - name: mattermost 
    id: mattermost
    minsize: 10737418240 
    maxsize: 32212254720
    namespace: default
    type: csi 
    filesystem: ext4
    accessmode: single-node-writer
    attachmentmode: file-system
    read_only: "false"
```

Then assign that specific list in the mapping to a variable to be used by the Mattermost role:
```yaml
nomad_mattermost_volume: "{{ nomad_csi_volumes[1] }}"
```

In this example the Mattermost is the second list in the mapping but that will differ depending on your specific configuration. 


**Gitlab SSO**

This role can configure Mattermost to use Gitlab for authentication. When enabled, the playbook will provision an OAuth application in Gitlab and configure Mattermost to use it.
There are some required variables in order for this to work.

Create a list in the `nomad_gitlab_oauth_applications` mapping in `inventory/group_vars/all/gitlab.yml`.

For example:
```yaml
nomad_gitlab_oauth_applications:
  - name: mattermost
    redirect_uris: "https://mattermost.{{ zone }}/login/gitlab/complete%0Ahttps://mattermost.{{ zone }}/signup/gitlab/complete"
    scopes: "read_user"
```

In `inventory/group_vars/all/mattermost.yml`, set `nomad_mattermost_gitab_sso` to `true`

```yaml
nomad_mattermost_gitab_sso: true
```

**Postgres**

Generate a long password (something like `pwgen -s 64 1`) and add it to `inventory/group_vars/all/mattermost.yml`.
Store this password securely. Using Ansible vault for example. 
You can also use something [direnv](https://direnv.net/) to assign it to an environment variable and then reference in the playbook like this:  

```yaml
nomad_mattermost_db_password: "{{ lookup('env', 'MATTERMOST_DATABASE_PASSWORD') }}"
```




