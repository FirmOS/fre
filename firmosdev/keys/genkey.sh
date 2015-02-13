openssl genrsa -out firmos_signkey.pem 8192 # Generate a Key
openssl req -new -x509 -key firmos_signkey.pem -out firmos_signert.pem -days 36500 # Generate CERT
openssl x509 -in firmos_signcert.pem -pubkey -noout > firmos_signcert.pub # generate the public key from the cert