# Utilizar la imagen base oficial de Jenkins con soporte de Docker
FROM jenkins/jenkins:lts-jdk11

# Instalar Docker CLI en el contenedor de Jenkins
USER root
RUN curl -sSL https://get.docker.com/ | sh

# Instalar dependencias de Python y PyInstaller
RUN apt-get update && apt-get install -y python3 python3-pip
RUN pip3 install pyinstaller

# Cambiar al usuario jenkins
USER jenkins
