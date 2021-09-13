#!/bin/bash

set -e

if [ -z "$CODE_SIGNING_CERT" ]; then exit 0; else echo "code signing certificate is available"; fi
if [ -z "$CODE_SIGNING_CERT_PW" ]; then exit 0; else echo "code signing certificate password is available"; fi

echo ${CODE_SIGNING_CERT} | base64 -d > code-signing-cert.pfx

ls -lah code-signing-cert.pfx

apk add openssl
openssl pkcs12 -nocerts -nodes -out private_key -in code-signing-cert.pfx -passin env:CODE_SIGNING_CERT_PW
openssl pkcs12 -clcerts -nokeys -nodes -out certificate -in code-signing-cert.pfx -passin env:CODE_SIGNING_CERT_PW
openssl pkcs12 -cacerts -nokeys -nodes -out ca_certs -in code-signing-cert.pfx -passin env:CODE_SIGNING_CERT_PW

ls -lah ca_certs certificate private_key

echo "this is a test" > test.blob

# https://github.com/qnap-dev/qdk2/blob/474bb4039b189dc19c92c90d399898cbe4ea8a28/QDK_2.x/bin/qbuild#L1662-L1664
openssl cms -sign -in test.blob -binary -nodetach -out test.msg \
    -signer certificate -inkey private_key \
    -certfile ca_certs

cat test.msg

# https://github.com/qnap-dev/qdk2/blob/474bb4039b189dc19c92c90d399898cbe4ea8a28/QDK_2.x/bin/qbuild#L1809-L1810
openssl cms -verify -purpose any -CApath /etc/ssl/certs/ -in test.msg > verify_dgst_file
cat verify_dgst_file

# our actual codepath does the signing slightly different than the example above:
# https://github.com/qnap-dev/qdk2/blob/f21df9a6e4edc261a817e2fa2e32f0b7c9d4c12f/QDK_2.x/bin/qbuild#L976-L977
# it doesn't use -certfile ca_certs - which will lead to verification failures...
# therefore we need to apply a patch -> see fix_offline_signing.diff
