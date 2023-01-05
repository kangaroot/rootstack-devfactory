job "gitlab-runner" {
  datacenters = ["ewandc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "gitlab-runner" {
    count = 5 
    task "gitlab-runner" {
      driver = "docker"
      resources {
          cpu = 1000
          memory = 2000
        }
        config {
            image = "gitlab/gitlab-runner:v15.6.1"
            command = "run"
            args = ["--config", "/alloc/config.toml"]
            network_mode = "host"
            volumes = [
              "alloc/config:/etc/gitlab-runner",
              "/var/run/docker.sock:/var/run/docker.sock"
            ]
            logging {
                type = "loki"
              }
          }
      }
    task "gitlab-runner-register" {
      driver = "docker"
        config {
            image = "gitlab/gitlab-runner:v15.6.1"
            command = "register"
            args = [ 
              "--non-interactive",
              "--config",
              "/alloc/config.toml",
              "--executor",
              "docker",
              "--docker-image",
              "docker:20.10.16",
              "--docker-volumes", 
              "/var/run/docker.sock:/var/run/docker.sock",
              "--url",
              "https://gitlab.ewan.kangaroot.net",
              "--registration-token",
              "Q6TBHQ8XMPXXVV49A683JBQTNQ9REJ",
              "--description", 
              "docker-runner",
              "--tag-list",
              "docker",
              "--run-untagged=true",
              "--locked=false",
              "--access-level=not_protected"
            ]
            network_mode = "host"
            volumes = [
              "alloc/config:/etc/gitlab-runner",
            ]
          }
          lifecycle {
            hook = "prestart"
            sidecar = false
          }
      }
 }
}
  
