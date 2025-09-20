Despliegue de una aplicación en Azure Kubernetes Service (AKS) con Terraform

A continuación detallo los pasos que seguí para preparar la imagen de la aplicación, autenticarme en Azure y desplegar la infraestructura de Kubernetes utilizando Terraform.

1. transformacion de a Express.js

convertimos la Azure Function en una aplicación Express.js, fue necesario porque Azure Functions no se ejecutan directamente en AKS.


2. Creacion del packege.json

Creamos el package.json donde va a contener las dependencias suficientes para que corra la aplicacion, en este caso express version 4.18.2

3. Creacion del la imagen

Al trabajar con kubernetes, nesecitamos la imagen de la aplicacion que vamos a correr, por lo tanto creamos un docker file, donde cargamos el package.json y ademas el index.js. Con esto creamos la imagen y la pusheamos a un respositorio publico, en este caso docker hub para la creacion del cluster.

4. Creacion del main.tf

El archivo main.tf define toda la infraestructura necesaria para desplegar una aplicación en Azure Kubernetes Service (AKS) y exponerla públicamente. A continuación se describe el rol de cada sección.

Proveedores (Providers)
  a. provider "azurerm"

  Configura la conexión con Microsoft Azure para que Terraform pueda crear y administrar recursos en la suscripción especificada.

  features {}: activa las funciones del proveedor sin parámetros adicionales.

  subscription_id: identifica de manera única la suscripción de Azure en la que se crearán los recursos.

  b. provider "kubernetes"

  Permite que Terraform gestione objetos dentro del clúster de Kubernetes recién creado.

  host y certificados (client_certificate, client_key, cluster_ca_certificate) se obtienen directamente del recurso azurerm_kubernetes_cluster.aks.

Grupo de Recursos
  resource "azurerm_resource_group" "rg"

  Crea un Resource Group en Azure que actúa como contenedor lógico para todos los recursos del proyecto.

  name y location se reciben como variables (var.resource_group_name y var.location), lo que permite reutilizar la configuración en distintas regiones o entornos.

Clúster de Kubernetes

  resource "azurerm_kubernetes_cluster" "aks"

  Define el clúster administrado de Kubernetes en Azure.
  Principales parámetros:

  name y resource_group_name: identifican el clúster y lo asocian al grupo de recursos creado previamente.

  dns_prefix: prefijo para el nombre DNS del clúster.

  default_node_pool: especifica el conjunto de nodos donde se ejecutarán los contenedores, incluyendo el tamaño de la máquina virtual (vm_size) y el número de nodos (node_count).

  identity: configura la identidad administrada del clúster para integrarse con otros servicios de Azure sin necesidad de credenciales manuales.

  tags: añade metadatos, en este caso para indicar que se trata de un entorno de prueba.

  Este recurso es la base de toda la infraestructura, ya que provee el entorno de ejecución para los contenedores.

Despliegue de la Aplicación

  resource "kubernetes_deployment" "app"

  Crea un Deployment dentro del clúster AKS para ejecutar la aplicación.
  Elementos destacados:

  metadata: define el nombre del deployment y la etiqueta app = "myapp", usada para identificar y agrupar recursos relacionados.

  replicas: número de instancias de la aplicación (1 en este caso).

  selector y template: establecen la plantilla de los pods, con las etiquetas necesarias para que el Service pueda localizarlos.

  container: indica el nombre del contenedor, la imagen alojada en Docker Hub (juaca2004/myapp:latest) y el puerto interno (3000) en el que escucha la aplicación.

  Este bloque asegura que Kubernetes mantenga al menos una réplica de la aplicación en ejecución.

Servicio de Exposición

  resource "kubernetes_service" "app_svc"

  Define un Service de tipo LoadBalancer para que la aplicación sea accesible desde Internet.

  metadata: establece el nombre del servicio y las etiquetas de identificación.

  selector: vincula el servicio a los pods del Deployment mediante la etiqueta app = "myapp".

  port: expone el puerto 80 hacia el exterior y redirige el tráfico al puerto 3000 de los contenedores.

  type = "LoadBalancer": solicita a Azure la creación de un balanceador de carga con una dirección IP pública.

  Gracias a este recurso, la aplicación puede recibir tráfico externo de forma automática y escalable.

5. Modificacion de variables

Para facilitar la reutilización y permitir cambios sin editar directamente el archivo principal, se definieron varias variables de entrada en un archivo variables.tf.
Cada variable tiene un tipo, un valor por defecto y, en algunos casos, una breve descripción.

location

    Tipo: string

    Valor por defecto: "westus3"

    Descripción: Indica la región de Azure donde se desplegarán todos los recursos.

    Uso: Permite cambiar la ubicación geográfica del despliegue (por ejemplo, "eastus") sin tocar el código del main.tf.

resource_group_name

    Tipo: string

    Valor por defecto: "aks-rg"

    Descripción: Nombre del grupo de recursos que contendrá el clúster AKS y los objetos asociados.

    Uso: Facilita identificar el entorno o proyecto en Azure.

aks_cluster_name

    Tipo: string

    Valor por defecto: "aks-cluster-2025"

    Descripción: Nombre asignado al clúster de Kubernetes (AKS).

    Uso: Se utiliza para personalizar el nombre del clúster según el entorno (desarrollo, pruebas, producción).

node_count

    Tipo: number

    Valor por defecto: 1

    Descripción: Número de nodos del pool principal en el clúster AKS.

    Uso: Ajustar el tamaño del clúster; por ejemplo, aumentar para soportar más carga.

node_vm_size

    Tipo: string

    Valor por defecto: "Standard_B2s"

    Descripción: Tipo de máquina virtual que se usará para los nodos del clúster.

    Uso: Permite elegir una especificación de hardware distinta (CPU, RAM) según el presupuesto o las necesidades de rendimiento.
