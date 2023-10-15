resource "aws_autoscaling_group" "task_manager_asg" {
  name                      = "task-manager-asg"
  launch_configuration      = aws_launch_template.task_manager_lc.name
  min_size                  = 2
  max_size                  = 5
  desired_capacity          = 2
  health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = var.lb_subnets_id
}

resource "aws_autoscaling_attachment" "task_manager_autoscaling_attachment" {
  autoscaling_group_name = aws_autoscaling_group.task_manager_asg.id
  lb_target_group_arn    = aws_lb_target_group.task_manager_target_group.arn
}
