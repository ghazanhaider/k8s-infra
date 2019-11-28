# Terraform AKS Kubernetes build cluster

Terraform script to build a Kubernetes cluster

## Features

* Create an ACR (Azure Container Registry) to facilitate image uploading
* Use a loadbalancer (Basic)
* The credentials input file "terraform.tfvars.json" can be the output of "az aks get-credentials", the same keys are used as variables

## How to use

### Use terraform to create the cluster

```
az login
az ad sp create-for-rbac --name AKSDemoSP > terraform.tfvars.json
terraform apply
```

The above commands can be used even if the SP already exists, it will change the credentials


Next, login into ACR so that the docker command can be used against ACR

### Build a docker container from code and test locally

```
az acr login --name ghaideraksdemoregistry
```

The ACR name must be globally unique, and should be the same name that went into the Terraform scripts
In this example we test with a test docker image (can be any image)

```
git clone git@github.com:ghazanhaider/hello-world.git
cd hello-world
```

Build it
```
docker build -t helloworld .
```

Test it
```
docker run --name hello -d -p 80:80 helloworld

# Test using your favorite browser
lynx http://localhost
```

Clean up
```
docker kill hello
docker rm hello
docker image rm helloworld nginx
```


### Upload this image to ACR

```
az acr login --name ghaideraksdemoregistry
docker tag helloworld ghaideraksdemoregistry.azurecr.io/demo/helloworld
docker push ghaideraksdemoregistry.azurecr.io/demo/helloworld
```

Apparently *docker login* can work too but we will need to create another SP for it. This is easier.


### Deploy this application's service and deployment using the manifest file

```
kubectl apply -f ./manifest.yaml
kubectl get svc
```

This might take 5 minutes, mostly due to loadbalancer and public IP being provisioned.
You can check repeatedly using:
```
watch kubectl get svc
```
... until the External IP is visible.

Test in your favorite browser.


### Cleanup

```
terraform destroy
```
