Write the dockerfile,app.yml and terraform (main.tf) file 

1.Build docker image and push image to dockerhub
2.write a deployment file in app.yml using dockerimage in dockerhub & write a service file for exposing it externally.
3.Create a VPC,IAM,EC2 by giving user data for installing docker & jenkins
4.After successfull installation configure aws in Ec2 machine by ( "aws configure" by entering accessid & secretkey )
5.Install eks cluster and nodegroups or nodes ( will create automatically) by below commands

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

-----> Creating cluster

        eksctl create cluster --name trend \          #trend ----> cluster name                            
        --region ap-south-1 \
        --node-type t2.medium

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

6. Access jenkins using public ip of EC2 instance by enabling port 8080 in inbound rule of Security Group

    Install the default plugins and also aws ( to deploy in eks ),docker,git
    go to configure in jenkins and choose pipeline script from SCM
    give the repository url
    add the git credentials ( not required if public repo)

7. Once the build is succeed then go to ec2 and type kubectl get svc 

    get the LB external ip eg: (a0051398dcccc446a8a2a6e63b8cd1db-1997863309.ap-south-1.elb.amazonaws.com) & access through web

8. Install prometheus & grafana using below commands to monitor the cluster or instance or any requirements 

    https://docs.google.com/document/d/16JuF2R3RnUtPhkqF6htQ5Z1zYvej6_ae ( all commands in this document to install )
  
    ---instal helm ( for eks )

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

    helm repo update

    helm install prometheus prometheus-community/prometheus \
    --set server.persistentVolume.enabled=false \
    --set alertmanager.persistentVolume.enabled=false

    ( use above command as persisteant volume disabled )

    kubectl expose service prometheus-server --type=NodePort --target-port=9090 --name=prometheus-server-ext

    ( Then open using http://node-group-instance-id:<port> )
    <port> you can get from kubectl get svc 
    there you can see like (80:31592/TCP) for prometheus-server-ext so enable this port in inbound rule of any node-group instance ) 
    NOTE: not in cluster instance enable in any one of node-group instance


    ------> also same for graphana

    After installing graphana

    enter this command ----> kubectl get secret --namespace default grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

    you'll get pswd 

    then finish the remaining step and edit inbound rule and expose in new tab as same as Prometheus 
    Then go to datasource and enable Prometheus to load data from Prometheus by giving any dashboard like ( 15661,1860 then load and execute )by importing it. 


