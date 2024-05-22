		###########################################
		## Create CA & web cert script
		## August Winterstein. august@f5.com
		################################################
		#!/bin/sh
		############################
		## VARIABLES
		############################
		dir=.
		CA="localCA"
		webcert="webcert"
		##################
		## SCRIPT
		##################
		# Create dir and ssl_ext file
		mkdir $dir/$CA
		echo "[exts]" > $dir/$CA/ssl_ext
		echo "" >> $dir/$CA/ssl_ext
		echo "extendedKeyUsage = serverAuth, clientAuth, codeSigning, emailProtection" >> $dir/$CA/ssl_ext
		echo "basicConstraints = CA:FALSE" >> $dir/$CA/ssl_ext
		echo "keyUsage = nonRepudiation, digitalSignature, keyEncipherment" >> $dir/$CA/ssl_ext
		echo "subjectAltName = @alt_names" >> $dir/$CA/ssl_ext
		echo "[alt_names]" >> $dir/$CA/ssl_ext
		echo "DNS.1   = vpn.f5demo.com" >> $dir/$CA/ssl_ext
		echo "DNS.2   = vanilla.f5demo.com" >> $dir/$CA/ssl_ext
		echo "DNS.3   = bluesky.f5demo.com" >> $dir/$CA/ssl_ext
		echo "DNS.4   = www.f5demo.com" >> $dir/$CA/ssl_ext
		echo "DNS.5   = 10.1.10.101" >> $dir/$CA/ssl_ext
		echo "DNS.6 = dancayer-app1.canadacentral.cloudapp.azure.com" >> $dir/$CA/ssl_ext
		# Generate CA key, CA cert, webcert key, webcert CSR
		#openssl rand -out $dir/$CA/.rand 2048
		#openssl genrsa -rand $dir/$CA/.rand -out $dir/$CA/$CA.key 2048
		#clear
		echo ""
		echo "****************************************"
		echo "Enter information for the CA certificate"
		echo "****************************************"
		openssl req -x509 -new -key $dir/$CA/$CA.key -out $dir/$CA/$CA.crt -days 90 -config ./myssl.cnf
		#openssl genrsa -rand $dir/$CA/.rand -out $dir/$CA/$webcert.key 2048
        openssl genrsa -out $dir/$CA/$webcert.key 2048
		#clear
		echo ""
		echo "*********************************************"
		echo "Enter information for the webcert certificate"
		echo "*********************************************"
		openssl req -new -out $dir/$CA/$webcert.req -key $dir/$CA/$webcert.key -config ./myssl.cnf -reqexts req_ext 
		# Generate webcert cert
		openssl x509 -req -days 90 -in $dir/$CA/$webcert.req -CA $dir/$CA/$CA.crt -CAkey $dir/$CA/$CA.key -out $dir/$CA/$webcert.crt -set_serial 129 -sha256 -extensions exts -extfile $dir/$CA/ssl_ext 
		#openssl x509 -req -days 3650 -in /shared/localCA/webcert.req -CA /shared/localCA/localCA.crt -CAkey /shared/localCA/localCA.key -out /shared/localCA/webcert.crt -set_serial 129 -sha256 -extensions req_ext -extfile myssl.cnf 
		
		# # Install CA & webcert certs and keys
		# tmsh install sys crypto cert $CA-cert from-local-file $dir/$CA/$CA.crt
		# tmsh install sys crypto key $CA-key from-local-file $dir/$CA/$CA.key
		# tmsh install sys crypto cert $webcert-CA-cert from-local-file $dir/$CA/$webcert.crt
		# tmsh install sys crypto key $webcert-CA-key from-local-file $dir/$CA/$webcert.key
		# tmsh save sys config
		# Display CA cert for import to client machines
		#clear
		echo ""
		echo "**************************"
		echo "Copy the below CA certificate to a file and import to client Trusted Root Certification Authorities store"
		echo "**************************"
		echo ""
		cat $dir/$CA/$CA.crt
		echo ""