variable "number" {
  default     = 3
  description = "Count of servers"
}

variable "environment" {
  default     = "prod"
  description = "Name of the environment"
}

variable "name" {
  default     = "follower"
  description = "Name of the servers"
}

variable "region" {
  description = "Where to deploy the resources"
}

