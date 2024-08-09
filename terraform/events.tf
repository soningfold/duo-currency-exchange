resource "aws_scheduler_schedule" "scheduler" {
  name       = "three-min-scheduler"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = "rate(3 minutes)"

  target {
    arn      = aws_sfn_state_machine.sfn_state_machine.arn
    role_arn = aws_iam_role.iam_for_scheduler.arn
  }
}