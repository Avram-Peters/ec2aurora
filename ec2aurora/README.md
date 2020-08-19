# EC2 and Aurora-PostgreSQL

## Description

## Requirements
- Terraform 11.0
- AWS Bucket for environment state
- Available VPC within the deployment region

```AWS Configuration``` 
> AWS Configuration is set up to run from the commandline, and secret, secret-key, and default region must be set. If 
>using the default profile, no changes are required. If using a different profile, edit the aws provider in main.tf



## Variables
* ```tags``` _required_ Tags for each deployment.
  * ```Purpose``` _required_ This tag will populate the Resource Group, and is the only required tag
  * json

* ```application_name``` _required_ The name of the applications being deployed. This is used throughout the deployment.

* ```vpc_cidr``` _required_ This is required to deploy the VPC. A default limit of 5 VPC's per region exists, so an open 
 region block is required. This region is broken into multiple subnets, so ensure that there are plenty of available IP
 addresses (::/24-27 recommended)

* ```environment``` _default=dev_ Environment of the deployment. Sets the path for the backend config files, scripts, and 
 secrets

* ```debug``` _default=false_ Sets debug state for access control.

*  ```cluster-instance-count``` _default=1_ This sets the number of HA instances wtihin the aurora cluster

* ```aurora-instance-class``` _required_ This sets the instance class for the nodes in the Aurora cluster. 

* ```db-engine``` _default=aurora-postgres_ This sets the engine for the database

* ```db-engine-version``` _default=11.6_ The version of the aurora database.

* ```ec2-instance``` _default=t2.micro_ sets the size of the ec2 instance


