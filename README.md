# Demo project for GKE + Postgres deployment

# Tech stack

* GCP
* Terraform
* Docker
* kubectl
* helm
* PGO - CrunchyData postgres operator 

# Structure

`*.tf` - terraform files for GKE deployment
`charts` - directory with helm charts used in installation
`docker` - directory used to build container images

# Deployment steps

Initialize terraform
```
terraform init
```

Apply changes
```
terraform plan

terraform apply
```

Destroy environment
```
terraform destroy
```

# References

https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest

https://github.com/terraform-google-modules/terraform-google-kubernetes-engine

https://github.com/CrunchyData/postgres-operator


