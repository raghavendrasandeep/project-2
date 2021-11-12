variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_session_token" {}


variable "region" {
    type = string
    description = "aws region where VM will be provisioned"
    default = "us-east-2"
}

variable "ami"{
    type = string
    description = "aws ami used to provision the VM"
    default = "ami-0233c2d874b811deb"
}


data "http" "my_public_ip" {
    url = "https://ifconfig.co/json"
    request_headers = {
        Accept = "application/json"
    }
}

locals {
    my_ip = jsondecode(data.http.my_public_ip.body)
}