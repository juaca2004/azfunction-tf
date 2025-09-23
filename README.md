### Deployment of an Azure Function with Terraform

Below are the steps I followed to clone the repository, authenticate with Azure, and deploy the function using Terraform.

---

#### 1. Azure Authentication

First, I signed in to my Azure account from the command line with:


az login


This command opened the browser to authenticate with my Azure credentials.
Once the authentication was completed, the terminal displayed the active subscription to be used for the deployment, along with the subscription ID that would be needed later.

---

#### 2. Clone the Repository

I cloned the repository containing the Terraform configuration files:


git clone https://github.com/ChristianFlor/azfunction-tf.git


Then, I entered the cloned directory:

cd azfunction-tf


---

#### 3. Initialize Terraform

I initialized the project to download the required providers:


terraform init


This prepared the working environment.

---

#### 4. Format Terraform Files

Next, I executed the command to format the configuration files and maintain a consistent style:


terraform fmt


---

#### 5. Create the Execution Plan

To preview the changes that would be applied in Azure, I generated the execution plan:


terraform plan


During this process, Terraform requested the value of the `name_function` variable, which in my case was:


Name Function
  Enter a value: santiago

In the provider file, I specified the Azure subscription to use for the deployment:

```hcl
provider "azurerm" {
  features {}
  subscription_id = "***************************************"
}
```

---

#### 6. Apply Changes to Azure

Finally, I applied the infrastructure defined in the `.tf` files:


terraform apply

<img width="1015" height="156" alt="image" src="https://github.com/user-attachments/assets/6d6d5961-beb7-456b-bab9-1fa86eeb02a8" />



Terraform again requested the `name_function` value and, after confirmation, created all the resources: resource group, Storage Account, Service Plan, the Azure Function App, and the JavaScript function.


The `outputs.tf` file displays the function’s invocation URL once the deployment is complete.

<img width="1037" height="150" alt="image" src="https://github.com/user-attachments/assets/076c16d5-5a9e-443f-ab51-40271cce8124" />

