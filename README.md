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
`containers` - directory used to build container images

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

# Postgres operator interactions

After deployment, in namespace `pgo` will be deployed 2 pods:
 * `pgo-client` - client to interact with operator
 * `postgres-operator` - postgres operator application

To interact wtih operator should be used client application `pgo` available in `pgo-client` pod or can be used from local(with port forwarding)

```

pgo version

pgo create cluster -n pgo potato

pgo create cluster -n pgo tomato --replica-count=3 --password-superuser=potatoinc --pgbouncer --pgbouncer-replicas=3 --node-label pool=pg_pool

pgo -n pgo delete cluster potato666

```

# Postgres toolbox

Container running in same namespace with DB contaianing tools to interact with the db

Login into toolbox pod:
```
kubectl -n pgo exec -it deploy/postgres-toolbox -- bash
```

Access postgres toolbox
```
psql -h potato666-pgbouncer  -U potatouser potato666

pg_dump -h potato666-pgbouncer  -U potatouser potato666 > dump.sql

gsutil cp dump.sql gs://gke-postgres-backups

```


# References

https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest

https://github.com/terraform-google-modules/terraform-google-kubernetes-engine

https://github.com/CrunchyData/postgres-operator


