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

                        sh 'curl -H "X-JFrog-Art-Api:$ART_TOKEN" -T target/stackapp-v2.war "https://ashwinbittu.jfrog.io/artifactory/stackapp-repo/${BUILD_NUMBER}/stackapp-v2.war"'
                        

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
                            export AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION
                            aws sts get-caller-identity
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

                //checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[url: 'https://github.com/ashwinbittu/managecontinoinfra.git']]])
  
                sh """
                    git clone -b main https://github.com/ashwinbittu/managecontinoinfra.git
                    #cd managecontinoinfra
                    #./manageInfra.sh create
                """          

            }
        }




    }


}