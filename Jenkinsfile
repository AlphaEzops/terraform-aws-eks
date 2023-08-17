pipeline {
  agent any
  stages {
    stage('Download Tools') {
      steps {
        sh '''echo "Step 0: Downloading AWS CLI and Helm CLI"
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

curl -LO "https://get.helm.sh/helm-v3.7.0-linux-amd64.tar.gz"
tar -zxvf helm-v3.7.0-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
rm -rf linux-amd64 helm-v3.7.0-linux-amd64.tar.gz
'''
      }
    }

  }
}