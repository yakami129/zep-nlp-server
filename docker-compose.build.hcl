variable "TAG" {
  default = "latest"
}

variable "DISTRO" {
  default = "okapi0129"
}

group "default" {
  targets = ["postgres","zep","zep-nlp-server"]
}

target "zep-nlp-server" {
  args = {
    TAG = null
  }
  dockerfile = "Dockerfile"
  tags = ["${DISTRO}/getzep/zep-nlp-server:${TAG}"]
}

target "zep-nlp-server-release" {
  inherits = ["zep-nlp-server"]
  platforms = ["linux/amd64", "linux/arm64"]
}