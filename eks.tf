resource "aws_eks_cluster" "mongo-eks-cluster" {
 name = "mongo-eks-cluster"
 role_arn = aws_iam_role.eks-iam-role.arn
 version = 1.23

 vpc_config {
  subnet_ids = [aws_subnet.sub-1.id,
 aws_subnet.sub-2.id]
 }

 depends_on = [
  aws_iam_role.eks-iam-role,
 ]
}
resource "aws_eks_addon" "example" {
  cluster_name = aws_eks_cluster.mongo-eks-cluster.name
  addon_name   = "aws-efs-csi-driver"
}

resource "aws_eks_node_group" "worker-node-group" {
  cluster_name  = aws_eks_cluster.mongo-eks-cluster.id
  node_group_name = "mongo-workernodes"
  node_role_arn  = aws_iam_role.workernodes.arn
  subnet_ids   = [aws_subnet.sub-1.id]
  instance_types = ["t2.medium"]
 
  scaling_config {
   desired_size = 2
   max_size     = 3
   min_size     = 1
  }
 
  depends_on = [
   aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
   aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
   aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
 }