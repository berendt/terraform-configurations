variable "region" {
    default = "RegionOne"
}

variable "image" {
    default = "Ubuntu 14.04"
}

variable "flavor" {
    default = "m1.large"
}

variable "user_name" {
    default = "terraform"
}

variable "tenant_name" {
    default = "terraform"
}

variable "password" {
    default = "password"
}

variable "auth_url" {
    default = "http://10.100.0.1:5000/v2.0"
}

variable "ssh_key_file" {
    default = "~/.ssh/id_rsa.terraform"
}

variable "ssh_user_name" {
    default = "ubuntu"
}

variable "external_gateway" {
    default = "c1901f39-f76e-498a-9547-c29ba45f64df"
}

variable "pool" {
    default = "public"
}
