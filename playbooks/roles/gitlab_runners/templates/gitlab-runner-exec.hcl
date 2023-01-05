
job "gitlab-runner" {
  datacenters = ["ewandc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "gitlab-runner" {
    count = 1 
    task "gitlab-runner" {
      driver = "exec"
      config {
          command = "alloc/gitlab-runner/gitlab-runner"
          args = ["run"] 
      }
      artifact {
          source = "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64"
          destination = "alloc/gitlab-runner/gitlab-runner"
          mode = "file"
        }
    }
   # task "gitlab-runner-register" {
   #   lifecycle {
   #       hook = "poststart"
   #       sidecar = false
   #     }
   #   driver = "exec"
   #   config {
   #       command = "alloc/gitlab-runner/gitlab-runner"
   #       args = ["register", "--non-interactive", "--url https://gitlab.ewan.kangaroot.net", "--registration-token 'Q6TBHQ8XMPXXVV49A683JBQTNQ9REJ'", "--executor 'docker'", "--docker-image alpine:latest" ] 
   #     }
   #   }
  }
}
  
