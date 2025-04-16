variable "project_id" {
  description = "The project ID to host the uptime check in (required)."
  type        = string
}

variable "enabled" {
  description = "Whether or not the policy is enabled (defaults to true)"
  type        = bool
  default     = true
}

variable "alert_policy_combiner" {
  description = "Determines how to combine multiple conditions. One of: AND, OR, or AND_WITH_MATCHING_RESOURCE."
  type        = string
  default     = "OR"
}

variable "condition_display_name" {
  description = "A unique name to identify condition in dashboards, notifications, and incidents. If left empty, defaults to Failure of uptime check_id"
  type        = string
  default     = ""
}

variable "condition_threshold_value" {
  description = "A value against which to compare the time series."
  type        = number
  default     = 1
}

variable "condition_threshold_duration" {
  description = "The amount of time that a time series must violate the threshold to be considered failing, in seconds. Must be a multiple of 60 seconds."
  type        = string
  default     = "60s"
}

variable "condition_threshold_comparison" {
  description = "The comparison to apply between the time series (indicated by filter and aggregation) and the threshold (indicated by threshold_value)."
  type        = string
  default     = "COMPARISON_GT"
}

variable "notification_rate_limit_period" {
  description = "Not more than one notification per specified period (in seconds), for example \"30s\"."
  type        = string
  default     = null
}

variable "aggregations" {
  description = "Specifies the alignment of data points in individual time series as well as how to combine the retrieved time series together."
  type = object({
    alignment_period     = optional(string)
    per_series_aligner   = optional(string)
    group_by_fields      = optional(list(string))
    cross_series_reducer = optional(string)
  })
  default = {}
}

variable "condition_threshold_trigger" {
  description = "Defines the percent and number of time series that must fail the predicate for the condition to be triggered"
  type = object({
    percent = optional(number)
    count   = optional(number)
  })
  default = {
    percent = null
    count   = null
  }
}

variable "notification_channel_strategy" {
  description = "Control over how the notification channels in notification_channels are notified when this alert fires, on a per-channel basis."
  type = object({
    notification_channel_names = list(string)
    renotify_interval          = number
  })
  default = null
}

variable "alert_policy_user_labels" {
  description = "This field is intended to be used for organizing and identifying the AlertPolicy objects."
  type        = map(string)
  default     = {}
}

variable "filter" {
  description = "Logs-based filter"
  default = null
}

variable "notification_channels" {
  description = "List of all the notification channels to create for alerting if the uptime check fails. See https://cloud.google.com/monitoring/api/ref_v3/rest/v3/projects.notificationChannelDescriptors/list for a list of types and labels."
  type = list(object({
    display_name = string
    type         = string
    labels       = map(string)
  }))
  default = []
}

variable "auto_close" {
  description = "Open incidents will close if an alert policy that was active has no data for this long (in seconds, must be at least 30 minutes). For example \"18000s\"."
  type        = string
  default     = null
}

variable "existing_notification_channels" {
  description = "List of existing notification channel IDs to use for alerting if the uptime check fails."
  type        = list(string)
  default     = []
}

variable "alert_policy_display_name" {
  description = "Display name for the alert policy"
  type        = string
  default     = ""
}

variable "monitored_resource" {
  description = "Monitored resource type and labels. One of: uptime_url, gce_instance, gae_app, aws_ec2_instance, aws_elb_load_balancer, k8s_service, servicedirectory_service. See https://cloud.google.com/monitoring/api/resources for a list of labels."
  type = object({
    monitored_resource_type = string
    labels                  = map(string)
  })
  default = null
}

variable "condition_threshold_filter" {
  description = "A filter that identifies which time series should be compared with the threshold. Defaults to uptime check failure filter if left as empty string."
  type        = string
  default     = ""
}


variable "documentation" {
  description = "Documentation that is included with notifications and incidents related to this policy."
  type = object({
    content     = optional(string)
    mime_type    = optional(string)
    subject       = optional(string)
    # links  =    optional(object({
    #   display_name  = optional(string)
    #   url = optional(string)
    # }))
  })
  default = null
}

