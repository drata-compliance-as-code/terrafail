

# ---------------------------------------------------------------------
# EKS
# ---------------------------------------------------------------------
resource "aws_eks_cluster" "TerraFailEKS_cluster" {
  name     = "TerraFailEKS_cluster"
  role_arn = aws_iam_role.TerraFailEKS_role.arn

  vpc_config {
    security_group_ids = [aws_security_group.TerraFailEKS_security_group.id]
    subnet_ids         = [aws_subnet.TerraFailEKS_subnet.id, aws_subnet.TerraFailEKS_subnet_2.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.TerraFailEKS_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.TerraFailEKS_AmazonEKSVPCResourceController,
  ]

  tags = {
    key = "value"
  }
}

resource "aws_TerraFailEKS_fargate_profile" "TerraFailEKS_fargate_profile" {
  cluster_name           = aws_eks_cluster.TerraFailEKS_cluster.name
  fargate_profile_name   = "TerraFailEKS_fargate_profile"
  pod_execution_role_arn = aws_iam_role.TerraFailEKS_role.arn
  subnet_ids             = [aws_subnet.TerraFailEKS_subnet_2.id]

  selector {
    namespace = "TerraFailEKS"
  }
}

resource "aws_TerraFailEKS_node_group" "TerraFailEKS_node_group" {
  cluster_name    = aws_eks_cluster.TerraFailEKS_cluster.name
  node_group_name = "TerraFailEKS_node_group"
  node_role_arn   = aws_iam_role.TerraFailEKS_ec2_role.arn
  subnet_ids      = [aws_subnet.TerraFailEKS_subnet.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.TerraFailEKS_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.TerraFailEKS_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.TerraFailEKS_AmazonEC2ContainerRegistryReadOnly,
  ]
}

# ---------------------------------------------------------------------
# IAM
# ---------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "TerraFailEKS_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.TerraFailEKS_role.name
}

resource "aws_iam_role_policy_attachment" "TerraFailEKS_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.TerraFailEKS_role.name
}

resource "aws_iam_role_policy_attachment" "TerraFailEKS_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.TerraFailEKS_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "TerraFailEKS_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.TerraFailEKS_ec2_role.name
}

resource "aws_iam_role_policy_attachment" "TerraFailEKS_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.TerraFailEKS_ec2_role.name
}

resource "aws_iam_role" "TerraFailEKS_role" {
  # Drata: Set [aws_iam_role.tags] to ensure that organization-wide tagging conventions are followed.
  name = "TerraFailEKS_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": ["eks.amazonaws.com",
                    "eks-fargate-pods.amazonaws.com"]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role" "TerraFailEKS_ec2_role" {
  # Drata: Set [aws_iam_role.tags] to ensure that organization-wide tagging conventions are followed.
  name = "TerraFailEKS_ec2_role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# ---------------------------------------------------------------------
# Network
# ---------------------------------------------------------------------
resource "aws_vpc" "TerraFailEKS_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "TerraFailEKS_vpc"
  }
}

resource "aws_subnet" "TerraFailEKS_subnet" {
  vpc_id            = aws_vpc.TerraFailEKS_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-2c"

  map_public_ip_on_launch = false
  tags = {
    Name = "Main"
  }
}

resource "aws_subnet" "TerraFailEKS_subnet_2" {
  depends_on = [
    aws_vpc.TerraFailEKS_vpc,
    aws_subnet.TerraFailEKS_subnet
  ]

  vpc_id                  = aws_vpc.TerraFailEKS_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-2b"
  map_public_ip_on_launch = false

  tags = {
    Name = "Main"
  }
}

resource "aws_internet_gateway" "TerraFailEKS_gateway" {
  vpc_id = aws_vpc.TerraFailEKS_vpc.id

  tags = {
    Name = "TerraFailEKS_gateway"
  }
}

resource "aws_route_table" "TerraFailEKS_route_table" {
  # Drata: Set [aws_route_table.tags] to ensure that organization-wide tagging conventions are followed.
  vpc_id = aws_vpc.TerraFailEKS_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.TerraFailEKS_gateway.id
  }
}

resource "aws_route_table_association" "TerraFailEKS_route_table_association" {
  count = 2

  subnet_id      = aws_subnet.TerraFailEKS_subnet.id
  route_table_id = aws_route_table.TerraFailEKS_route_table.id
}

resource "aws_security_group" "TerraFailEKS_security_group" {
  name        = "TerraFailEKS_security_group"
  description = "Cluster communication with worker nodes"
  vpc_id      = aws_vpc.TerraFailEKS_vpc.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["173.0.0.0/32"]
  }
  tags = {
    Name = "TerraFailEKS_security_group"
  }
}

# ---------------------------------------------------------------------
# KMS
# ---------------------------------------------------------------------
resource "aws_kms_key" "TerraFailEKS_key" {
  # Drata: Define [aws_kms_key.policy] to restrict access to your resource. Follow the principal of minimum necessary access, ensuring permissions are scoped to trusted entities. Exclude this finding if access to Keys is managed using IAM policies instead of a Key policy
  # Drata: Set [aws_kms_key.tags] to ensure that organization-wide tagging conventions are followed.
  description              = "KMS key to encrypt/decrypt"
  deletion_window_in_days  = 10
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
  is_enabled               = true
}
