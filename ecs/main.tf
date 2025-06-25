terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.11.4" # Мінімальна версія терраформа
}

provider "aws" {
  region  = "eu-north-1"
}

resource "aws_ecs_cluster" "test" {
  name = "test-terraform"
    setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "service" {
  family = "service"
  network_mode = "bridge"
  requires_compatibilities = ["EC2"]
  cpu = 512
  memory = 512
  execution_role_arn       = "arn:aws:iam::599076352459:role/ecsTaskExecutionRole"
  task_role_arn            = "arn:aws:iam::599076352459:role/ecsTaskExecutionRole"
  
  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  container_definitions = jsonencode([
    {
      name = "first"
      image = "599076352459.dkr.ecr.eu-north-1.amazonaws.com/test-app:latest"
      essential = true
      portMappings = [
        {
          name = "test-container-80-tcp"
          containerPort = 80
          hostPort      = 80
          protocol = "tcp"
          appProtocol = "http"
        }
      ]
/*      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/my-app"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
*/
    }
  ])
}

resource "aws_ecs_service" "service" {
  name = "test-service"
  cluster = aws_ecs_cluster.test.id
  task_definition = aws_ecs_task_definition.service.arn
  desired_count = 1

  launch_type = "EC2"
}

data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "ecs" {
  name_prefix = "test-terraform-"
  image_id = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"
  iam_instance_profile {
    name = "ecsInstanceRole"
  }

  user_data = base64encode(<<EOF
  #!/bin/bash
  echo "ECS_CLUSTER=${aws_ecs_cluster.test.name}" >> /etc/ecs/ecs.config
  EOF
  )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name = "ecs-asg"
  max_size = 1
  min_size = 1
  desired_capacity = 1

  launch_template {
    id = aws_launch_template.ecs.id
    version = aws_launch_template.ecs.latest_version
  }

  vpc_zone_identifier = ["subnet-038357dbe22005793", "subnet-07d7a146391d065b5"]
  tag {
    key                 = "Name"
    value               = "${aws_launch_template.ecs.name_prefix}${aws_launch_template.ecs.id}"
    propagate_at_launch = true
  }
}

/*
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/my-app"
  retention_in_days = 7
}
*/
