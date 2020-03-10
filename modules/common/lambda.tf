############################################################################
# Lambda Function
############################################################################
resource "aws_lambda_function" "lambda_function" {
  count         = "${var.enable ? 1 : 0}"
  function_name = "${var.name}"
  role          = "${var.aws_lambda_function_role}"

  s3_bucket     = "${var.s3_bucket}"
  s3_key        = "${var.s3_key}"

  timeout       = "${var.timeout}"
  memory_size   = "${var.memory_size}"

  handler       = "${var.handler}"
  runtime       = "${var.runtime}"

  tags          = "${local.tags}"

  vpc_config {
    subnet_ids         = ["${var.subnets}"]
    security_group_ids = ["${aws_security_group.lambda_function_security_group.id}"]
  }
  tracing_config {
    mode = "${var.enable_tracing_mode}"
  }
  environment {
    variables = {
      ENV_QUALIFIER = "${var.env_qualifier}"
      
    }
  }
}

############################################################################
# Security Group
############################################################################
resource "aws_security_group" "lambda_function_security_group" {
  count       = "${var.enable ? 1 : 0}"
  name        = "${var.name}-lambda-function"
  description = "allow inbound access from the correct location"
  vpc_id      = "${var.vpc_id}"
  tags = "${local.tags}"
}

resource "aws_security_group_rule" "lambda_function_security_group_rule_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.lambda_function_security_group.id}"
  cidr_blocks       = ["10.0.0.0/8"]
}
resource "aws_security_group_rule" "lambda_function_security_group_rule_splunk" {
  type              = "egress"
  from_port         = 8088
  to_port           = 8088
  protocol          = "tcp"
  security_group_id = "${aws_security_group.lambda_function_security_group.id}"
  description       = "connect to splunk"
  cidr_blocks       = ["10.0.0.0/8"]
}
resource "aws_security_group_rule" "lambda_function_security_group_rule_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = "${aws_security_group.lambda_function_security_group.id}"
  cidr_blocks       = ["10.0.0.0/8"]
}
