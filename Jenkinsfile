node {
    def app

    def HOST_IP = ''

    withCredentials([string(credentialsId: 'dockerhost01', variable: 'DOCKERHOST01')]) {
        HOST_IP = DOCKERHOST01
    }

    stage('Clone repository') {
        /* Let's make sure we have the repository cloned to our workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        app = docker.build("jonasvinther/cd-for-web", "-f docker/images/node/Dockerfile .")
    }


    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */

        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub-credentials') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
        }
    }

    stage('Stop running container') {
        try {

            sshagent (credentials: ['ssh']) {
                sh 'ssh -o StrictHostKeyChecking=no root@${HOST_IP} docker rm -f nodeapp'
            }

        }
        catch(Exception e) {
            echo 'No running container found!'
        } 
    }

    stage('Deploy to production') {
        sshagent (credentials: ['ssh']) {
            sh 'ssh -o StrictHostKeyChecking=no root@${HOST_IP} docker pull jonasvinther/cd-for-web'
            sh 'ssh -o StrictHostKeyChecking=no root@${HOST_IP} docker run -d --name nodeapp --restart=always -p 3000:3000 jonasvinther/cd-for-web'
        }
    }
    
    stage('Delete working dir') {
        deleteDir()
    }
}
