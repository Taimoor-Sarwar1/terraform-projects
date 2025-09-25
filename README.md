This terraform module contains following AWS resources:
1. 1 VPC
2. 2 public subnets
3. 1 EC2 instance running in one of the subnets

Additionally, to make our instance publically accessible, other resources are created as follow:
1. Internet Gateway:
2. Route Table: In which a route is defined that connects 0.0.0.0/0 to Internet Gateway.
3. Route Table Association: Subnets are associated to the Route Table to be able to public.
4. Security Group: Having 0.0.0.0/0 allowing incoming requests to SSH port.
