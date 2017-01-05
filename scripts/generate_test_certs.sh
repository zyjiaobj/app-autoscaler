#!/bin/sh

set -ex

# Install certstrap
go get -v github.com/square/certstrap

# Place keys and certificates here
depot_path="../test-certs"
rm -rf ${depot_path}
mkdir -p ${depot_path}


# CA to distribute to autoscaler certs
certstrap --depot-path ${depot_path} init --passphrase '' --common-name autoscalerCA
mv -f ${depot_path}/autoscalerCA.crt ${depot_path}/autoscaler-ca.crt
mv -f ${depot_path}/autoscalerCA.key ${depot_path}/autoscaler-ca.key

# metricscollector certificate
certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name metricscollector --ip 127.0.0.1
certstrap --depot-path ${depot_path} sign metricscollector --CA autoscaler-ca

# scalingengine certificate
certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name scalingengine --ip 127.0.0.1
certstrap --depot-path ${depot_path} sign scalingengine --CA autoscaler-ca

# eventgenerator certificate
certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name eventgenerator --ip 127.0.0.1
certstrap --depot-path ${depot_path} sign eventgenerator --CA autoscaler-ca

# servicebroker certificate
certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name servicebroker --ip 127.0.0.1
certstrap --depot-path ${depot_path} sign servicebroker --CA autoscaler-ca

# api certificate
certstrap --depot-path ${depot_path} request-cert --passphrase '' --common-name api --ip 127.0.0.1
certstrap --depot-path ${depot_path} sign api --CA autoscaler-ca

# scheduler certificate
certstrap --depot-path ${depot_path} request-cert --passphrase 123456 --common-name scheduler --ip 127.0.0.1
certstrap --depot-path ${depot_path} sign scheduler --CA autoscaler-ca
openssl pkcs12 -export -in ${depot_path}/scheduler.crt -inkey ${depot_path}/scheduler.key -out ${depot_path}/scheduler.p12 -name scheduler -passin pass:123456 -password pass:123456
keytool -importkeystore -srckeystore ${depot_path}/scheduler.p12 -srcstoretype PKCS12 -destkeystore ${depot_path}/scheduler.jks -deststoretype JKS -alias scheduler -srcstorepass "123456" -storepass "123456"