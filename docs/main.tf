provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "jenkins_custom" {
  name = "mi-jenkins-python:latest"
}

resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = docker_image.jenkins_custom.latest
  ports {
    internal = 8080
    external = 8080
  }
}

resource "docker_image" "dind" {
  name = "docker:dind"
}

resource "docker_container" "docker_dind" {
  name  = "dockerd"
  image = docker_image.dind.latest
  privileged = true
  ports {
    internal = 2375
    external = 2375
  }
}
