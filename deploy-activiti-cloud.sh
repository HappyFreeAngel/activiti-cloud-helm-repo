#!/usr/bin/env bash
kubectl create namespace activiti-cloud

helm install --name activiti-cloud  --namespace=activiti-cloud   ./activiti-cloud-full-example --version 7.1.223 --set global.gateway.domain=10.6.10.11.nip.io --set activiti-cloud-identity.alfresco-identity-service.keycloak.postgresql.persistence.existingClaim="" --
set common.keycloak-host=10.6.10.11.nip.io