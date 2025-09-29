In this terraform module, following AWS resources are being created:
1. 1 VPC
2. Public subnets
3. 1 EKS cluster with 1 master node and 2 worker nodes (EC2 instances)

After creating the resources through "terraform apply", run "aws eks update-kubeconfig --region us-east-1 --name eks-cluster" command in VS Code.
This command lets you connect to your EKS cluster so that you can run kubectl commands from VS Code.
Now, you can run pods or whatever kubernetes work required.
"nginx-deployment.yaml" is the kubernetes manifest file.
