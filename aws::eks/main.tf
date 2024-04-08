

# ---------------------------------------------------------------------
# EKS
# ---------------------------------------------------------------------
resource "aws_eks_cluster" "sac_eks_cluster" {
  name     = "sac-testing-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    security_group_ids     = [aws_security_group.eks_security_group.id]
    subnet_ids             = [aws_subnet.eks_subnet_1.id, aws_subnet.eks_subnet_2.id]
    endpoint_public_access = true            # SaC Testing - Severity: Critical - Set endpoint_public_access to true
    public_access_cidrs    = ["0.0.0.0/0"] # SaC Testing - Severity: Critical - Set public_access_cidrs to *
  # Drata: Ensure that [aws_eks_cluster.vpc_config.public_access_cidrs] is explicitly defined and narrowly scoped to only allow trusted sources to access public EKS API server endpoint
  }

  encryption_config { # SaC Testing - Severity: High - Set encryption_config to undefined
    provider {
      key_arn = aws_kms_key.eks_key.arn
    }
    resources = ["secrets"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.demo-cluster-AmazonEKSVPCResourceController,
  ]

  tags = {
    key = "value"
  }
}

resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  cluster_name           = aws_eks_cluster.sac_eks_cluster.name
  fargate_profile_name   = "sac-eks-fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_cluster_role.arn
  subnet_ids             = [aws_subnet.eks_subnet_2.id]

  selector {
    namespace = "example"
  }
  # SaC Testing - Severity: Moderate - Set tags to undefined
  tags = {
    key = "value"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.sac_eks_cluster.name
  node_group_name = "eks-cluster-node-group"
  node_role_arn   = aws_iam_role.demo-node.arn
  subnet_ids      = [aws_subnet.eks_subnet_1.id]

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
  # SaC Testing - Severity: Moderate - Set tags to undefined
  tags = {
    key = "value"
  }
}
