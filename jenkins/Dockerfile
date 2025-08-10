FROM jenkins/jenkins:lts-jdk21
USER root
RUN apt-get update && apt-get upgrade -y
RUN curl -fsSL https://get.docker.com -o dockerinstall && chmod 755 dockerinstall && ./dockerinstall
USER jenkins