#!/bin/bash

echo "===================================================="
echo " DevOps Tools Interactive Installation Script"
echo " Java17 + Java21 + Git + Maven + Jenkins + Docker + SonarQube + Tomcat"
echo " DevOps Interactive Installation Script"
echo " Java17 + Java21 + Jenkins + Docker + SonarQube + Tomcat"
echo "===================================================="

# ------------------------------------------------
@@ -19,29 +19,13 @@ TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}"
TOMCAT_HOME="/opt/tomcat"

JAVA17_HOME="/usr/lib/jvm/java-17-amazon-corretto"
JAVA21_HOME="/usr/lib/jvm/java-21-amazon-corretto"

JAVA_STATUS="Skipped"
GIT_STATUS="Skipped"
MAVEN_STATUS="Skipped"

JENKINS_INSTALL_STATUS="Skipped"
JENKINS_START_STATUS="Skipped"

DOCKER_INSTALL_STATUS="Skipped"
DOCKER_START_STATUS="Skipped"

SONAR_INSTALL_STATUS="Skipped"
SONAR_START_STATUS="Skipped"

TOMCAT_INSTALL_STATUS="Skipped"
TOMCAT_START_STATUS="Skipped"
JAVA17_HOME="/usr/lib/jvm/java-17-amazon-corretto.x86_64"
JAVA21_HOME="/usr/lib/jvm/java-21-amazon-corretto.x86_64"

INSTALL_ALL="no"

# ------------------------------------------------
# Get EC2 Public IP
# Get Public IP
# ------------------------------------------------

