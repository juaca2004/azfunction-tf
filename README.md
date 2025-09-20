Despliegue de una Azure Function con Terraform

A continuación detallo los pasos que seguí para clonar el repositorio, autenticarme en Azure y desplegar la función utilizando Terraform.

1. Autenticación en Azure

Primero inicié sesión en mi cuenta de Azure desde la línea de comandos con:

az login


Este comando abrió el navegador para autenticarme con mis credenciales de Azure. Una vez completada la autenticación, la terminal mostró la suscripción activa que se utilizará en el despliegue y ademas el ID que usare mas adelante.

2. Clonar el repositorio

Cloné el repositorio que contiene los archivos de configuración de Terraform:

git clone https://github.com/ChristianFlor/azfunction-tf.git


Después, ingresé al directorio clonado:

cd azfunction-tf

3. Inicializar Terraform

Inicialicé el proyecto para descargar los proveedores necesarios:

terraform init


Esto preparó el entorno de trabajo.

4. Formatear archivos de Terraform

A continuación, ejecuté el comando para dar formato a los archivos de configuración y mantener un estilo uniforme:

terraform fmt

5. Crear el plan de ejecución

Para visualizar los cambios que se aplicarían en Azure, generé el plan de ejecución:

terraform plan


Durante este proceso, Terraform solicitó el valor de la variable name_function, que en mi caso fue:

Name Function
  Enter a value: santiago

En el archivo provider especifiqué la suscripción de Azure que utilizo para el despliegue:

provider "azurerm" {
  features {}
  subscription_id = "***************************************"
}


6. Aplicar los cambios en Azure

Finalmente, apliqué la infraestructura definida en los archivos .tf:

terraform apply


Terraform volvió a solicitar el valor de name_function y, tras confirmar, creó todos los recursos: grupo de recursos, Storage Account, Service Plan, la Azure Function App y la función en JavaScript.


Función JavaScript: que responde a solicitudes HTTP y permite probar el servicio.

El archivo outputs.tf muestra la URL de invocación de la función una vez desplegada.
