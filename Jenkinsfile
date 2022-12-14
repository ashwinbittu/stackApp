pipeline {

	agent any

    environment {
        appname = "stackapp"
        appver = "v2"
        artficatreporeg = "https://ashwinbittu.jfrog.io"
        artifactrepo = "/stackapp-repo"
        artifactrepocreds = 'jfrog-artifact-saas'
        infracreatemode = false
    }

    stages{

        stage('Build App'){
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

        stage('Unit Testing Of App'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }              
            steps {
                sh 'mvn test'
            }
            }

        stage('Integration Testing of App'){
            when{
                environment name: 'infracreatemode', value: 'true'
            }              
            steps {
                sh 'mvn verify -DskipUnitTests'
            }
            }

        stage ('Code Analysis With Checkstyle'){
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
        stage('Code Analysis With Sonarqube') {
		  environment {
             scannerHome = tool 'sonarqscan'
          }
          when{
                environment name: 'infracreatemode', value: 'true'
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
                environment name: 'infracreatemode', value: 'true'
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
                environment name: 'infracreatemode', value: 'true'
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

        stage('Network Infra Creation'){
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

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('Application Infra Creation'){
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

                                        cd stackApp/iac/packer
                                        export app_ami_id=$(jq -r '.builds[-1].artifact_id' app_img_manifest.json | cut -d ":" -f2)
                                        echo "AMI_ID-APP-->>"$app_ami_id
                                        #export app_ami_id="ami-0e3c4f1e87ed81661"

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create application

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('Database Infra Creation'){
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

                                        cd stackApp/iac/packer
                                        export db_ami_id=$(jq -r '.builds[-1].artifact_id' db_img_manifest.json | cut -d ":" -f2)                                        
                                        echo "AMI_ID-DB-->>"$db_ami_id                                        
                                        #export db_ami_id="ami-0302e41d1e1b68dec"
                                        
                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create database

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('Caching Infra Creation'){
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

                                        cd stackApp/iac/packer                                       
                                        export cache_ami_id=$(jq -r '.builds[-1].artifact_id' cache_img_manifest.json | cut -d ":" -f2)                                        
                                        echo "AMI_ID-CACHE-->>"$cache_ami_id                                        
                                        #export cache_ami_id="ami-0e1727be7345e53ae"

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create cache

                                    '''   
                                }  
                        }     
                    }
            }
        }   
   
        stage('Messaging Infra Creation'){
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

                                        cd stackApp/iac/packer                                       
                                        export mesg_ami_id=$(jq -r '.builds[-1].artifact_id' message_img_manifest.json | cut -d ":" -f2)                                        
                                        echo "AMI_ID-MSG-->>"$export                                        
                                        #export mesg_ami_id="ami-033d5ea44c7d47269"

                                        rm -rf stackapppipelines
                                        git clone -b main https://github.com/ashwinbittu/stackapppipelines.git
                                        cd stackapppipelines; chmod 777 *.*;
                                        ./manageInfra.sh create message

                                    '''   
                                }  
                        }     
                    }
            }
        }             

        stage('Route53 Infra Creation'){
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
                                        ./manageInfra.sh create route53

                                    '''   
                                }  
                        }     
                    }
            }
        }

        stage('All Infra Destroy'){
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
                                        ./manageInfra.sh destroy route53
                                        ./manageInfra.sh destroy message
                                        ./manageInfra.sh destroy cache
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