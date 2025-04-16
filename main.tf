locals {
  enable_alert_strategy = var.auto_close != null || var.notification_rate_limit_period != null || var.notification_channel_strategy != null ? true : false
  threshold_filter      = var.condition_threshold_filter
}

resource "google_monitoring_alert_policy" "tlz_alert_policy" {
  project      = var.project_id
  display_name = var.alert_policy_display_name
  enabled      = var.enabled
  combiner     = var.alert_policy_combiner
  severity    = var.alert_policy_severity # Add severity here

dynamic "documentation" {
  for_each = var.documentation != null ? [var.documentation] : []
  content {
    content   = documentation.value.content
    mime_type = documentation.value.mime_type
    subject   = documentation.value.subject
    }
  }
  dynamic "conditions" {
    for_each = var.alert_conditions
    content {
      display_name = conditions.value.display_name

      dynamic "condition_matched_log" {
        for_each = conditions.value.type == "log" ? [1] : []
        content {
          filter = conditions.value.filter
        }
      }

      dynamic "condition_absent" {
        for_each = var.alert_condition_absent
        content {
          filter   = conditions.value.filter
          duration = conditions.value.duration

          dynamic "aggregations" {
            for_each = lookup(conditions.value, "aggregations", [])
            content {
              alignment_period     = aggregations.value.alignment_period
              cross_series_reducer = aggregations.value.cross_series_reducer
              per_series_aligner   = aggregations.value.per_series_aligner
              group_by_fields      = aggregations.value.group_by_fields
            }
          }

          trigger {
            count   = var.condition_absent_trigger.count
            percent = var.condition_absent_trigger.percent
          }
        }
      }

      dynamic "condition_monitoring_query_language" {
        for_each = conditions.value.type == "mql" ? [1] : []
        content {
          query                  = conditions.value.query
          duration               = conditions.value.duration
          evaluation_missing_data = conditions.value.evaluation_missing_data

          trigger {
            count   = conditions.value.trigger.count
            percent = conditions.value.trigger.percent
          }
        }
      }

      dynamic "condition_sql" {
        for_each = conditions.value.type == "sql" ? [1] : []
        content {
          query = conditions.value.query

          dynamic "minutes" {
            for_each = lookup(conditions.value, "minutes", [])
            content {
              periodicity = minutes.value.periodicity
            }
          }

          dynamic "hourly" {
            for_each = lookup(conditions.value, "hourly", [])
            content {
              periodicity  = hourly.value.periodicity
              minute_offset = hourly.value.minute_offset
            }
          }

          dynamic "daily" {
            for_each = lookup(conditions.value, "daily", [])
            content {
              periodicity = daily.value.periodicity

              dynamic "execution_time" {
                for_each = lookup(daily.value, "execution_time", [])
                content {
                  hours   = execution_time.value.hours
                  minutes = execution_time.value.minutes
                  seconds = execution_time.value.seconds
                  nanos   = execution_time.value.nanos
                }
              }
            }
          }

          dynamic "row_count_test" {
            for_each = lookup(conditions.value, "row_count_test", [])
            content {
              comparison = row_count_test.value.comparison
              threshold  = row_count_test.value.threshold
            }
          }

          dynamic "boolean_test" {
            for_each = lookup(conditions.value, "boolean_test", [])
            content {
              column = boolean_test.value.column
            }
          }
        }
      }

      dynamic "condition_threshold" {
        for_each = conditions.value.type == "metric" ? [1] : []
        content {
          filter          = conditions.value.filter
          comparison      = conditions.value.comparison
          threshold_value = conditions.value.threshold_value
          duration        = conditions.value.duration

          dynamic "aggregations" {
            for_each = lookup(conditions.value, "aggregations", [])
            content {
              alignment_period    = aggregations.value.alignment_period
              per_series_aligner  = aggregations.value.per_series_aligner
              cross_series_reducer = aggregations.value.cross_series_reducer
            }
          }
          # Add the new condition_threshold_trigger here
          trigger {
            count  = var.condition_threshold_trigger.count
            percent = var.condition_threshold_trigger.percent
          }
        }
      }
    }
  }

  notification_channels = concat([for channel in google_monitoring_notification_channel.tlz_notification_channel : channel.id], var.existing_notification_channels)

  dynamic "alert_strategy" {
    for_each = local.enable_alert_strategy ? [1] : []

    content {
      auto_close = var.auto_close

      dynamic "notification_rate_limit" {
          #for_each = var.notification_rate_limit_period != null ? [1] : []
          for_each = var.notification_rate_limit_period != null && anytrue([for cond in var.alert_conditions : cond.type == "log"]) ? [1] : []
        content {
          period = var.notification_rate_limit_period
        }
      }

      dynamic "notification_channel_strategy" {
        for_each = var.notification_channel_strategy != null ? [1] : []

        content {
          notification_channel_names = var.notification_channel_strategy.notification_channel_names
          renotify_interval          = var.notification_channel_strategy.renotify_interval
        }
      }
    }
  }

  user_labels = var.alert_policy_user_labels
}

#resource "google_monitoring_notification_channel" "tlz_notification_channel" {
  #for_each     = { for k, v in var.notification_channels : k => v }
  #project      = var.project_id
  #display_name = each.value.display_name
  #type         = each.value.type
  #labels       = each.value.labels
#}
