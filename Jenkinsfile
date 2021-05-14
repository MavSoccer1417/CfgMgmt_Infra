node  {

  def app
  stage('Clone Repository') {
    git clone 'https://github.com/MavSoccer1417/CfgMgmt_Code.git'
  }
  stage('Build with Maven') {
   	steps {               	 
      sh "mvn compile"   
      sh "mvn package"
    }     	 
  }  
   
  stage('Deploy with Ansible') {
  }
}
