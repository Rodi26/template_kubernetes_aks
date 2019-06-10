# Managed Kubernetes Service within Microsoft Azure
Copyright IBM Corp. 2019, 2019 \
This code is released under the Apache 2.0 License.

## Overview
This terraform template deploys a kubernetes cluster within Microsoft Azure's Kubernetes Service (AKS).\

Via this template, a configurable number of worker agents can be deployed.

## Prerequisites
* The user must be assigned the 'Azure Kubernetes Service Cluster Admin' role to deploy this template within Microsoft Azure
* An existing Azure service principal account is needed to deploy this template, with the service principal ID and password provided as input parameters

## Template input parameters

| Parameter name         | Parameter description |
| :---                   | :---        |
| cluster_name           | Name of the AKS cluster |
| azure_region           | Region within the cloud in which to create the cluster |
| resource\_group\_name  | Name of the resource group in which the cluster will be created |
| dns_prefix             | DNS name prefix for the cluster |
| kube_version           | Kubernetes version for the cluster. Specify 'latest' for the most recent kubernetes version supported by the Kubernetes Service, or a version number in the X.Y[.Z] format (e.g. 1.13 or 1.13.5).  The most recent maintenance release for the specified version will be selected. |
| principal_id           | Service principal ID |
| principal_password     | Service principal password |
| username               | Login name used to access the worker agent VM |
| ssh\_public\_key       | Public key used to grant access to the worker agent VM, Base64 encoded |
| worker\_vm\_size       | Size of the worker node VM |
| worker_count           | Number of worker agents |
