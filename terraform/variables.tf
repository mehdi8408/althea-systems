variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prd"
}