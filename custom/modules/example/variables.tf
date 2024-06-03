variable "module_name" {
  type        = string
  default     = "example"
  description = "The Module name"
}

variable "module_folder" {
  type        = string
  default     = "custom/modules/example"
  description = "Module is located in this folder"
}

variable "module_written_for_cloud" {
  type        = string
  default     = "custom"
  description = "Module is written for the particular Cloud"
}
