resource "aws_iam_role" "codedeploy_role" {
  name = "my-app-codedeploy-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "codedeploy_policy" {
  name        = "task-manager-app-codedeploy-policy"
  policy      = data.aws_iam_policy_document.codedeploy_policy.json
  description = "Allows CodeDeploy to deploy"
}

data "aws_iam_policy_document" "codedeploy_policy" {
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "codedeploy_policy_attachment" {
  policy_arn = aws_iam_policy.codedeploy_policy.arn
  role       = aws_iam_role.codedeploy_role.name
}

# Define the CodeDeploy application
resource "aws_codedeploy_app" "task_manager_app" {
  name = "task-manager-app"
}

# Define the CodeDeploy deployment group
resource "aws_codedeploy_deployment_group" "task_manager_app_deployment_group" {
  app_name               = aws_codedeploy_app.task_manager_app.name
  deployment_group_name  = "prod"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.task_manager_green.name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

}

# Define the CodeDeploy deployment configuration
resource "aws_codedeploy_deployment_config" "app_deployment_config" {
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
}
