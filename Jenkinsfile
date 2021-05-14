pipeline  {

  agent any
  stages {
    stage('Clone Repository') {
      steps {
        git clone 'https://github.com/MavSoccer1417/CfgMgmt_Code.git'
      }
    }
    stage('Build with Maven') {
   	  steps {               	 
        sh "mvn compile"   
        sh "mvn package"
      }     	 
    }  
   
    stage('Deploy with Ansible') {
      steps {
        echo "Deploy"
      }
    }
  }
}
