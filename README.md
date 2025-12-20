Write the dockerfile,app.yml and terraform (main.tf) file 

1.Build docker image and push image to dockerhub
2.write a deployment file in app.yml using dockerimage in dockerhub
3.Create a VPC,IAM,EC2 by giving user data for installing docker & jenkins
4.After successfull installation configure aws in Ec2 machine by (/ aws configure by entering accessid & secretkey )
5.Install eks cluster and nodegroups by below commands

-----> Install kubectl & eksctl

        curl -o kubectl https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin
        sudo apt install zip
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip awscliv2.zip
        sudo ./aws/install
        curl --silent  --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
        sudo mv /tmp/eksctl /usr/local/bin

        NOTE:add role for eks ( adminaccess ) & attach to ec2 instance 

-----> Installing cluster

        eksctl create cluster --name  guvi-eks-cluster \
        --region ap-south-1 \
        --node-type t2.medium

