pipeline {
    agent { label 'workstation'}

    parameters {
        choice(name: 'ENV', choices: ['dev', 'prod'], description: 'choose Environment')
        choice(name: 'ACTION', choices: ['apply', 'destroy'], description: 'choose action')
    }

    stages {

        stage('Terraform plan') {
            steps {
                sh 'terraform init -backend-config=env-${ENV}/state.tfvars'
                sh 'terraform plan -var-file=env-${ENV}/input.tfvars'
            }
        }

        stage('Terraform apply') {
            steps {
                sh 'terraform ${ACTION} -var-file=env-${ENV}/input.tfvars -auto-approve'
            }
        }
    }
}