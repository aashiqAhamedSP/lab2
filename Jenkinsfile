pipeline{
    agent {
     label 'node1'
    }
    

    stages {
        
        stage('git checkout'){
            
            steps{
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: '8b432ff3-8216-48f7-b218-176da6d31520', url: 'https://github.com/aashiqAhamedSP/lab2.git']]])
            }
        }
        
        stage('AZ CLI script for terraform storage account'){
            steps{
                sh 'sudo chmod +x strgaccntforterraform.sh'
                sh 'sh strgaccntforterraform.sh'
            }
            
        }
        
        stage('get storage account keys'){
            steps{
                sh 'sudo chmod +x strgkeys.sh'
                sh 'sh strgkeys.sh'
            }
            
        }
    
        stage('Terraform Init'){
            
            steps {
                    withCredentials([azureServicePrincipal(
                    credentialsId: 'AZSP',
                    subscriptionIdVariable: 'AZ_SUB_ID',
                    clientIdVariable: 'AZ_SP_CL_ID',
                    clientSecretVariable: 'AZ_SP_CL_CR',
                    tenantIdVariable: 'AZ_SP_TN_ID'
                )]) {
                        
                        sh """
                               
                        echo "Initialising Terraform"
                        terraform init
                        """
                         
                    }
             }
        }
		stage('Terraform Validate'){
            
            steps {
                    
                    withCredentials([azureServicePrincipal(
                    credentialsId: 'AZSP',
                    subscriptionIdVariable: 'AZ_SUB_ID',
                    clientIdVariable: 'AZ_SP_CL_ID',
                    clientSecretVariable: 'AZ_SP_CL_CR',
                    tenantIdVariable: 'AZ_SP_TN_ID'
                )]) {
                        
                        sh """
                                
                        terraform validate
                        """
                           }
                    }
             }
			 
		stage('Terraform Plan'){
            steps {

                    
                    withCredentials([azureServicePrincipal(
                    credentialsId: 'AZSP',
                    subscriptionIdVariable: 'AZ_SUB_ID',
                    clientIdVariable: 'AZ_SP_CL_ID',
                    clientSecretVariable: 'AZ_SP_CL_CR',
                    tenantIdVariable: 'AZ_SP_TN_ID'
                )]) {
                        
                        sh """
                        
                        echo "Creating Terraform Plan"
                        terraform plan -var "subid=$AZ_SUB_ID" -var "clid=$AZ_SP_CL_ID" -var "clcr=$AZ_SP_CL_CR" -var "tnid=$AZ_SP_TN_ID"
                        """
                        }
                }
            }
            
        stage('Terraform apply'){
            steps {

                    
                    withCredentials([azureServicePrincipal(
                    credentialsId: 'AZSP',
                    subscriptionIdVariable: 'AZ_SUB_ID',
                    clientIdVariable: 'AZ_SP_CL_ID',
                    clientSecretVariable: 'AZ_SP_CL_CR',
                    tenantIdVariable: 'AZ_SP_TN_ID'
                )]) {
                        
                        sh """
                        
                        echo "Creating Terraform resources now!!"
                        terraform apply --auto-approve -var "subid=$AZ_SUB_ID" -var "clid=$AZ_SP_CL_ID" -var "clcr=$AZ_SP_CL_CR" -var "tnid=$AZ_SP_TN_ID"
                        """
                        }
                }
            }
            
        stage('setting up inventory for ansible'){
            steps{
                sh 'sudo chmod +x hostsetup.sh'
                sh 'sh hostsetup.sh'
                ansiblePlaybook disableHostKeyChecking: true, extras: '-u azureuser', inventory: 'inventory', playbook: 'installmysql.yaml'
            }
            
        }
        }
        
    }   
   
