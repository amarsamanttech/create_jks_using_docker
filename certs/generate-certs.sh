#!/bin/bash
# Generate certificate and key
openssl req -x509 -newkey rsa:2048 -keyout server.key -out server.crt -days 365 -nodes -subj "/CN=server.example.com"

# Remove existing truststore and keystore directories/files to avoid conflicts
rm -rf server.truststore.jks server.keystore.jks

# Import certificate into truststore
keytool -import -trustcacerts -alias server -file server.crt -keystore server.truststore.jks -storepass changeit -noprompt

# Convert to PKCS12 and create keystore
openssl pkcs12 -export -in server.crt -inkey server.key -out server.p12 -name server -passout pass:changeit
keytool -importkeystore -srckeystore server.p12 -srcstoretype PKCS12 -destkeystore server.keystore.jks -deststorepass changeit -srcstorepass changeit

# Remove any existing directories in output with the same names
for file in server.crt server.key server.truststore.jks server.keystore.jks; do
  [ -d "/certs/output/$file" ] && rm -rf "/certs/output/$file"
done

# Move files to output directory
mv server.* /certs/output/
echo "Certificates generated: server.crt, server.key, server.keystore.jks, server.truststore.jks"