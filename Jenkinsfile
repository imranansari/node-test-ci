node('swarm'){

    checkout scm
    def container = docker.build('node-test')

        container.inside(){
            sh '''
                npm install
                npm run lint
                npm run test            
            '''
        }
    }