TOKEN=$(curl -s -X PUT "http://169.254.169.254/latest/api/token" \
@@ -104,306 +88,200 @@ else

fi

echo "-------------------------------------------"

# ------------------------------------------------
# System Pre-check
# System Details
# ------------------------------------------------

echo "System Pre-check"
echo "-------------------------------------------"
echo ""
echo "============= SYSTEM DETAILS ============="

echo ""
echo "Memory:"
free -h

echo "-------------------------------------------"

echo ""
echo "Disk:"
df -h

echo "-------------------------------------------"

echo "CPU Count:"
echo ""
echo "CPU:"
nproc

echo "-------------------------------------------"
echo ""
echo "=========================================="

# ------------------------------------------------
# Increase /tmp Size
# ------------------------------------------------

echo "Increasing /tmp size..."

mount -o remount,size=2G /tmp 2>/dev/null

echo "-------------------------------------------"

# ------------------------------------------------
# Java Installation
# Required Packages
# ------------------------------------------------

if ask_install "Java 17 and Java 21"; then

    echo "Installing Java 17 and Java 21..."

    yum install java-17-amazon-corretto java-21-amazon-corretto -y
echo ""
echo "Installing required packages..."

    if [ $? -eq 0 ]; then
yum install -y \
wget \
curl \
git \
unzip \
tar \
lsof \
net-tools \
fontconfig \
ca-certificates

        JAVA_STATUS="Java 17 and Java 21 installed successfully"
update-ca-trust

        echo "$JAVA_STATUS"
# ------------------------------------------------
# Java Installation
# ------------------------------------------------

        echo "Java 17:"
        ${JAVA17_HOME}/bin/java -version
if ask_install "Java 17 and Java 21"; then

        echo ""
        echo "Java 21:"
        ${JAVA21_HOME}/bin/java -version
    echo ""
    echo "Installing Java 17 and Java 21 JDK..."

    else
    yum install -y \
    java-17-amazon-corretto-devel \
    java-21-amazon-corretto-devel

        JAVA_STATUS="Java installation failed"
    echo ""
    echo "Installed Java Directories:"
    ls -lrt /usr/lib/jvm/

        echo "$JAVA_STATUS"
    echo ""
    echo "Java 17 Version:"
    ${JAVA17_HOME}/bin/java -version

    fi
    echo ""
    echo "Java 21 Version:"
    ${JAVA21_HOME}/bin/java -version

else

echo "Skipping Java installation..."

fi

echo "-------------------------------------------"

# ------------------------------------------------
# Git Installation
# Maven Installation
# ------------------------------------------------

if ask_install "Git"; then

    echo "Installing Git..."

    yum install git -y

    if [ $? -eq 0 ]; then

        GIT_STATUS="Git installed successfully - Version: $(git --version | awk '{print $3}')"

        echo "$GIT_STATUS"
if ask_install "Maven"; then

    else
    echo ""
    echo "Installing Maven..."

        GIT_STATUS="Git installation failed"
    yum install maven -y

        echo "$GIT_STATUS"
    export JAVA_HOME=${JAVA17_HOME}
    export PATH=$JAVA_HOME/bin:$PATH

    fi
    echo ""
    echo "Maven Version:"
    mvn -version

else

    echo "Skipping Git installation..."
    echo "Skipping Maven installation..."

fi

echo "-------------------------------------------"

# ------------------------------------------------
# Maven Installation
# Docker Installation
# ------------------------------------------------

if ask_install "Maven"; then

    echo "Installing Maven..."

    yum install maven -y

    if [ $? -eq 0 ]; then

        MAVEN_STATUS="Maven installed successfully - Version: $(mvn -version | head -1 | awk '{print $3}')"
if ask_install "Docker"; then

        echo "$MAVEN_STATUS"
    echo ""
    echo "Installing Docker..."

    else
    yum install docker -y

        MAVEN_STATUS="Maven installation failed"
    systemctl enable docker
    systemctl restart docker

        echo "$MAVEN_STATUS"
    sleep 5

    fi
    echo ""
    docker --version

else

    echo "Skipping Maven installation..."
    echo "Skipping Docker installation..."

fi

echo "-------------------------------------------"

# ------------------------------------------------
# Required Packages
# ------------------------------------------------

echo "Installing required packages..."

yum install wget unzip tar curl net-tools lsof fontconfig ca-certificates -y

update-ca-trust

echo "-------------------------------------------"

# ------------------------------------------------
# Jenkins Installation
# ------------------------------------------------

if ask_install "Jenkins"; then

    echo "Removing old Jenkins..."
    echo ""
    echo "Installing Jenkins..."

systemctl stop jenkins 2>/dev/null
    systemctl disable jenkins 2>/dev/null

yum remove jenkins -y

rm -rf /var/lib/jenkins
rm -rf /etc/yum.repos.d/jenkins.repo

    echo "Configuring latest Jenkins repository..."

wget --no-check-certificate \
-O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

    echo "Installing latest Jenkins..."

yum install jenkins -y

    if [ $? -eq 0 ]; then

        echo "Configuring Jenkins to use Java 21..."

        sed -i '/^JENKINS_JAVA_CMD=/d' /etc/sysconfig/jenkins

        echo "JENKINS_JAVA_CMD=${JAVA21_HOME}/bin/java" >> /etc/sysconfig/jenkins

        export JAVA_HOME=${JAVA21_HOME}
        export PATH=$JAVA_HOME/bin:$PATH

        JENKINS_INSTALL_STATUS="Jenkins installed successfully"
    echo ""
    echo "Configuring Jenkins with Java 21..."

        echo "$JENKINS_INSTALL_STATUS"
    sed -i '/^JENKINS_JAVA_CMD=/d' /etc/sysconfig/jenkins

        systemctl daemon-reload
    echo "JENKINS_JAVA_CMD=${JAVA21_HOME}/bin/java" >> /etc/sysconfig/jenkins

        systemctl enable jenkins
        systemctl start jenkins
    systemctl daemon-reload

        echo "Waiting for Jenkins to start..."
    systemctl enable jenkins
    systemctl restart jenkins

        sleep 40
    echo ""
    echo "Waiting for Jenkins startup..."

        if systemctl is-active --quiet jenkins; then

            JENKINS_START_STATUS="Jenkins started successfully"

            echo "$JENKINS_START_STATUS"

        else

            JENKINS_START_STATUS="Jenkins failed to start"

            echo "$JENKINS_START_STATUS"

            journalctl -u jenkins -n 50 --no-pager

        fi

    else

        JENKINS_INSTALL_STATUS="Jenkins installation failed"

        echo "$JENKINS_INSTALL_STATUS"

    fi
    sleep 40

else

echo "Skipping Jenkins installation..."

fi

echo "-------------------------------------------"

# ------------------------------------------------
# Docker Installation
# ------------------------------------------------

if ask_install "Docker"; then

    echo "Installing Docker..."

    yum install docker -y

    if [ $? -eq 0 ]; then

        DOCKER_INSTALL_STATUS="Docker installed successfully - Version: $(docker --version | awk '{print $3}' | sed 's/,//')"

        echo "$DOCKER_INSTALL_STATUS"

        systemctl enable docker
        systemctl start docker

        sleep 5

        if systemctl is-active --quiet docker; then

            DOCKER_START_STATUS="Docker started successfully"

            echo "$DOCKER_START_STATUS"

        else

            DOCKER_START_STATUS="Docker failed to start"

            echo "$DOCKER_START_STATUS"

        fi

    else

        DOCKER_INSTALL_STATUS="Docker installation failed"

        echo "$DOCKER_INSTALL_STATUS"

    fi

else

    echo "Skipping Docker installation..."

fi

echo "-------------------------------------------"

# ------------------------------------------------
# SonarQube Installation
# ------------------------------------------------

if ask_install "SonarQube"; then

    echo ""
echo "Installing SonarQube..."

sysctl -w vm.max_map_count=262144
sysctl -w fs.file-max=65536

    grep -q "vm.max_map_count=262144" /etc/sysctl.conf || echo "vm.max_map_count=262144" >> /etc/sysctl.conf
    grep -q "fs.file-max=65536" /etc/sysctl.conf || echo "fs.file-max=65536" >> /etc/sysctl.conf
    grep -q "vm.max_map_count=262144" /etc/sysctl.conf || \
    echo "vm.max_map_count=262144" >> /etc/sysctl.conf

    grep -q "fs.file-max=65536" /etc/sysctl.conf || \
    echo "fs.file-max=65536" >> /etc/sysctl.conf

systemctl stop sonarqube 2>/dev/null
    systemctl disable sonarqube 2>/dev/null

rm -rf /opt/sonarqube*
rm -f /etc/systemd/system/sonarqube.service
@@ -421,93 +299,63 @@ if ask_install "SonarQube"; then
wget --no-check-certificate \
https://binaries.sonarsource.com/Distribution/sonarqube/${SONAR_ZIP}

    if [ -f "/opt/${SONAR_ZIP}" ]; then

        unzip -q ${SONAR_ZIP}

        ln -s ${SONAR_DIR} ${SONAR_LINK}

        chown -R sonar:sonar ${SONAR_DIR}
        chown -h sonar:sonar ${SONAR_LINK}

        echo "Configuring SonarQube to use Java 17..."
    unzip -q ${SONAR_ZIP}

        sed -i '/^#sonar.java.jdkHome=/d' ${SONAR_LINK}/conf/sonar.properties
    ln -s ${SONAR_DIR} ${SONAR_LINK}

        echo "sonar.java.jdkHome=${JAVA17_HOME}" >> ${SONAR_LINK}/conf/sonar.properties
    chown -R sonar:sonar ${SONAR_DIR}
    chown -h sonar:sonar ${SONAR_LINK}

        cat > /etc/systemd/system/sonarqube.service <<EOF
    cat > /etc/systemd/system/sonarqube.service <<EOF
[Unit]
Description=SonarQube service
After=network.target

[Service]
Type=forking

User=sonar
Group=sonar

Environment=JAVA_HOME=${JAVA17_HOME}
Environment=PATH=${JAVA17_HOME}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin

ExecStart=${SONAR_LINK}/bin/linux-x86-64/sonar.sh start
ExecStop=${SONAR_LINK}/bin/linux-x86-64/sonar.sh stop
Restart=on-failure

Restart=always

LimitNOFILE=65536
LimitNPROC=4096

[Install]
WantedBy=multi-user.target
EOF

        systemctl daemon-reload

        systemctl enable sonarqube
        systemctl start sonarqube

        echo "Waiting for SonarQube to start..."

        sleep 40
    systemctl daemon-reload

        if systemctl is-active --quiet sonarqube; then
    systemctl enable sonarqube
    systemctl restart sonarqube

            SONAR_INSTALL_STATUS="SonarQube installed successfully - Version: ${SONAR_VERSION}"
    echo ""
    echo "Waiting for SonarQube startup..."

            SONAR_START_STATUS="SonarQube started successfully"

            echo "$SONAR_INSTALL_STATUS"
            echo "$SONAR_START_STATUS"

        else

            SONAR_START_STATUS="SonarQube failed to start"

            echo "$SONAR_START_STATUS"

            journalctl -u sonarqube -n 50 --no-pager

        fi

    else

        SONAR_INSTALL_STATUS="SonarQube download failed"

        echo "$SONAR_INSTALL_STATUS"

    fi
    sleep 50

else

echo "Skipping SonarQube installation..."

fi

echo "-------------------------------------------"

# ------------------------------------------------
# Tomcat Installation
# ------------------------------------------------

if ask_install "Apache Tomcat"; then
if ask_install "Tomcat"; then

    echo "Installing Apache Tomcat..."
    echo ""
    echo "Installing Tomcat..."

rm -rf ${TOMCAT_HOME}
rm -f /opt/${TOMCAT_FILE}
@@ -516,17 +364,19 @@ if ask_install "Apache Tomcat"; then

wget --no-check-certificate ${TOMCAT_URL}

    if [ -f "/opt/${TOMCAT_FILE}" ]; then
    tar -xvzf ${TOMCAT_FILE}

        tar -xvzf ${TOMCAT_FILE}
    mv apache-tomcat-${TOMCAT_VERSION} tomcat

        mv apache-tomcat-${TOMCAT_VERSION} tomcat
    chmod -R 755 ${TOMCAT_HOME}

        chmod +x ${TOMCAT_HOME}/bin/*.sh
    chmod +x ${TOMCAT_HOME}/bin/*.sh

        echo "Configuring Tomcat users..."
    # ------------------------------------------------
    # Configure Tomcat Users
    # ------------------------------------------------

        cat > ${TOMCAT_HOME}/conf/tomcat-users.xml <<EOF
    cat > ${TOMCAT_HOME}/conf/tomcat-users.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>

<tomcat-users>
@@ -543,146 +393,265 @@ if ask_install "Apache Tomcat"; then
</tomcat-users>
EOF

        echo "Updating manager context.xml..."
    # ------------------------------------------------
    # Remove Tomcat Manager Restriction
    # ------------------------------------------------

        cat > ${TOMCAT_HOME}/webapps/manager/META-INF/context.xml <<EOF
    cat > ${TOMCAT_HOME}/webapps/manager/META-INF/context.xml <<EOF
<Context antiResourceLocking="false" privileged="true">

<!--
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
       allow="127\\.\d+\\.\d+\\.\d+|::1|0:0:0:0:0:0:0:1" />
allow="127\\.\d+\\.\d+\\.\d+|::1|0:0:0:0:0:0:0:1" />
-->

<Manager sessionAttributeValueClassNameFilter="java\\.lang\\.(?:Boolean|Integer|Long|Number|String)|org\\.apache\\.catalina\\.filters\\.CsrfPreventionFilter\\$LruCache(?:\\$1)?|java\\.util\\.(?:Linked)?HashMap"/>

</Context>
EOF

        echo "Changing Tomcat port to 9090..."
    # ------------------------------------------------
    # Change Tomcat Port
    # ------------------------------------------------

    sed -i 's/port="8080"/port="9090"/g' \
    ${TOMCAT_HOME}/conf/server.xml

    # ------------------------------------------------
    # Configure Java 17 for Tomcat
    # ------------------------------------------------

    cat > ${TOMCAT_HOME}/bin/setenv.sh <<EOF
export JAVA_HOME=${JAVA17_HOME}
export PATH=\$JAVA_HOME/bin:\$PATH
EOF

    chmod +x ${TOMCAT_HOME}/bin/setenv.sh

        sed -i 's/port="8080"/port="9090"/g' ${TOMCAT_HOME}/conf/server.xml
    # ------------------------------------------------
    # Kill Existing Process
    # ------------------------------------------------

        PORT_9090_PID=$(lsof -ti:9090)
    pkill -f tomcat

        if [ ! -z "$PORT_9090_PID" ]; then
    sleep 5

            echo "Port 9090 already in use. Killing process..."
    PORT_9090_PID=$(lsof -ti:9090)

            kill -9 $PORT_9090_PID
    if [ ! -z "$PORT_9090_PID" ]; then

        fi
        kill -9 $PORT_9090_PID

        echo "Starting Tomcat..."
    fi

        export JAVA_HOME=${JAVA17_HOME}
        export PATH=$JAVA_HOME/bin:$PATH
    # ------------------------------------------------
    # Start Tomcat
    # ------------------------------------------------

        ${TOMCAT_HOME}/bin/startup.sh
    echo ""
    echo "Starting Tomcat..."

        sleep 10
    export JAVA_HOME=${JAVA17_HOME}
    export PATH=$JAVA_HOME/bin:$PATH

        if lsof -i:9090 >/dev/null 2>&1; then
    echo "JAVA_HOME=$JAVA_HOME"

            TOMCAT_INSTALL_STATUS="Tomcat installed successfully - Version: ${TOMCAT_VERSION}"
    ${TOMCAT_HOME}/bin/startup.sh

            TOMCAT_START_STATUS="Tomcat started successfully"
    sleep 15

            echo "$TOMCAT_INSTALL_STATUS"
            echo "$TOMCAT_START_STATUS"
else

        else
    echo "Skipping Tomcat installation..."

            TOMCAT_START_STATUS="Tomcat failed to start"
fi

            echo "$TOMCAT_START_STATUS"
# ------------------------------------------------
# Final Status
# ------------------------------------------------

            tail -50 ${TOMCAT_HOME}/logs/catalina.out
echo ""
echo "============= FINAL STATUS ============="

        fi
echo ""
echo "EC2 Public IP: ${PUBLIC_IP}"

    else
# ------------------------------------------------
# Java Status
# ------------------------------------------------

        TOMCAT_INSTALL_STATUS="Tomcat download failed"
echo ""

        echo "$TOMCAT_INSTALL_STATUS"
if [ -d "${JAVA17_HOME}" ]; then

    fi
    echo "Java 17 installed successfully"

else

    echo "Skipping Tomcat installation..."
    echo "Java 17 not installed"

fi

echo "-------------------------------------------"
echo "Installation Completed"
echo "-------------------------------------------"
if [ -d "${JAVA21_HOME}" ]; then

    echo "Java 21 installed successfully"

else

    echo "Java 21 not installed"

fi

# ------------------------------------------------
# Maven Status
# ------------------------------------------------

echo ""
echo "============= FINAL STATUS ============="

echo "EC2 Public IP: ${PUBLIC_IP}"
if command -v mvn >/dev/null 2>&1; then

    export JAVA_HOME=${JAVA17_HOME}
    export PATH=$JAVA_HOME/bin:$PATH

    echo "Maven installed successfully"

    mvn -version | head -1

else

    echo "Maven not installed"

fi

# ------------------------------------------------
# Docker Status
# ------------------------------------------------

echo ""
echo "$JAVA_STATUS"
echo "$GIT_STATUS"
echo "$MAVEN_STATUS"

if systemctl is-active --quiet docker; then

    echo "Docker started successfully"

    docker --version

else

    echo "Docker failed to start"

fi

# ------------------------------------------------
# Jenkins Status
# ------------------------------------------------

echo ""
echo "$JENKINS_INSTALL_STATUS"
echo "$JENKINS_START_STATUS"

if [[ "$JENKINS_START_STATUS" == "Jenkins started successfully" ]]; then
if systemctl is-active --quiet jenkins; then

    echo "Jenkins started successfully"

echo "Jenkins URL: http://${PUBLIC_IP}:8080"

    echo "Jenkins password location: /var/lib/jenkins/secrets/initialAdminPassword"
    echo "Jenkins password location:"
    echo "/var/lib/jenkins/secrets/initialAdminPassword"

    echo "Jenkins Java Version: Java 21"
    echo "Jenkins Java: Java 21"

else

    echo "Jenkins failed to start"

    journalctl -u jenkins -n 30 --no-pager

fi

echo ""
echo "$DOCKER_INSTALL_STATUS"
echo "$DOCKER_START_STATUS"
# ------------------------------------------------
# SonarQube Status
# ------------------------------------------------

echo ""
echo "$SONAR_INSTALL_STATUS"
echo "$SONAR_START_STATUS"

if [[ "$SONAR_START_STATUS" == "SonarQube started successfully" ]]; then
if systemctl is-active --quiet sonarqube; then

    echo "SonarQube started successfully"

echo "SonarQube URL: http://${PUBLIC_IP}:9000"

echo "SonarQube username: admin"

echo "SonarQube password: admin"

    echo "SonarQube Java Version: Java 17"
    echo "SonarQube Java: Java 17"

else

    echo "SonarQube failed to start"

    echo ""
    echo "SonarQube Logs:"

    tail -50 ${SONAR_LINK}/logs/sonar.log 2>/dev/null

fi

# ------------------------------------------------
# Tomcat Status
# ------------------------------------------------

echo ""
echo "$TOMCAT_INSTALL_STATUS"
echo "$TOMCAT_START_STATUS"

if [[ "$TOMCAT_START_STATUS" == "Tomcat started successfully" ]]; then
if lsof -i:9090 >/dev/null 2>&1; then

    echo "Tomcat started successfully"

echo "Tomcat URL: http://${PUBLIC_IP}:9090"

    echo "Tomcat Manager URL: http://${PUBLIC_IP}:9090/manager/html"
    echo "Tomcat Manager URL:"
    echo "http://${PUBLIC_IP}:9090/manager/html"

echo "Tomcat Username: admin"

echo "Tomcat Password: admin"

    echo "Tomcat Installed Path: /opt/tomcat"
    echo "Tomcat Java: Java 17"

else

    echo "Tomcat failed to start"

    echo ""

    if [ -f "${TOMCAT_HOME}/logs/catalina.out" ]; then

        echo "Tomcat Logs:"
        tail -100 ${TOMCAT_HOME}/logs/catalina.out

    else

        echo "Tomcat log file not found"

    fi

fi

# ------------------------------------------------
# Port Status
# ------------------------------------------------

echo ""
echo "============= PORT STATUS ============="

ss -tulnp | grep -E '8080|9000|9090'

# ------------------------------------------------
# Resource Summary
# ------------------------------------------------

echo ""
echo "============= SYSTEM RESOURCE SUMMARY ============="

echo ""
echo "Memory:"
free -h

@@ -694,4 +663,5 @@ echo ""
echo "CPU Count:"
nproc

echo "===================================================="
echo ""
echo "==================================================="
