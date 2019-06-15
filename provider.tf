#Below configurations are optional as "terraform init" will read the config files and understand what modules to download

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"

  version = "~> 1.7"
}