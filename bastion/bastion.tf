resource "tls_private_key" "bastin-key" {
    algorithm = "RSA"
    rsa_bits = 2048

}

resource "aws_key_pair" "bastion-key-pair" {
  key_name = "${var.prefix}-key"
  public_key = tls_private_key.bastin-key.public_key_openssh
}

resource "local_file" "bastion_private_key" {
  content = tls_private_key.bastin-key.private_key_pem
  filename = "${path.module}/bastion_key.pem"
}

resource "aws_instance" "bastion" {
  ami = var.aws_ami
  instance_type = "t3a.small"

  subnet_id = var.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.bastion-sg.id]
  key_name = aws_key_pair.bastion-key-pair.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

  user_data = <<-EOF
#!/bin/bash
sudo su
set -e
set -x

echo "complete"
yum install -y docker
systemctl enable docker
systemctl restart docker

echo "complete"
cat <<EOT > buildspec.yaml
version: 0.2

phases:
  pre_build:
    commands:
      - echo Login to ECR
      - aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.ap-northeast-2.amazonaws.com
  build:
    commands:
      - echo Build started
      - docker build -t ${var.ecr_backend_name} .
      - docker tag ${var.ecr_backend_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_backend_name}:latest
  post_build:
    commands:
      - echo Push to ECR
      - docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_backend_name}:latest
artifacts:
  files:
    - appspec.yaml
    - taskdef.json
EOT

echo "complete"
cat <<EOT > appspec.yaml
version: 0.2
Resources:
  - TargetService:
      Type: AWS::ECS::Service
      Properties:
        TaskDefinition: arn:aws:ecs:${var.region}:${var.account_id}:task-definition/${var.task_definition_name}
        LoadBalancerInfo:
          ContainerName: ${var.container_name}
          ContainerPort: ${var.container_port}
        CapacityProviderStrategy:
        - Base: 2
          CapacityProvider: FARGATE_SPOT
          Weight: 1
        PlatformVersion: "LATEST"
        NetworkConfiguration:
          AwsvpcConfiguration:
            Subnets:
              - ${var.private_subnets[0]}
              - ${var.private_subnets[1]}
            SecurityGroups:
              - ${var.service_sg_id}
EOT

echo "complete"
cat <<EOT > taskdef.json
{
  "executionRoleArn": "arn:aws:iam::${var.account_id}:role/${var.ecs_task_execution_role_name}",
  "taskRoleArn": "arn:aws:iam::${var.account_id}:role/${var.ecs_task_execution_role_name}",
  "containerDefinitions": [
    {
      "name": "${var.container_name}",
      "image": "${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_backend_name}:latest",
      "portMappings": [
        {
          "containerPort": ${var.container_port},
          "hostPort": ${var.container_port},
          "protocol": "tcp"
        }
      ]
    }
  ],
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "networkMode": "awsvpc",
  "cpu": "512",
  "memory": "1024",
  "family": "${var.task_definition_name}"
}
EOT

echo "complete"
yum install git -y

export HOME=/root
git config --global credential.helper '!aws codecommit credential-helper $@'
git config --global credential.UseHttpPath true

git clone https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.be_repo_name}
git clone https://git-codecommit.${var.region}.amazonaws.com/v1/repos/${var.fe_repo_name}

echo "complete"
aws s3 cp s3://${var.file_bucket_name}/backend/ ./${var.be_repo_name} --recursive
aws s3 cp s3://${var.file_bucket_name}/frontend/ ./${var.fe_repo_name} --recursive

mv ./buildspec.yaml ./${var.be_repo_name}/
mv ./appspec.yaml ./${var.be_repo_name}/
mv ./taskdef.json ./${var.be_repo_name}/

cd ${var.be_repo_name}
unzip ./*.zip -d .
rm -rf *.zip

echo "complete"
aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com
docker build -t ${var.ecr_backend_name} .
docker tag ${var.ecr_backend_name}:latest ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_backend_name}:latest
docker push ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com/${var.ecr_backend_name}:latest

echo "complete"
git init
git add .
git commit -m "Initial commit"
git checkout -b ${var.default_branch}
git push origin ${var.default_branch}

cd ..

echo "complete"
cd ${var.fe_repo_name}

echo "complete"
git init
git add .
git commit -m "Initial commit"
git checkout -b ${var.default_branch}
git push origin ${var.default_branch}
EOF



  tags = {
    "Name" = "${var.prefix}-bastion-ec2"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion.id
  
  tags = {
    Name = "${var.prefix}-bastion-eip"
  }
}