pipeline {
    agent any

    environment {
        OCP_NAMESPACE = "test-attendance"
        APP_NAME      = "frontend-app"
        IMAGE_TAG     = "latest"
        OCP_NAME      = "https://api.cluster-9wl8l.dynamic.redhatworkshops.io:6443"
        OCP_TOKEN    = "sha256~9r6JsDXJQxL8ZoVUTXcRIXYbkjyH1xfHA7ZR7FfLhg8"
        HELM_CHART_PATH = "helm-chart/"
        IMAGE_REPO = "image-registry.openshift-image-registry.svc:5000/${OCP_NAMESPACE}/${APP_NAME}"
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Login to OpenShift') {
            steps {
                sh """
                oc login --token=${OCP_TOKEN} --server=${OCP_NAME} --insecure-skip-tls-verify=true
                if ! oc get project ${OCP_NAMESPACE} >/dev/null 2>&1; then
                    oc new-project ${OCP_NAMESPACE} --description="Project for ${APP_NAME}"
                fi
                oc project ${OCP_NAMESPACE}
                """
            }
        }

        stage('Start OpenShift Build') {
            steps {
                script {
                    sh """
                    if oc get bc ${APP_NAME} >/dev/null 2>&1; then
                        oc start-build ${APP_NAME} --from-dir=. --wait --follow
                    else
                        oc new-build --name=${APP_NAME} --binary --strategy=docker
                        oc start-build ${APP_NAME} --from-dir=. --wait --follow
                    fi
                    """
                }
            }
        }

        stage('install Helm') {
            steps {
                script {
                    sh """
                    if ! command -v helm &> /dev/null; then
                        curl -sSL https://get.helm.sh/helm-v3.14.4-linux-amd64.tar.gz -o helm.tar.gz
                        tar -zxvf helm.tar.gz
                        mv linux-amd64/helm ./helm
                        chmod +x ./helm
                        export PATH=\$PATH:\$(pwd)
                    else
                        echo "Helm is already installed"
                    fi
                    ./helm version
                    """
                }
            }
        }

        stage('Deploy Helm') {
            steps {
                script {
                    sh """
                    ./helm lint ./helm-chart
                    ./helm upgrade --install ${APP_NAME} ./helm-chart \
                        --namespace ${OCP_NAMESPACE} \
                        --create-namespace \
                        --set image.repository=${IMAGE_REPO} \
                        --set image.tag=${IMAGE_TAG}
                    ./helm template ${APP_NAME} ./helm-chart --namespace ${OCP_NAMESPACE} \
                        --set image.repository=${IMAGE_REPO} \
                        --set image.tag=${IMAGE_TAG} > rendered.yaml
                    cat rendered.yaml
                    oc apply -f rendered.yaml -n ${OCP_NAMESPACE}
                    """
                }
            }
        }

        stage('Deploy to OpenShift') {
            steps {
                script {
                    sh """
                    oc rollout restart deployment ${APP_NAME} -n ${OCP_NAMESPACE}
                    """
                }
            }
        }
    }
}