variable "alert_conditions" {
  description = "List of alert conditions."
  type = list(object({
    display_name = string
    type         = string # "log" or "metric"
    filter       = string
    # For metric conditions:
    comparison      = optional(string)
    threshold_value = optional(number)
    duration        = optional(string)
    aggregations = optional(list(object({
      alignment_period   = string
      per_series_aligner = string
      cross_series_reducer = string
    })))
  }))
  default = [
    # {
    #   display_name = "Log Alert: Dialogflow No Calls"
    #   type         = "log"
    #   filter       = "logName=\"projects/your-project-id/logs/your-log-name\""
    # },
    # {
    #   display_name    = "Metric Alert: High CPU Usage"
    #   type            = "metric"
    #   filter          = "resource.type = \"gce_instance\" AND metric.type = \"compute.googleapis.com/instance/cpu/utilization\""
    #   comparison      = "COMPARISON_GT"
    #   threshold_value = 0.8
    #   duration        = "300s"
    #   aggregations = [{
    #     alignment_period   = "60s"
    #     per_series_aligner = "ALIGN_RATE"
    #     cross_series_reducer = "REDUCE_MEAN"
    #   }]
    # },
  ]
}


variable "alert_policy_severity" {
  description = "Severity of the alert policy (CRITICAL, ERROR, WARNING)."
  type        = string
  default     = "null" # Optional
  validation {
    condition = var.alert_policy_severity == null || contains(["CRITICAL", "ERROR", "WARNING"], var.alert_policy_severity)
    error_message = "Invalid severity value. Must be CRITICAL, ERROR, WARNING"
  }
}

variable "alert_condition_absent" {
  description = "Specifies the filter and duration"
  type = string
  default = ""
}

variable "condition_absent_aggregations" {
  description = "Specifies the alignment of data points in individual time series as well as how to combine the retrieved time series together for the condition_absent block."
  type = object({
  alignment_period = optional(string)
  per_series_aligner = optional(string)
  cross_series_reducer = optional(string)
})
  default = {}
}

variable "condition_absent_trigger" {
  description = "Defines the percent and number of time series that must fail the predicate for the condition to be triggered for the condition_absent block"
  type = object({
  percent = optional(number)
  count = optional(number)
})
  default = {
  percent = null
  count = null
}
}

variable "condition_absent_duration" {
  description = "The amount of time that a time series must fail to report new data to be considered failing for the condition_absent block."
  type = string
  default = "60s"
}

variable "condition_absent_filter" {
  description = "A filter that identifies which time series should be compared with the threshold for the condition_absent block."
  type = string
  default = ""
}

variable "condition_mql_query" {
  description = "Monitoring Query Language query that outputs a boolean stream for the condition_monitoring_query_language block."
  type = string
  default = ""
}

variable "condition_mql_duration" {
  description = "The amount of time that a time series must violate the threshold to be considered failing for the condition_monitoring_query_language block."
  type = string
  default = "60s"
}

variable "condition_mql_trigger" {
  description = "Defines the percent and number of time series that must fail the predicate for the condition to be triggered for the condition_monitoring_query_language block."
  type = object({
  percent = optional(number)
  count = optional(number)
})
  default = {
  percent = null
  count = null
}
}

variable "condition_mql_evaluation_missing_data" {
  description = "A condition control that determines how metric-threshold conditions are evaluated when data stops arriving for the condition_monitoring_query_language block."
  type = string
  default = "EVALUATION_MISSING_DATA_NO_OP"
}

variable "condition_sql_query" {
  description = "The Log Analytics SQL query to run for the condition_sql block."
  type = string
  default = ""
}

variable "condition_sql_minutes" {
  description = "Used to schedule the query to run every so many minutes for the condition_sql block."
  type = object({
  periodicity = string
})
  default = {
  periodicity = "5m"
}
}

variable "condition_sql_hourly" {
  description = "Used to schedule the query to run every so many hours for the condition_sql block."
  type = object({
  periodicity = string
  minute_offset = optional(string)
})
  default = {
  periodicity = "1h"
  minute_offset = null
}
}

variable "condition_sql_daily" {
  description = "Used to schedule the query to run every so many days for the condition_sql block."
  type = object({
  periodicity = string
  execution_time = optional(object({
  hours = optional(number)
  minutes = optional(number)
  seconds = optional(number)
  nanos = optional(number)
}))
})
  default = {
  periodicity = "1d"
  execution_time = null
}
}

variable "condition_sql_row_count_test" {
  description = "A test that checks if the number of rows in the result set violates some threshold for the condition_sql block."
  type = object({
  comparison = string
  threshold = number
})
  default = {
  comparison = "COMPARISON_GT"
  threshold = 0
}
}

variable "condition_sql_boolean_test" {
  description = "A test that uses an alerting result in a boolean column produced by the SQL query for the condition_sql block."
  type = object({
  column = string
})
  default = {
  column = ""
}
}
 
