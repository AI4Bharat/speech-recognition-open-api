#!/bin/bash
namespace=$1
echo "Install AWS cli"
export TZ=Europe/Minsk && sudo ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > sudo  /etc/timezone && sudo apt-get update && sudo apt-get install -y awscli
echo "Install and confgure kubectl"
sudo curl -L https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && sudo chmod +x /usr/local/bin/kubectl
echo "Install and confgure kubectl aws-iam-authenticator"
sudo curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.10.3/2018-07-26/bin/linux/amd64/aws-iam-authenticator && sudo chmod +x ./aws-iam-authenticator && sudo cp ./aws-iam-authenticator /bin/aws-iam-authenticator
echo  "Install latest awscli version"
sudo apt install unzip && curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip" && unzip awscli-bundle.zip &&./awscli-bundle/install -b ~/bin/aws
echo "Get the kubeconfig file "
export KUBECONFIG=$HOME/.kube/kubeconfig && /home/circleci/bin/aws eks --region $AWS_REGION update-kubeconfig --name $EKS_CLUSTER_NAME
echo "Install and configuire helm"
curl https://baltocdn.com/helm/signing.asc | sudo apt-key add -
sudo apt-get install apt-transport-https --yes
echo "deb https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
#echo "Initialize helm"
#helm init --client-only --kubeconfig=$HOME/.kube/kubeconfig
#echo "Install tiller plugin"
#helm plugin install https://github.com/rimusz/helm-tiller --kubeconfig=$HOME/.kube/kubeconfig
#helm tiller start-ci
export HELM_HOST=127.0.0.1:44134
result=$(eval helm ls --namespace $namespace | grep asr-model-v2)
if [ $? -ne "0" ]; then
   echo "install helm charts"
   helm install --timeout 180s asr-model-v2 asr-model-v2 --set namespace=$namespace --namespace $namespace --create-namespace
else
   echo "Upgrade helm charts"
   helm upgrade --timeout 180s asr-model-v2 asr-model-v2 --set namespace=$namespace --namespace $namespace --create-namespace
fi
#echo "stop tiller"
#helm tiller stop


