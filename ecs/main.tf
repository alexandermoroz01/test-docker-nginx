provider "aws" {
  region = "eu-north-1"
}

# Отримуємо останній ECS-оптимізований AMI
data "aws_ssm_parameter" "ecs_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

# ECS кластер
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "my-ecs-cluster"
}

# Security Group для EC2
resource "aws_security_group" "ecs_sg" {
  name        = "ecs_sg"
  description = "Allow HTTP"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch Template
resource "aws_launch_template" "ecs_template" {
  name_prefix   = "ecs-launch-template"
  image_id      = data.aws_ssm_parameter.ecs_ami.value
  instance_type = "t3.micro"

  vpc_security_group_ids = [aws_security_group.ecs_sg.id]

  user_data = base64encode(file("user_data.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "ECS Instance"
    }
  }
}

# Auto Scaling Group для EC2 під ECS
resource "aws_autoscaling_group" "ecs_asg" {
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.public_1.id]

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

# ECS Task Definition (читає task-def.json)
resource "aws_ecs_task_definition" "web_task" {
  family                   = "web-task"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = file("task-def.json")
}

# ECS Service (запускає контейнер на EC2 інстансі)
resource "aws_ecs_service" "web_service" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.web_task.arn
  desired_count   = 1
  launch_type     = "EC2"
}
