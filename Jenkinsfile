
pipeline {
    agent any

    environment {
        OCP_REGISTRY_HOST = "default-route-openshift-image-registry.apps.stgocpv1.jazz.com.pk"
        OCP_NAMESPACE     = "wso2"

        PIPELINE_APP_NAME = "${JOB_NAME}"
        IMAGE_TAG         = "${BUILD_NUMBER}"

        // Full image reference (registry/namespace/app:tag)
        FULL_IMAGE_NAME   = "${OCP_REGISTRY_HOST}/${OCP_NAMESPACE}/${PIPELINE_APP_NAME}:${IMAGE_TAG}"

        DOCKERFILE_PATH   = "Dockerfile"
        BUILD_CONTEXT     = "."
    }

    stages {
        stage('Build Container Image') {
            steps {
                sh """
                    podman build \
                      --tls-verify=false \
                      -f $DOCKERFILE_PATH \
                      -t $FULL_IMAGE_NAME \
                      $BUILD_CONTEXT
                """
            }
        }

        stage('Push Image to OpenShift Registry') {
            steps {
                withCredentials([string(credentialsId: 'ocp-registry-sa-token', variable: 'OCP_TOKEN')]) {
                    sh """
                        
                        echo \$OCP_TOKEN | podman login $OCP_REGISTRY_HOST --username serviceaccount --password-stdin --tls-verify=false
                        podman push --tls-verify=false $FULL_IMAGE_NAME
                    """
                }
            }
        }

        stage('Deploy Application to OpenShift') {
            steps {
                withCredentials([string(credentialsId: 'ocp-registry-sa-token', variable: 'OCP_TOKEN')]) {
                    sh """
                                                
                        echo \$OCP_TOKEN | oc login --token=\$OCP_TOKEN --server=https://api.stgocpv1.jazz.com.pk:6443 --insecure-skip-tls-verify=true
                        oc project $OCP_NAMESPACE
                        
                        sed "s|<WS02_APP_NAME>|${PIPELINE_APP_NAME}|g; s|<WS02_APP_TAG>|$IMAGE_TAG|g; \
                        s|default-route-openshift-image-registry.apps.stgocpv1.jazz.com.pk|image-registry.openshift-image-registry.svc:5000|g" \
                        deployment.yaml > deployment-ci.yaml

                        oc -n $OCP_NAMESPACE apply -f deployment-ci.yaml                        
                        oc -n $OCP_NAMESPACE annotate --overwrite deployment ${PIPELINE_APP_NAME}-deploy \
                          kubernetes.io/change-cause="Deployed build $BUILD_NUMBER" || true
                    """
                }
            }
        }

        stage('Cleanup') {
            steps {
                sh "podman rmi $FULL_IMAGE_NAME || true"
            }
        }
    }
}
