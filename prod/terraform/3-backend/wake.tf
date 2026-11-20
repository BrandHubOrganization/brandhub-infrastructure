# =========================================================
# Wake on request / sleep when idle (crawl, edit_video)
#   - Wakers (gateway: edit_video, core: crawl) call ec2:StartInstances with the shared EC2 role.
#   - EventBridge Scheduler wakes crawl at crawl_schedule_times and starts a scheduled crawl over SSM.
#   - Each wakeable host stops itself when idle (ec2-ecr/wake/idle-sleep.sh).
# =========================================================

locals {
  wakeable = { for k, v in var.instances : k => aws_instance.brandhub[k] if v.wake_on_request }
}

# Shared EC2 role (from the IAM stack): start only Wakeable=true instances.
resource "aws_iam_role_policy" "ec2_wake_instances" {
  name = "brandhub-wake-instances"
  role = data.aws_iam_instance_profile.ecr_pull.role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = ["ec2:StartInstances"]
        Resource  = "arn:aws:ec2:${var.aws_region}:${var.aws_account_id}:instance/*"
        Condition = { StringEquals = { "aws:ResourceTag/Wakeable" = "true" } }
      },
      {
        Effect   = "Allow"
        Action   = ["ec2:DescribeInstances"]
        Resource = "*"
      }
    ]
  })
}

# ---------------------------------------------------------
# Scheduled crawls
# ---------------------------------------------------------

resource "aws_iam_role" "scheduler_crawl" {
  name = "brandhub-scheduler-crawl"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "scheduler.amazonaws.com" }
      Action    = "sts:AssumeRole"
      Condition = { StringEquals = { "aws:SourceAccount" = var.aws_account_id } }
    }]
  })
}

resource "aws_iam_role_policy" "scheduler_crawl" {
  name = "brandhub-scheduler-crawl"
  role = aws_iam_role.scheduler_crawl.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:StartInstances"]
        Resource = aws_instance.brandhub["crawl"].arn
      },
      {
        Effect = "Allow"
        Action = ["ssm:SendCommand"]
        Resource = [
          aws_instance.brandhub["crawl"].arn,
          "arn:aws:ssm:${var.aws_region}::document/AWS-RunShellScript",
        ]
      }
    ]
  })
}

locals {
  # Crawl starts at t; the host wakes crawl_wake_lead_minutes earlier (wraps past midnight).
  crawl_times = { for t in var.crawl_schedule_times : replace(t, ":", "") => {
    hour        = tonumber(split(":", t)[0])
    minute      = tonumber(split(":", t)[1])
    wake_hour   = floor(((tonumber(split(":", t)[0]) * 60 + tonumber(split(":", t)[1]) - var.crawl_wake_lead_minutes + 1440) % 1440) / 60)
    wake_minute = (tonumber(split(":", t)[0]) * 60 + tonumber(split(":", t)[1]) - var.crawl_wake_lead_minutes + 1440) % 60
  } }
}

resource "aws_scheduler_schedule" "crawl_wake" {
  for_each = local.crawl_times

  name                         = "brandhub-crawl-wake-${each.key}"
  schedule_expression          = "cron(${each.value.wake_minute} ${each.value.wake_hour} * * ? *)"
  schedule_expression_timezone = "Asia/Ho_Chi_Minh"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.scheduler_crawl.arn
    input    = jsonencode({ InstanceIds = [aws_instance.brandhub["crawl"].id] })
  }
}

# At the crawl time the host is up; crawl-kick.sh waits for the API, then starts the run.
resource "aws_scheduler_schedule" "crawl_kick" {
  for_each = local.crawl_times

  name                         = "brandhub-crawl-kick-${each.key}"
  schedule_expression          = "cron(${each.value.minute} ${each.value.hour} * * ? *)"
  schedule_expression_timezone = "Asia/Ho_Chi_Minh"

  flexible_time_window {
    mode = "OFF"
  }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:ssm:sendCommand"
    role_arn = aws_iam_role.scheduler_crawl.arn
    input = jsonencode({
      DocumentName = "AWS-RunShellScript"
      InstanceIds  = [aws_instance.brandhub["crawl"].id]
      Parameters   = { commands = ["/usr/local/bin/brandhub-crawl-kick.sh"] }
    })

    retry_policy {
      maximum_retry_attempts       = 3
      maximum_event_age_in_seconds = 900
    }
  }
}

output "wakeable_instances" {
  description = "Instances that sleep when idle; set WAKE_TARGETS for the wakers from these IDs"
  value       = { for k, i in local.wakeable : k => i.id }
}
