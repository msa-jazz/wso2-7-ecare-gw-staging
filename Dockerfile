FROM ghcr.io/zahidsultan1/wso2am-gw:4.5.0

# FROM docker.wso2.com/wso2am-universal-gw:4.5.0.0
# ARG USER=wso2carbon
# ARG USER_HOME=/home/${USER}
# ARG WSO2_SERVER_NAME=wso2am-universal-gw
# ARG WSO2_SERVER_VERSION=4.5.0
# ARG WSO2_SERVER=${WSO2_SERVER_NAME}-${WSO2_SERVER_VERSION}
# ARG WSO2_SERVER_HOME=${USER_HOME}/${WSO2_SERVER}

USER root
RUN rm -f /etc/localtime
RUN ln -sv /usr/share/zoneinfo/Asia/Karachi /etc/localtime
RUN echo "Asia/Karachi" > /etc/timezone
# COPY *.jar ${WSO2_SERVER_HOME}/repository/components/lib/
# RUN chown 802:802 ${WSO2_SERVER_HOME}/repository/components/lib/mysql-connector-java-8.0.29.jar
# Copy jdbc mysql driver
ADD --chown=wso2carbon:wso2 https://repo1.maven.org/maven2/mysql/mysql-connector-java/8.0.28/mysql-connector-java-8.0.28.jar ${WSO2_SERVER_HOME}/repository/components/lib

COPY deployment.toml ${WSO2_SERVER_HOME}/repository/conf/deployment.toml
RUN chown wso2carbon:wso2 ${WSO2_SERVER_HOME}/repository/conf/deployment.toml
RUN chmod 755 ${WSO2_SERVER_HOME}/repository/conf/deployment.toml

# COPY api-manager.sh ${WSO2_SERVER_HOME}/bin/
# RUN chown wso2carbon:wso2 ${WSO2_SERVER_HOME}/bin/gateway.sh
# RUN chmod 755 ${WSO2_SERVER_HOME}/bin/gateway.sh

# COPY extras/* ${WSO2_SERVER_HOME}/repository/resources/security/
# RUN chown -R 802:802 ${WSO2_SERVER_HOME}/repository/resources/security/
# RUN chmod -R 777 ${WSO2_SERVER_HOME}/repository/resources/security/

#ENTRYPOINT ["sh", "-c", "${WSO2_SERVER_HOME}/bin/gateway.sh"]
#USER wso2carbon
