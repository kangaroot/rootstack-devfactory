# Gitlab

This role deploys a working Gitlab instance on the Nomad cluster. 
Gitlab is intended to be the central tool used in Devfactory as all other tools deployed on top of the Nomad cluster are tied into Gitlab.
The role is configured to use the [Gitlab Omnibus](https://docs.gitlab.com/omnibus/) Docker image. This image packages into the image the different components necessary to run a single instance of Gitlab including an internal PostgreSQL instance.

The installed Gitlab instance is designed to support a moderate level of failover by using an Azure disk as a CSI volume that will be persisted across restarts, node-failures etc.

## Architecture

This role uses a jinja2 template of a Nomad Job spec to deploy Gitlab to the nomad cluster.

It is configured to allow traefik to read the registered consul services for:

- http (`gitlab`)
- SSH (`gitlab-ssh`)

SSH is setup by setting the `nomad_gitlab_ssh_port` variable(defaults to `2222`). An Azure load balancer rule is assigned to this port on the public ip of the load balancer. Traefik then listens on this port and forwards the tcp connection to the endpoint of the `gitlab-ssh` service that is registered in consul.  

## Configuration

The configuration of the role is done through the variables set in the [role's defaults](./defaults/main.yml). Most of don't need to overridden however there are some that need to be set

### Required Variables

These variables should be stored in `group_vars` to allow other roles to access them when needed.  

**Enable Role**

As this role is non-essential to the deployment of the Nomad cluster, it is necessary to explicitly enable the deployment of the Gitlab instance:

```yaml
gitlab_enabled: true
```

**Auth Setup**

For each variable, generate a password and store it securely using something like Ansible Vault.

```yaml
nomad_gitlab_initial_root_password:
nomad_gitlab_shared_runner_token:
```

**CSI Volumes**

It is necessary to add another list to the mapping `nomad_csi_volumes`.
For example:
```yaml
nomad_csi_volumes:
  - name: gitlab 
    id: gitlab
    minsize: 10737418240 
    maxsize: 32212254720
    namespace: default
    type: csi 
    filesystem: ext4
    accessmode: single-node-writer
    attachmentmode: file-system
    read_only: "false"
```

This variable is designed to allow any number of CSI volumes to be provisioned and registered to be used by the different services on the Nomad cluster.
As such, it is necessary to assign the list containing the volume configuration to the variable used by the Gitlab role: 

```yaml
nomad_gitlab_volume: "{{ nomad_csi_volumes[0] }}"
```

## Usage

Following configuring the role as outlined above, run the `deploy.yml` playbook.
This will set up the necessary CSI Volumes and post the Gitlab job spec to Nomad.

Starting up the service for the first can sometimes take a while. 
Once ready, a login page should appear at https://gitlab.{{ zone }}. Login is root and the initial root password you configured.

