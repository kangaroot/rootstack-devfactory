job "debug" {
  datacenters = ["ewandc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }

  group "gitlab-runner" {
    count = 1 
    task "test" {
      driver = "exec"
      config {
          command = ""
          #args = ["$user"] 
      }
    }
  }
}

  
