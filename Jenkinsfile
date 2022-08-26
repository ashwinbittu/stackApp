pipeline {

	agent any

    environment {
        appname = "stackapp"
        appver = "v2"
        artficatreporeg = "https://ashwinbittu.jfrog.io"
        artifactrepo = "/stackapp-repo"
        artifactrepocreds = 'jfrog-artifact-saas'
    }

    stages{

        stage('BUILD'){
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
                steps {
                    sh 'mvn test'
                }
            }

        stage('INTEGRATION TEST'){
                steps {
                    sh 'mvn verify -DskipUnitTests'
                }
            }

        stage ('CODE ANALYSIS WITH CHECKSTYLE'){
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
        */

        stage ('Upload App Image to Artifactory') {
                    steps {
                        withCredentials([string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 
                            sh """

                            curl -H "X-JFrog-Art-Api:$ART_TOKEN" -T target/stackapp-v2.war "https://ashwinbittu.jfrog.io/artifactory/stackapp-repo/${BUILD_NUMBER}/stackapp-v2.war"
                            
                            """
                        }
                        /*rtUpload (
                            buildName: JOB_NAME,
                            buildNumber: BUILD_NUMBER,
                            serverId: '${artifactrepocreds}', // Obtain an Artifactory server instance, defined in Jenkins --> Manage:
                            spec: '''{
                                    "files": [
                                        {
                                        "pattern": "target/${appname}-${appver}.war",
                                        "target": "/${artifactrepo}/${BUILD_NUMBER}",
                                        "recursive": "false"
                                        }
                                    ]
                                }'''
                        )*/
                    }
        }

       

	    stage ('Backing AMI')  {
	        steps {
                //checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/ashwinbittu/stackApp-infra.git']]])
                
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: "awscreds",
                    accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                    secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh """
                            #export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
                            aws sts get-caller-identity
                            rm -rf stackApp-infra
                            git clone -b main https://github.com/ashwinbittu/stackApp-infra.git
                            cd stackApp-infra/packer
                            
                            #App/Tomcat Bake
                            /usr/bin/packer validate -var 'app_layer=app' -var 'source_ami=$ubuntu_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$app_userscript' -var 'ssh_username=$ubuntu_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$ubuntu_owners' template.ubuntu.pkr.hcl
                            #/usr/bin/packer build    -var 'app_layer=app' -var 'source_ami=$ubuntu_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$app_userscript' -var 'ssh_username=$ubuntu_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$ubuntu_owners' template.ubuntu.pkr.hcl 
                            
                            
                            #DB/Maria-MySQL Bake
                            /usr/bin/packer validate -var 'app_layer=db' -var 'source_ami=$amzlnx_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$db_userscript' -var 'ssh_username=$amzlnx_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$amzlnx_owners' template.amzlinx2.pkr.hcl
                            #/usr/bin/packer build    -var 'app_layer=db' -var 'source_ami=$amzlnx_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$db_userscript' -var 'ssh_username=$amzlnx_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$amzlnx_owners' template.amzlinx2.pkr.hcl 


                            #Cache/Memcache
                            /usr/bin/packer validate -var 'app_layer=cache' -var 'source_ami=$amzlnx_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$cache_userscript' -var 'ssh_username=$amzlnx_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$amzlnx_owners' template.amzlinx2.pkr.hcl
                            #/usr/bin/packer build    -var 'app_layer=cache' -var 'source_ami=$amzlnx_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$cache_userscript' -var 'ssh_username=$amzlnx_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$amzlnx_owners' template.amzlinx2.pkr.hcl 


                            #Mesg/Rabbitmq
                            /usr/bin/packer validate -var 'app_layer=msg' -var 'source_ami=$ubuntu_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$msg_userscript' -var 'ssh_username=$ubuntu_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$ubuntu_owners' template.ubuntu.pkr.hcl
                            #/usr/bin/packer build    -var 'app_layer=msg' -var 'source_ami=$ubuntu_source_ami' -var 'app_name=$app_name_stackapp' -var 'instance_type=$instance_type' -var 'script=$msg_userscript' -var 'ssh_username=$ubuntu_ssh_username' -var 'root-device-type=$ubuntu_root_device_type' -var 'virtualization-type=$ubuntu_virtualization_type' -var 'owners=$ubuntu_owners' template.ubuntu.pkr.hcl 

                        

                        """
                    
                    }
            }
         
        }

        stage('Infra Creation Using Terraform'){
            steps {
                    withCredentials([[ $class: 'AmazonWebServicesCredentialsBinding', credentialsId: "awscreds", accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY' ]]) {

                        withCredentials([usernamePassword(credentialsId: 'github-person-acces-token', usernameVariable: 'REPO_API_USER', passwordVariable: 'REPO_API_TOKEN')]){

                                withCredentials([string(credentialsId: 'TFE_TOKEN', variable: 'TFE_TOKEN'), string(credentialsId: 'ART_TOKEN', variable: 'ART_TOKEN')]){ 

                                    sh """
                                        
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
                                        ./manageInfra.sh create

                                    """   
                                }  
                        }     
                    }
            }
        }




    }


}