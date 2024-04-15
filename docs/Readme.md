# Despliegue de Jenkins en Docker con Terraform

Este documento proporciona instrucciones detalladas sobre cómo replicar el despliegue de un servidor Jenkins en contenedores Docker gestionados mediante Terraform. Este entorno incluye todo lo necesario para ejecutar Jenkins y permite la integración con Docker in Docker (DinD) para la ejecución de contenedores dentro de los jobs de Jenkins.

## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado lo siguiente en tu máquina:
- Docker
- Docker Compose
- Terraform
- Tener Fork del repositorio de Github

## Paso 1: Creación de la Imagen de Jenkins Personalizada

### 1.1 Crear el Dockerfile

Crear un `Dockerfile` en la raíz del proyecto con el siguiente contenido:

```dockerfile
FROM jenkins/jenkins:lts-jdk11
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -sSL https://get.docker.com/ | sh
USER jenkins

### 1.2 Construir la Imagen

En la misma ubicación del Dockerfile, ejecuta el siguiente comando para construir la imagen:

-docker build -t mi-jenkins-python .

## Paso 2: Configuración de Terraform para el Despliegue de Contenedores

### 2.1 Crear Archivos de Configuración de Terraform

En un directorio llamado terraform, crea un archivo main.tf con la siguiente configuración:

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "jenkins_custom" {
  name = "mi-jenkins-python:latest"
}

resource "docker_container" "jenkins" {
  name  = "jenkins"
  image = docker_image.jenkins_custom.latest
  ports {
    internal = 8080
    external = 8080
  }
}

resource "docker_image" "dind" {
  name = "docker:dind"
}

resource "docker_container" "docker_dind" {
  name  = "dockerd"
  image = docker_image.dind.latest
  privileged = true
  ports {
    internal = 2375
    external = 2375
  }
}

### 2.2 Inicializar y Aplicar Terraform

Desde el directorio terraform, ejecuta:

-terraform init
-terraform apply

## Paso 4: Configuración del Pipeline en Jenkins

### 4.1 Crear un Nuevo Job

1. En el panel principal de Jenkins, haz clic en "Nueva Tarea".
2. Introduce un nombre para tu job, por ejemplo, "Python App Build".
3. Selecciona "Pipeline" y luego haz clic en "OK".

### 4.2 Configurar el Pipeline con SCM

1. Dentro de la configuración del job, desplázate hacia abajo hasta la sección "Pipeline".
2. En la sección "Definition", selecciona "Pipeline script from SCM".
3. Selecciona el tipo de SCM, por ejemplo, "Git".
4. En el campo "Repository URL", introduce la URL de tu repositorio forkeado, algo como `https://github.com/tu-usuario/simple-python-pyinstaller-app.git`.
5. Si tu repositorio es privado, necesitarás configurar las credenciales:
   - Haz clic en "Add" junto al campo de credenciales y elige "Jenkins".
   - Selecciona el tipo de credenciales adecuado, generalmente "Username with password".
   - Introduce tu nombre de usuario y contraseña de GitHub y guarda la configuración.
6. En el campo "Branch Specifier", deja `*/main` para utilizar la rama principal o ajusta según la rama que desees utilizar.
7. Si tienes un `Jenkinsfile` en tu repositorio, asegúrate de que la ruta en el campo "Script Path" sea correcta, generalmente es simplemente `Jenkinsfile` si el archivo está en la raíz del repositorio.

### 4.3 Ejecutar el Pipeline

1. Regresa al panel de control de Jenkins.
2. Haz clic en el nombre de tu job.
3. En el lado izquierdo, selecciona "Construir ahora" para iniciar la ejecución de tu pipeline.

### 4.4 Automatizar el Pipeline

Para que Jenkins verifique automáticamente los cambios en el repositorio y ejecute el pipeline:
1. Dentro de la configuración del job, busca la opción "Build Triggers".
2. Marca la casilla "Poll SCM" e introduce un cron como `H/5 * * * *` para verificar el repositorio cada 5 minutos.
3. Guarda los cambios.

