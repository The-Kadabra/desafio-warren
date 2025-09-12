###############
# Target Nginx#
###############
resource "aws_lb_target_group" "nginx_tg" {
  depends_on  = [module.ec2_instance]
  name        = format("%s-%s-nginx-tg", var.project, var.environment)
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.tags
}

####################
# Target Prometheus#
####################
resource "aws_lb_target_group" "prometheus_tg" {
  depends_on  = [module.ec2_instance]
  name        = format("%s-%s-prometheus-tg", var.project, var.environment)
  port        = 9090
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.tags
}

################
# Load Balancer#
################
resource "aws_lb" "app_lb" {
  depends_on          = [module.ec2_instance]
  name                = "${var.project}-${var.environment}-alb"
  load_balancer_type  = "application"
  security_groups     = [module.ec2_instance.security_group_id]
  subnets             = module.vpc.public_subnets

  tags = var.tags
}

##############################
# Listener - Porta 80 (Nginx)#
##############################
resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

#####################################
# Listener - Porta 9090 (prometheus)#
#####################################
resource "aws_lb_listener" "prometheus_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 9090
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.prometheus_tg.arn
  }
}

############################
# Attachments (EC2 nos TGs)#
############################
resource "aws_lb_target_group_attachment" "nginx_attach" {
  target_group_arn = aws_lb_target_group.nginx_tg.arn
  target_id        = module.ec2_instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "prometheus_attach" {
  target_group_arn = aws_lb_target_group.prometheus_tg.arn
  target_id        = module.ec2_instance.id
  port             = 9090
}

#################
# Target Grafana#
#################
resource "aws_lb_target_group" "grafana_tg" {
  depends_on  = [module.ec2_instance]
  name        = format("%s-%s-grafana-tg", var.project, var.environment)
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "instance"

  health_check {
    path                = "/login"         
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = var.tags
}

##################################
# Listener - Porta 3000 (Grafana)#
##################################
resource "aws_lb_listener" "grafana_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 3000
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grafana_tg.arn
  }
}

###############################
# Attachment EC2 -> TG Grafana#
###############################
resource "aws_lb_target_group_attachment" "grafana_attach" {
  target_group_arn = aws_lb_target_group.grafana_tg.arn
  target_id        = module.ec2_instance.id
  port             = 3000
}
