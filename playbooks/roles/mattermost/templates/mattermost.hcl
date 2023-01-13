job "{{ nomad_mattermost_job_name }}" {
  datacenters = ["{{ nomad_datacenter }}"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "mattermost" {
    count = "{{ nomad_mattermost_group_count }}"
    volume "{{ nomad_mattermost_volume.name }}"{
      type = "{{ nomad_mattermost_volume.type }}"
      access_mode     = "{{ nomad_mattermost_volume.accessmode }}"
      attachment_mode = "{{ nomad_mattermost_volume.attachmentmode }}"     
      read_only = {{ nomad_mattermost_volume.read_only }}
      source = "{{ nomad_mattermost_volume.id }}"
    }
    network {
      mode = "bridge"
      port "{{ nomad_mattermost_network[0].name }}" {
        to = {{ nomad_mattermost_network[0].port }}
        host_network = "{{ nomad_mattermost_network[0].hostnetwork }}"
      }
    }

    service {
      name = "{{ nomad_mattermost_services[0].name }}"
      port = "{{ nomad_mattermost_services[0].port }}"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.mattermost.tls=true",
        "traefik.http.routers.mattermost.entrypoints=https",
        "traefik.http.routers.mattermost.tls.certResolver={{ consul_dc_name }}",
        "traefik.http.routers.mattermost.tls.domains[0].main=mattermost.{{ zone }}",
      ]
     # check {
     #   type = "http"
     #   path = "/-/health"
     #   method = "GET"
     #   interval = "10s"
     #   timeout = "2s"
     #   }
      }

    task "mattermost" {
      driver = "docker"
      resources {
        cpu    = {{ nomad_mattermost_job_resources.cpu }} 
        memory = {{ nomad_mattermost_job_resources.memory }}  
      }
      config {
        image          = "{{ nomad_mattermost_docker_image }}"
        ports          = ["{{ nomad_mattermost_network[0].name }}"]
        volumes = [
          "{{ nomad_mattermost_volume_container_mount_point }}/data:/var/opt/mattermost",
          "{{ nomad_mattermost_volume_container_mount_point }}/config:/etc/mattermost",
          "local/sshd_config:/assets/sshd_config"
        ]
        {% if 'aarch64' != ansible_architecture %}
        logging {
          type = "loki"
        }
        {% endif %}
      }

      volume_mount {
          volume = "{{ nomad_mattermost_volume.id }}"
          destination = "{{ nomad_mattermost_volume_container_mount_point }}"
          read_only = false
      }
    }
  }
}


