FROM jenkins/jenkins:lts-jdk11
USER root
RUN apt-get update && apt-get install -y lsb-release curl python3 python3-pip python3-venv
RUN curl -sSL https://get.docker.com/ | sh
RUN python3 -m venv /opt/pyenv
ENV PATH="/opt/pyenv/bin:$PATH"
RUN pip install --upgrade pip
RUN pip install pyinstaller
USER jenkins
