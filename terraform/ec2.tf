resource "aws_instance" "this" {
  ami           = "ami-057b6e529186a8233" // Amazon Linux 2023
  instance_type = "c6i.large"

  vpc_security_group_ids = [aws_security_group.ec2.id]
  subnet_id              = aws_subnet.subnets[0].id
  iam_instance_profile   = aws_iam_instance_profile.this.name


  tags = {
    Name = local.name
  }
}

resource "aws_security_group" "ec2" {
  name        = "instance-${local.name}"
  description = "Security group for ${local.name} EC2"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "TCP"
    cidr_blocks = [
      aws_vpc.this.cidr_block
    ]
    # security_groups = [
    #   aws_security_group.this.default.id
    # ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "instance_profile_role" {
  name               = "rl-${local.name}-default-instance-profile"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.assume.json
}

data "aws_iam_policy_document" "assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "instance-profile-${local.name}"
  role = aws_iam_role.instance_profile_role.name
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.instance_profile_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
