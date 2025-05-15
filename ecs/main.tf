provider "aws" {
  region = "eu-north-1"
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

resource "aws_launch_template" "ecs_template" {
  name_prefix   = "ecs-launch-template"
  image_id      = "ami-0a33e2549d1f690dd" # ECS-optimized AMI for EU-NORTH-1
  instance_type = "t3.micro"

  user_data = base64encode(file("user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ECS Instance"
    }
  }
}

resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = ["subnet-xxxxxx"] # Вкажи свої сабнети
  launch_template {
    id      = aws_launch_template.ecs_template.id
    version = "$Latest"
  }

  tag {
    key                 = "AmazonECSCluster"
    value               = aws_ecs_cluster.ecs_cluster.name
    propagate_at_launch = true
  }
}

resource "aws_ecs_task_definition" "web_task" {
  family                   = "web-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = file("task-def.json")
}

resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = 1
  launch_type     = "EC2"
}
