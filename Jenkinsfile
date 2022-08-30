pipeline {

	agent any

    environment {
        appname = "stackapp"
        appver = "v2"
        artficatreporeg = "https://ashwinbittu.jfrog.io"
        artifactrepo = "/stackapp-repo"
        artifactrepocreds = 'jfrog-artifact-saas'
        infracreatemode = true
    }

    stages{

        stage('BUILD'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }            
            steps {
                sh 'mvn clean install -DskipTests'
            }
            post {
                success {
                    echo 'Now Archiving...'
                    archiveArtifacts artifacts: '**/target/*.war'
                }
            }
        }

        stage('UNIT TEST'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }              
            steps {
                sh 'mvn test'
            }
            }

        stage('INTEGRATION TEST'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }              
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
            }

        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }              
            steps {
                sh 'mvn checkstyle:checkstyle'
            }
            post {
                success {
                    echo 'Generated Analysis Result'
                }
            }
        }

       /* 
        stage('CODE ANALYSIS with SONARQUBE') {
		  environment {
             scannerHome = tool 'sonarqscan'
          }
          when{
                environment name: 'infracreatemode', value: 'false'
          }          
          steps {
             withSonarQubeEnv('sonar') {
                   sh '''${scannerHome}/bin/sonar-scanner -Dsonar.projectKey=radammcorp \
                   -Dsonar.projectName=radammcorp \
                   -Dsonar.projectVersion=1.0 \
                   -Dsonar.sources=src/ \
                   -Dsonar.java.binaries=target/test-classes/com/radammcorpit/account/controllerTest/ \
                   -Dsonar.junit.reportsPath=target/surefire-reports/ \
                   -Dsonar.jacoco.reportsPath=target/jacoco.exec \
                   -Dsonar.java.checkstyle.reportPaths=target/checkstyle-result.xml'''
              }
            }
            timeout(time: 10, unit: 'MINUTES') {
               waitForQualityGate abortPipeline: true
            }
          }
        }
        

        stage ('Upload App Image to Artifactory') {
            when{
                environment name: 'infracreatemode', value: 'false'
            }              
                    steps {
                        withCredentials([string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 
                            sh """
                            echo "HH"
                            
                            curl -H "X-JFrog-Art-Api:$ART_TOKEN" -T target/stackapp-v2.war "https://ashwinbittu.jfrog.io/artifactory/stackapp-repo/${BUILD_NUMBER}/stackapp-v2.war"
                            
                            """
                        }
                    }
        }

       */

	    stage ('Backing AMIs')  {
            when {
                environment name: 'infracreatemode', value: 'false'
            }
	        steps {
                //checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/ashwinbittu/stackApp-infra.git']]])
                
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "awscreds",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            aws sts get-caller-identity
                            rm -rf stackApp
                            git clone -b main https://github.com/ashwinbittu/stackApp.git
                            cd stackApp/iac/packer
                            
                            #App/Tomcat Bake
                            /usr/bin/packer validate -var "app_layer=app" -var "source_ami=$ubuntu_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$app_userscript" -var "ssh_username=$ubuntu_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$ubuntu_owners"  template.ubuntu.pkr.hcl
                            /usr/bin/packer build    -var "app_layer=app" -var "source_ami=$ubuntu_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$app_userscript" -var "ssh_username=$ubuntu_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$ubuntu_owners" template.ubuntu.pkr.hcl
                            cp manifest.json app_img_manifest.json
                            
                            #Mesg/Rabbitmq
                            /usr/bin/packer validate -var "app_layer=msg" -var "source_ami=$ubuntu_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$msg_userscript" -var "ssh_username=$ubuntu_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$ubuntu_owners"  template.ubuntu.pkr.hcl
                            /usr/bin/packer build    -var "app_layer=msg" -var "source_ami=$ubuntu_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$msg_userscript" -var "ssh_username=$ubuntu_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$ubuntu_owners"  template.ubuntu.pkr.hcl
                            cp manifest.json message_img_manifest.json


                            #DB/Maria-MySQL Bake
                            /usr/bin/packer validate -var "app_layer=db" -var "source_ami=$amzlnx_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$db_userscript" -var "ssh_username=$amzlnx_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$amzlnx_owners"  template.amzlinx2.pkr.hcl
                            /usr/bin/packer build    -var "app_layer=db" -var "source_ami=$amzlnx_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$db_userscript" -var "ssh_username=$amzlnx_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$amzlnx_owners"  template.amzlinx2.pkr.hcl
                            cp manifest.json db_img_manifest.json

                            #Cache/Memcache
                            /usr/bin/packer validate -var "app_layer=cache" -var "source_ami=$amzlnx_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$cache_userscript" -var "ssh_username=$amzlnx_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$amzlnx_owners"  template.amzlinx2.pkr.hcl
                            /usr/bin/packer build    -var "app_layer=cache" -var "source_ami=$amzlnx_source_ami" -var "app_name=$app_name_stackapp" -var "instance_type=$instance_type" -var "script=$cache_userscript" -var "ssh_username=$amzlnx_ssh_username" -var "root-device-type=$ubuntu_root_device_type" -var "virtualization-type=$ubuntu_virtualization_type" -var "owners=$amzlnx_owners"  template.amzlinx2.pkr.hcl
                            cp manifest.json cache_img_manifest.json


                        

                        '''
                    
                    }
            }
         
        }

        stage('Network Infra Creation Using Terraform'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }              
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh '''
                                        
                                        export TFE_TOKEN=$TFE_TOKEN 
                                        export TFE_ORG=$TFE_ORG
                                        export TFE_ADDR=$TFE_ADDR
                                        export REPO_API_TOKEN=$REPO_API_TOKEN 
                                        export REPO_FID=$REPO_API_USER
                                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                        export AWS_REGION=$AWS_DEFAULT_REGION
                                        export targetRegion=$AWS_DEFAULT_REGION
                                        export env=$APP_ENV_DEV
                                        export appname=$app_name_stackapp

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create network
                                        #./manageInfra.sh destroy 

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('Application Infra Creation Using Terraform'){
            when{
                environment name: 'infracreatemode', value: 'false'
            }              
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh '''
                                        
                                        export TFE_TOKEN=$TFE_TOKEN 
                                        export TFE_ORG=$TFE_ORG
                                        export TFE_ADDR=$TFE_ADDR
                                        export REPO_API_TOKEN=$REPO_API_TOKEN 
                                        export REPO_FID=$REPO_API_USER
                                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                        export AWS_REGION=$AWS_DEFAULT_REGION
                                        export targetRegion=$AWS_DEFAULT_REGION
                                        export env=$APP_ENV_DEV
                                        export appname=$app_name_stackapp

                                        cd stackApp/iac/packer
                                        export app_ami_id=$(jq -r '.builds[-1].artifact_id' app_img_manifest.json | cut -d ":" -f2)
                                        echo "AMI_ID-APP-->>"$app_ami_id
                                        #export app_ami_id="ami-0ab6cd77655cb413c"

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create application
                                        #./manageInfra.sh destroy

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('Database Infra Creation Using Terraform'){
            when{
                environment name: 'infracreatemode', value: 'false'
            }              
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh '''
                                        
                                        export TFE_TOKEN=$TFE_TOKEN 
                                        export TFE_ORG=$TFE_ORG
                                        export TFE_ADDR=$TFE_ADDR
                                        export REPO_API_TOKEN=$REPO_API_TOKEN 
                                        export REPO_FID=$REPO_API_USER
                                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                        export AWS_REGION=$AWS_DEFAULT_REGION
                                        export targetRegion=$AWS_DEFAULT_REGION
                                        export env=$APP_ENV_DEV
                                        export appname=$app_name_stackapp

                                        cd stackApp/iac/packer
                                        export db_ami_id=$(jq -r '.builds[-1].artifact_id' db_img_manifest.json | cut -d ":" -f2)                                        
                                        echo "AMI_ID-DB-->>"$db_ami_id                                        
                                        #export db_ami_id="ami-03f15496b423fc91e"
                                        
                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create database
                                        #./manageInfra.sh destroy

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('Caching Infra Creation Using Terraform'){
            when{
                environment name: 'infracreatemode', value: 'false'
            }              
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh '''
                                        
                                        export TFE_TOKEN=$TFE_TOKEN 
                                        export TFE_ORG=$TFE_ORG
                                        export TFE_ADDR=$TFE_ADDR
                                        export REPO_API_TOKEN=$REPO_API_TOKEN 
                                        export REPO_FID=$REPO_API_USER
                                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                        export AWS_REGION=$AWS_DEFAULT_REGION
                                        export targetRegion=$AWS_DEFAULT_REGION
                                        export env=$APP_ENV_DEV
                                        export appname=$app_name_stackapp

                                        cd stackApp/iac/packer                                       
                                        export cache_ami_id=$(jq -r '.builds[-1].artifact_id' cache_img_manifest.json | cut -d ":" -f2)                                        
                                        echo "AMI_ID-CACHE-->>"$cache_ami_id                                        
                                        #export cache_ami_id="ami-0da28db37fec7611f"

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create cache
                                        #./manageInfra.sh destroy

                                    '''   
                                }  
                        }     
                    }
            }
        }   

        stage('Messaging Infra Creation Using Terraform'){
            when{
                environment name: 'infracreatemode', value: 'false'
            }              
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh '''
                                        
                                        export TFE_TOKEN=$TFE_TOKEN 
                                        export TFE_ORG=$TFE_ORG
                                        export TFE_ADDR=$TFE_ADDR
                                        export REPO_API_TOKEN=$REPO_API_TOKEN 
                                        export REPO_FID=$REPO_API_USER
                                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                        export AWS_REGION=$AWS_DEFAULT_REGION
                                        export targetRegion=$AWS_DEFAULT_REGION
                                        export env=$APP_ENV_DEV
                                        export appname=$app_name_stackapp

                                        cd stackApp/iac/packer                                       
                                        export mesg_ami_id=$(jq -r '.builds[-1].artifact_id' message_img_manifest.json | cut -d ":" -f2)                                        
                                        echo "AMI_ID-MSG-->>"$export                                        
                                        #export mesg_ami_id="ami-0da8f4cc59749f64d"

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create message
                                        #./manageInfra.sh destroy

                                    '''   
                                }  
                        }     
                    }
            }
        }             

        stage('All Infra Destroy Using Terraform'){
            when{
                environment name: 'infracreatemode', value: 'false'
            }              
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh '''
                                        
                                        export TFE_TOKEN=$TFE_TOKEN 
                                        export TFE_ORG=$TFE_ORG
                                        export TFE_ADDR=$TFE_ADDR
                                        export REPO_API_TOKEN=$REPO_API_TOKEN 
                                        export REPO_FID=$REPO_API_USER
                                        export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
                                        export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
                                        export AWS_REGION=$AWS_DEFAULT_REGION
                                        export targetRegion=$AWS_DEFAULT_REGION
                                        export env=$APP_ENV_DEV
                                        export appname=$app_name_stackapp

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        #./manageInfra.sh destroy message
                                        #./manageInfra.sh destroy cache
                                        ./manageInfra.sh destroy database
                                        ./manageInfra.sh destroy application
                                        ./manageInfra.sh destroy network   


                                    '''   
                                }  
                        }     
                    }
            }
        }

    }


}