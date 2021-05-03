# Demo project for GKE + Postgres deployment

# Tech stack

* GCP
* Terraform
* Docker
* kubectl
* helm
* PGO - CrunchyData postgres operator 

# Repository structure

`*.tf` - terraform files for GKE deployment
`charts` - directory with helm charts used in installation
`containers` - directory used to build container images
`scripts` - scripts used in environment provisioning

# Workflows

## Prerequisites

* GCP account + project

* gcloud, kubectl and helm installed

* gcloud initialized and set to GCP project

* Envrionmen variable `GOOGLE_APPLICATION_CREDENTIALS` pointing to service account credentials file

* Service account with role `roles/container.admin`

## Deployment


Initialize terraform providers
```
terraform init
```
Environment deployment

```
terraform plan

terraform apply
```
## Accesing postgresql

Postgresql will be deployed in namespace `pgo`, through `pgo-client` pod can be accessed postgres operator,
through `postgres-toolbox` interaction with postgres can be done.


## Postgres operator interactions

Through `pgo-client` can be obtained information about postgres cluster, deployed new clusters, scaled environments etc.

To interact wtih operator should be used client application `pgo` on pod or can be used from local(with port forwarding)

```
kubectl -n pgo exec -it deploy/pgo-client -- bash

```

Example commands:
```
pgo version

pgo -n pgo  show cluster potato666

pgo  -n pgo create cluster tomato123

pgo -n pgo delete cluster potato123

```

https://access.crunchydata.com/documentation/postgres-operator/4.6.2/pgo-client/common-tasks/

## Postgres toolbox

Through `postgres-toolbox` can be accessed postgresql db, can be executed on demand DB backup, 
also can be executed manually restore of previous dump since pod has activated GCP service account.

Login into toolbox pod:
```
kubectl -n pgo exec -it deploy/postgres-toolbox -- bash
```

Access postgres toolbox
```
psql -h potato666-pgbouncer  -U potatouser potato666

\dt
select * from sales;
select * from customers;


Manual backup operations:
pg_dump -h potato666-pgbouncer  -U potatouser potato666 > dump.sql
gsutil cp dump.sql gs://gke-postgres-backups

```

## Backup

Backups automatically executed by a K8S cron job with configurable schedule, 
db backups are automatically uploaded to created GS bucket, name containing year month day hour minute second of backup.

Manual backups are also supported, by executing `/scripts/backup-db.sh` on toolbox container.

Note: backups are done in SQL format

## Destroy

Commands to be executed in order to destroy created environment

```
terraform destroy
```

# Future work

Since this is a POC project, it has room for improvements in directions like:
 * Terraform modular split:
   * modules(s) for platform like GKE, GS setup;
   * module(s) for applications deployment;
 * GKE deployment: 
   * deploy in non default networks;
   * deploy private nodes without external IPs;
 * Security improvements:
   * special service account for accessing GCP resources from pods;
   * run as non root in containers;
   * special role only with requied permissions;
 * Postgres Operator:
   * definition of requests and limits for pods(now disabled to save costs)
   * configurable db storage size;
   * backup/restore using PGO client;
   * configuration of TLS connectivity;
   * usage of monitoring metrics;
   * automated scripts for DB restore;
 * Postgres DB setup:
   * usage of external DB dump(current approach will be limited to 1MB which can fit in ConfigMap);
   * db metrics exporting;


# References

https://registry.terraform.io/modules/terraform-google-modules/kubernetes-engine/google/latest

https://github.com/terraform-google-modules/terraform-google-kubernetes-engine

https://github.com/CrunchyData/postgres-operator

# License

Only for reference, distribution and/or commercial usage not allowed

