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
    resources = [aws_codedeploy_deployment_group.task_manager_app_deployment_group.arn]
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
  autoscaling_groups     = [aws_autoscaling_group.task_manager_asg.arn]
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }

    green_fleet_provisioning_option {
      action = "COPY_AUTO_SCALING_GROUP"
    }
  }

  deployment_style {
    deployment_type   = "BLUE_GREEN"
    deployment_option = "WITH_TRAFFIC_CONTROL"
  }

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.task_manager_target_group.name
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

}

# Define the CodeDeploy deployment configuration
resource "aws_codedeploy_deployment_config" "task_manager_deployment_config" {
  deployment_config_name = "task_manager_deployment.AllAtOnce"

  minimum_healthy_hosts {
    type  = "HOST_COUNT"
    value = 2
  }
}

