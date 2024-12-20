######################
#/     Policies     /#
######################
resource "aws_iam_role" "image_builder_role" {
  name = "ImageBuilderRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ec2_policy" {
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilder"
  role       = aws_iam_role.image_builder_role.name
}

resource "aws_iam_role_policy_attachment" "attach_core_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role      = aws_iam_role.image_builder_role.name
}

resource "aws_iam_instance_profile" "image_builder" {
  name = "ImageBuilderInstanceProfile"
  role = aws_iam_role.image_builder_role.name
}

###########################
#/     Image Builder     /#
###########################
resource "aws_imagebuilder_component" "test" {
  name    = "test"
  version = "1.0.0"
  platform = "Linux"

   data = yamlencode({
    phases = [{
      name = "build"
      steps = [{
        action = "ExecuteBash"
        inputs = {
          commands = [
            "sudo yum update -y",
            "sudo yum install -y amazon-cloudwatch-agent",
            "sudo yum install -y httpd",
            "echo '<html><body><h1>Hello World</h1></body></html>' | sudo tee /var/www/html/index.html",
            "sudo systemctl start httpd",
            "sudo systemctl enable httpd",
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:./files/cw-agent-config.json",
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a stop",
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a start"
            ]
        }
        name      = "example"
        onFailure = "Continue"
      }
      ]
    }]
    schemaVersion = 1.0
  })
}

data "aws_ami" "al2023" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.5.*-kernel-6.1-x86_64"]
  }

  owners = ["137112412989"]
}

resource "aws_imagebuilder_image_recipe" "al2023" {
  name           = "al2023"
  version        = "1.0.0"
  # parent_image   = "ami-0182f373e66f89c85" #al2023
  parent_image = data.aws_ami.al2023.id
  component {
    component_arn     = aws_imagebuilder_component.test.arn
  }
  block_device_mapping {
    device_name = "/dev/xvda"
    ebs {
      delete_on_termination = true
      volume_size           = 10
      volume_type           = "gp2"
    }
  }
}

resource "aws_imagebuilder_infrastructure_configuration" "al2023" {
  name                   = "al2023"
  instance_types         = ["t2.micro"]
  security_group_ids     = [aws_security_group.this.id]
  subnet_id              = aws_subnet.this.id
  instance_profile_name  = aws_iam_instance_profile.image_builder.name
}

resource "aws_imagebuilder_image_pipeline" "al2023" {
  name         = "al2023"
  image_recipe_arn         = aws_imagebuilder_image_recipe.al2023.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.al2023.arn
}

########################
#/     Test Image     /#
########################
resource "aws_imagebuilder_image" "test" {
  image_recipe_arn                 = aws_imagebuilder_image_recipe.al2023.arn
  infrastructure_configuration_arn = aws_imagebuilder_infrastructure_configuration.al2023.arn
}