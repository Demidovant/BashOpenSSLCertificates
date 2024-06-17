#!/bin/bash


function separator {
  echo "################################################"
}


function get_current_path {
  echo "Get current script path"
  separator

  current_script_full_path=$(readlink -f $0)
  #echo "$current_script_full_path"

  current_script_path=$(dirname $current_script_full_path)
  #echo "$current_script_path"
}


function read_config {
  echo "Reading configs"
  separator

  env_file="$current_script_path/env.ini"
  #echo "$env_file"

  ca_conf_file="$current_script_path/ca_config.ini"
  #echo "$ca_conf_file"

  certs_conf_file="$current_script_path/certs_config.ini"
  #echo "$certs_config.ini"
}


function edit_configs {
  echo "Do you want to edit config files?"
  read -p "Type: "yes". Default "no"  " answer

  if [ "$answer" = "yes" ]; then
    separator
    echo "Start editing config templates"
    nano "$current_script_path/env.ini"
    nano "$current_script_path/ca_config.ini"
    nano "$current_script_path/certs_config.ini"
  fi
}


function create_folders {
  echo "Creating folders"
  separator


  while IFS= read -r line; do
    if [[ $line =~ ^([^=]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      value="${BASH_REMATCH[2]}"

      if [[ $key = "ROOT_PATH" ]]; then
        ROOT_PATH=$value
        mkdir -p "$ROOT_PATH"
        echo "ROOT_PATH = $ROOT_PATH"
      fi

      if [[ $key = "CA_DIR" ]]; then
        CA_DIR=$ROOT_PATH$value
        mkdir -p "$CA_DIR"
        echo "CA_DIR = $CA_DIR"
      fi

      if [[ $key = "DATA_DIR" ]]; then
        DATA_DIR=$ROOT_PATH$value
        mkdir -p "$DATA_DIR"
        echo "DATA_DIR = $DATA_DIR"
        mkdir -p "$DATA_DIR/BACKUP"
      fi

      if [[ $key = "CERTS_DIR" ]]; then
        CERTS_DIR=$ROOT_PATH$value
        mkdir -p "$CERTS_DIR"
        echo "CERTS_DIR = $CERTS_DIR"
      fi

    fi
  done < "$env_file"
  separator
}


function print_tree {
  echo
  (tree $ROOT_PATH -h --dirsfirst)
  separator
}


function create_env {
  cat > "$current_script_path/env.ini" <<EOF
ROOT_PATH=$current_script_path/
CA_DIR=CA
DATA_DIR=CA_DB
CERTS_DIR=CERTS
EOF
  echo "Created $current_script_path/env.ini"
  separator
}


function create_ca_config {
  cat > "$current_script_path/ca_config.ini" <<EOF
[CA]
CA_CN=Custom_CA
CA_DAYS=3650
CA_COMPANY=Company Name
CA_DEPARTAMENT=IT
CA_COUNTRY=RU
CA_PROVINCE=Moscow
CA_CITY=Moscow
CA_EMAIL=ca@testmail.ru
CA_PFX_PASS=123
CA_KEY_BIT=2048
CA_HASH_ALG=sha256
SERIAL=01
EOF
  echo "Created $current_script_path/ca_config.ini"
  separator
}


function create_certs_config {
cat > "$current_script_path/certs_config.ini" <<EOF
[test-client]
CN=test-client.local
DAYS=1095
COMPANY=Company1
DEPARTAMENT=IT
COUNTRY=RU
PROVINCE=Moscow
CITY=Moscow
EMAIL=test-client@testmail.ru
PFX_PASS=12345!@#$)(
CERT_KEY_BIT=2048
COMMENT=OpenSSL generated certificate
DNS1=test-client
DNS2=test.local
IP1=1.1.1.1
IP2=10.9.8.7

[custom_cert]
CN=custom-client_cert.local.ru
DAYS=10000
COMPANY=Horns and hooves
DEPARTAMENT=Happy department
COUNTRY=RU
PROVINCE=Moscow
CITY=Moscow
EMAIL=custom-client_cert.local.ru@testmail.ru
PFX_PASS=sdfjbhjJKgsndfvkjsk76786&(9dskdfj)00
CERT_KEY_BIT=4096
COMMENT=CommentTextString
DNS1=custom-client_cert.local.com
DNS2=custom-client_cert.local
DNS3=custom-client_cert
DNS4=custom-client
DNS5=custom
DNS6=*.local.ru
DNS7=7.ru
DNS8=8.ru
DNS9=9.ru
DNS10=10.ru
IP1=1.1.1.1
IP2=10.9.8.7
IP3=1.1.1.2
IP4=10.9.8.3
IP5=1.1.1.4
IP6=10.9.8.5
IP7=1.1.1.6
IP8=10.9.8.255
IP9=1.1.1.254
IP10=10.9.8.253

[yac-vl-00255.company-net.ext]
CN=yac-vl-00255.company-net.ext
DAYS=730
COMPANY=Company-Net
DEPARTAMENT=Tech
COUNTRY=RU
PROVINCE=Moscow
CITY=Moscow
EMAIL=yac-vl-00255@company-net.ext
PFX_PASS=Hth-tkb_12345!@#$)(
CERT_KEY_BIT=1024
COMMENT=Server yac-vl-00255.company-net.ext
EOF

  echo "Created $current_script_path/certs_config.ini"
  separator
}


function create_config_templates {
  echo "Create config temlates and replace old if already exist? Are you sure?"
  read -p "Type: Yes, i am sure!   Or just press enter to edit config files  " answer

  if [ "$answer" = "Yes, i am sure!" ]; then
    separator
    echo "Default config templates will be created"
  else
    echo "Config templates not created"
    edit_configs
    return
  fi

  separator

#  echo "Choose what do you want:"
#  echo "1. Create template env.ini"
#  echo "2. Create template ca_config.ini"
#  echo "3. Create template certs_config.ini"
#  echo "4. Create 1 + 2"
#  echo "5. Create 1 + 3"
#  echo "6. Create 2 + 3"
#  echo "7. Create all 1 + 2 + 3"

#  read -p "Type number of your choice: " choice

choice=$(whiptail --title "Templates Management" --menu "Choose what do you want:" 15 80 8 \
  "1" "Create template env.ini" \
  "2" "Create template ca_config.ini" \
  "3" "Create template certs_config.ini" \
  "4" "Create 1 + 2" \
  "5" "Create 1 + 3" \
  "6" "Create 2 + 3" \
  "7" "Create 1 + 2 + 3 (All templates)" 3>&1 1>&2 2>&3)

echo "Your choice: $choice"

  separator

  case $choice in
    1) create_env ;;
    2) create_ca_config ;;
    3) create_certs_config ;;
    4) create_env && create_ca_config ;;
    5) create_env && create_certs_config ;;
    6) create_ca_config && create_certs_config ;;
    7) create_env && create_ca_config && create_certs_config ;;
  esac

  edit_configs
  separator
}


function backup_ca_folder {
  current_date=$(date +"%Y%m%d")
  current_time=$(date +"%H%M%S")
  cp -R "$CA_DIR" "$DATA_DIR/BACKUP/CA-${current_date}_${current_time}"
  cp "$ca_conf_file" "$DATA_DIR/BACKUP/CA-${current_date}_${current_time}"
  cp "$env_file" "$DATA_DIR/BACKUP/CA-${current_date}_${current_time}"
}


function backup_cert_folder {
  current_date=$(date +"%Y%m%d")
  current_time=$(date +"%H%M%S")
  cp -R "$CERTS_DIR/$SECTION_NAME" "$DATA_DIR/BACKUP/$SECTION_NAME-${current_date}_${current_time}"
  cp "$certs_conf_file" "$DATA_DIR/BACKUP/$SECTION_NAME-${current_date}_${current_time}"
}


function create_ca {
  echo "Create new CA and replace old if already exist? Are you sure?"
  read -p "Type: Yes, i am sure!  " answer

  if [ "$answer" = "Yes, i am sure!" ]; then
    separator
    echo "New CA will be created"
  else
    echo "CA not created"
    return
  fi

  separator
  echo "Start creating CA"
  separator
  read_config
  create_folders
  echo "Creating files"
  separator

  while IFS= read -r line; do
  if [[ $line =~ ^\[(.*)\]$ ]]; then
    section="${BASH_REMATCH[1]}"
    if [[ $section = "CA" ]]; then
      file="$CA_DIR/ca.cnf"
      if [ -f "$file" ]; then
        rm -rf "$file"
        echo Deleted "$file"
      fi
      touch "$file"
      echo Created "$file"
    fi
  separator
  fi

  if [[ $line =~ ^([^=]*)=(.*)$ ]]; then
    key="${BASH_REMATCH[1]}"
    value="${BASH_REMATCH[2]}"

    if [[ $key = "CA_CN" ]]; then
      CA_CN=$value
      echo "CA_CN = $CA_CN"
    fi

    if [[ $key = "CA_DAYS" ]]; then
      CA_DAYS=$value
      echo "CA_DAYS = $CA_DAYS"
    fi

    if [[ $key = "CA_COMPANY" ]]; then
      CA_COMPANY=$value
      echo "CA_COMPANY = $CA_COMPANY"
    fi

    if [[ $key = "CA_DEPARTAMENT" ]]; then
      CA_DEPARTAMENT=$value
      echo "CA_DEPARTAMENT = $CA_DEPARTAMENT"
    fi

    if [[ $key = "CA_COUNTRY" ]]; then
      CA_COUNTRY=$value
      echo "CA_COUNTRY = $CA_COUNTRY"
    fi

    if [[ $key = "CA_PROVINCE" ]]; then
      CA_PROVINCE=$value
      echo "CA_PROVINCE = $CA_PROVINCE"
    fi

    if [[ $key = "CA_CITY" ]]; then
      CA_CITY=$value
      echo "CA_CITY = $CA_CITY"
    fi

    if [[ $key = "CA_EMAIL" ]]; then
      CA_EMAIL=$value
      echo "CA_EMAIL = $CA_EMAIL"
    fi

    if [[ $key = "CA_PFX_PASS" ]]; then
      CA_PFX_PASS=$value
      echo "CA_PFX_PASS = $CA_PFX_PASS"
    fi

    if [[ $key = "CA_KEY_BIT" ]]; then
      CA_KEY_BIT=$value
      echo "CA_KEY_BIT = $CA_KEY_BIT"
    fi

    if [[ $key = "CA_HASH_ALG" ]]; then
      CA_HASH_ALG=$value
      echo "CA_HASH_ALG = $CA_HASH_ALG"
    fi

    if [[ $key = "SERIAL" ]]; then
      SERIAL=$value
      echo "SERIAL = $SERIAL"
    fi

  fi
  done < "$ca_conf_file"

  separator

  index_file="$DATA_DIR/index.txt"

  if [ -f "$index_file" ]; then
    rm -rf "$index_file"
    echo Deleted "$index_file"
  fi
  touch "$index_file"
  echo Created "$index_file"

  separator

  serial_file="$DATA_DIR/serial.txt"

  if [ -f "$serial_file" ]; then
    rm -rf "$serial_file"
    echo Deleted "$serial_file"
  fi
  touch "$serial_file"
  echo Created "$serial_file"
  echo $SERIAL > "$serial_file"

  separator

  cat > $CA_DIR/ca.cnf <<EOF
[ ca ]
default_ca    = CA_default      # The default ca section

[ CA_default ]

default_days     = $CA_DAYS     # How long to certify for
default_crl_days = 30           # How long before next CRL
default_md       = $CA_HASH_ALG       # Use public key default MD
preserve         = no           # Keep passed DN ordering
certificate      = $CA_DIR/ca.crt       # The CA certifcate
private_key      = $CA_DIR/ca.key       # The CA private key
new_certs_dir    = $CERTS_DIR            # Location for new certs after signing
database         = $index_file    # Database index file
serial           = $serial_file   # The current serial number

unique_subject = no  # Set to 'no' to allow creation of
                     # several certificates with same subject.

x509_extensions = ca_extensions # The extensions to add to the cert

email_in_dn     = yes            # Don't concat the email in the DN
copy_extensions = copy          # Required to copy SANs from CSR to cert

####################################################################
[ req ]
default_bits       = 2048
default_keyfile    = $CA_DIR/ca.key
distinguished_name = ca_distinguished_name
x509_extensions    = ca_extensions
string_mask        = utf8only

####################################################################
[ ca_distinguished_name ]
countryName         = Country Name (2 letter code)
countryName_default = $CA_COUNTRY

stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = $CA_PROVINCE

localityName                = Locality Name (eg, city)
localityName_default        = $CA_CITY

organizationName            = Organization Name (eg, company)
organizationName_default    = $CA_COMPANY

organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = $CA_DEPARTAMENT

commonName         = Common Name (e.g. server FQDN or YOUR name)
commonName_default = $CA_CN

emailAddress         = Email Address
emailAddress_default = $CA_EMAIL

####################################################################
[ ca_extensions ]

subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid:always, issuer
basicConstraints       = critical, CA:true
keyUsage               = keyCertSign, cRLSign

####################################################################
[ signing_policy ]
countryName            = optional
stateOrProvinceName    = optional
localityName           = optional
organizationName       = optional
organizationalUnitName = optional
commonName             = supplied
emailAddress           = optional

####################################################################
[ signing_req ]
subjectKeyIdentifier   = hash
authorityKeyIdentifier = keyid,issuer
basicConstraints       = CA:FALSE
keyUsage               = digitalSignature, keyEncipherment, dataEncipherment

EOF


  echo "Do you want to manually edit ca.cnf file ?"
  read -p "Type: "yes". Default "no"  " answer_edit_cnf

  if [ "$answer_edit_cnf" = "yes" ]; then
    nano "$CA_DIR/ca.cnf"
  fi


  separator
  echo "Start creating keys and certs"
  separator

  openssl genrsa -out $CA_DIR/ca.key $CA_KEY_BIT
  echo Created "$CA_DIR/ca.key"
  openssl req -new -x509 -days $CA_DAYS -key $CA_DIR/ca.key -out $CA_DIR/ca.crt -config $CA_DIR/ca.cnf -batch
  echo Created "$CA_DIR/ca.crt"
  openssl x509 -in $CA_DIR/ca.crt -outform PEM -out $CA_DIR/ca.pem
  openssl pkcs12 -export -out $CA_DIR/ca_with_pass.pfx -inkey $CA_DIR/ca.key -in $CA_DIR/ca.crt -password pass:$CA_PFX_PASS
  echo Created "$CA_DIR/ca_with_pass.pfx"

  pass_file="$CA_DIR/ca_pass.txt"
  if [ -f "$pass_file" ]; then
    rm -rf "$pass_file"
    echo Deleted "$pass_file"
  fi
  touch "$pass_file"
  echo Created "$pass_file"
  echo $CA_PFX_PASS > "$pass_file"

  openssl pkcs12 -export -out $CA_DIR/ca_wo_pass.pfx -inkey $CA_DIR/ca.key -in $CA_DIR/ca.crt -password pass:
  echo Created "$CA_DIR/ca_wo_pass.pfx"
  openssl x509 -inform PEM -in $CA_DIR/ca.crt -outform DER -out $CA_DIR/ca.cer
  echo Created "$CA_DIR/ca.cer"
  separator

  backup_ca_folder
}

function create_cnf {
 cat > $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf <<EOF
[ req ]
default_bits       = $CERT_KEY_BIT
default_keyfile    = $CERTS_DIR/$CN.key
distinguished_name = server_distinguished_name
req_extensions     = server_req_extensions
string_mask        = utf8only

####################################################################
[ server_distinguished_name ]
countryName         = Country Name (2 letter code)
countryName_default = $COUNTRY

stateOrProvinceName         = State or Province Name (full name)
stateOrProvinceName_default = $PROVINCE

localityName         = Locality Name (eg, city)
localityName_default = $CITY

organizationName            = Organization Name (eg, company)
organizationName_default    = $COMPANY

organizationalUnitName         = Organizational Unit (eg, division)
organizationalUnitName_default = $DEPARTAMENT

commonName           = Common Name (e.g. server FQDN or YOUR name)
commonName_default   = $CN

emailAddress         = Email Address
emailAddress_default = $EMAIL

####################################################################
[ server_req_extensions ]

subjectKeyIdentifier = hash
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, keyEncipherment, dataEncipherment
subjectAltName       = @alternate_names
nsComment            = $COMMENT
extendedKeyUsage     = serverAuth,clientAuth

####################################################################
[ alternate_names ]

DNS.0 = $CN
EOF

  if [[ $DNS1 != "" ]]; then
    echo "DNS.1 = $DNS1" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS2 != "" ]]; then
    echo "DNS.2 = $DNS2" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS3 != "" ]]; then
    echo "DNS.3 = $DNS3" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS4 != "" ]]; then
    echo "DNS.4 = $DNS4" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS5 != "" ]]; then
    echo "DNS.5 = $DNS5" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS6 != "" ]]; then
    echo "DNS.6 = $DNS6" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS7 != "" ]]; then
    echo "DNS.7 = $DNS7" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS8 != "" ]]; then
    echo "DNS.8 = $DNS8" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS9 != "" ]]; then
    echo "DNS.9 = $DNS9" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $DNS10 != "" ]]; then
    echo "DNS.10 = $DNS10" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP1 != "" ]]; then
    echo "IP.1 = $IP1" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP2 != "" ]]; then
    echo "IP.2 = $IP2" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP3 != "" ]]; then
    echo "IP.3 = $IP3" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP4 != "" ]]; then
    echo "IP.4 = $IP4" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP5 != "" ]]; then
    echo "IP.5 = $IP5" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP6 != "" ]]; then
    echo "IP.6 = $IP6" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP7 != "" ]]; then
    echo "IP.7 = $IP7" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP8 != "" ]]; then
    echo "IP.8 = $IP8" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP9 != "" ]]; then
    echo "IP.9 = $IP9" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi

  if [[ $IP10 != "" ]]; then
    echo "IP.10 = $IP10" >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf
  fi
}

function edit_cert_cnf {
  echo "Do you want to manually edit $SECTION_NAME.cnf file?"
  read -p "Type: "yes". Default "no"  " answer < /dev/tty
  if [ "$answer" = "yes" ]; then
    separator
    echo "Start editing cnf file"
    nano "$CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf" < /dev/tty
  fi
}

function create_certs_use_openssl {
SERIAL=`cat $DATA_DIR/serial.txt`
openssl req -batch -new -newkey rsa:$CERT_KEY_BIT -nodes -keyout $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.key -config $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cnf -out $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.csr
yes | openssl ca -days $DAYS -config $CA_DIR/ca.cnf -policy signing_policy -extensions signing_req -out $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.crt -infiles $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.csr
yes | mv $CERTS_DIR/$SERIAL.pem $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.pem
openssl pkcs12 -export -out $CERTS_DIR/$SECTION_NAME/$SECTION_NAME\_with_pass.pfx -inkey $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.key -in $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.crt -certfile $CA_DIR/ca.crt -password pass:$PFX_PASS
echo $PFX_PASS > $CERTS_DIR/$SECTION_NAME/$SECTION_NAME\_pass.txt
openssl pkcs12 -export -out $CERTS_DIR/$SECTION_NAME/$SECTION_NAME\_wo_pass.pfx -inkey $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.key -in $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.crt -certfile $CA_DIR/ca.crt -password pass:
openssl x509 -inform PEM -in $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.crt -outform DER -out $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.cer
openssl x509 -in $CA_DIR/ca.pem > $CERTS_DIR/$SECTION_NAME/$SECTION_NAME-bundle.pem
openssl x509 -in $CERTS_DIR/$SECTION_NAME/$SECTION_NAME.pem >> $CERTS_DIR/$SECTION_NAME/$SECTION_NAME-bundle.pem
}


function create_certs {
  echo "Create new server/client certs and replace old if already exist? Are you sure?"
  echo "Will be created all certs from certs_config.ini"
  echo "Old certs wil be overwrited"
  read -p "Type: Yes, i am sure!  " answer

  if [ "$answer" = "Yes, i am sure!" ]; then
    separator
    echo "New server/client certs will be created"
  else
    echo "Certs not created"
    return
  fi

  separator
  echo "Start creating server/client certs"
  separator
  read_config
  create_folders
  echo "Creating files"
  separator

  last_line=$(wc -l < $certs_conf_file)
  current_line=0


  while IFS= read -r line; do
    current_line=$(($current_line + 1))
    if [[ $line =~ ^\[(.*)\]$ ]]; then
      SECTION_NAME="${BASH_REMATCH[1]}"

      separator
      echo "$SECTION_NAME"
      separator
      echo "Create new server/client cert for $SECTION_NAME and replace old if already exist"
      rm -rf "$CERTS_DIR/$SECTION_NAME"
      echo "Remove if exists $CERTS_DIR/$SECTION_NAME"
      mkdir -p "$CERTS_DIR/$SECTION_NAME"
      echo "Create $CERTS_DIR/$SECTION_NAME"
      separator
    fi

    if [[ $line =~ ^([^=]*)=(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"
      value="${BASH_REMATCH[2]}"

      if [[ $key = "CN" ]]; then
        CN=$value
        echo "CN = $CN"
      fi

      if [[ $key = "DAYS" ]]; then
        DAYS=$value
        echo "DAYS = $DAYS"
      fi

      if [[ $key = "COMPANY" ]]; then
        COMPANY=$value
        echo "COMPANY = $COMPANY"
      fi

      if [[ $key = "DEPARTAMENT" ]]; then
        DEPARTAMENT=$value
        echo "DEPARTAMENT = $DEPARTAMENT"
      fi

      if [[ $key = "COUNTRY" ]]; then
        COUNTRY=$value
        echo "COUNTRY = $COUNTRY"
      fi

      if [[ $key = "PROVINCE" ]]; then
        PROVINCE=$value
        echo "PROVINCE = $PROVINCE"
      fi

      if [[ $key = "CITY" ]]; then
        CITY=$value
        echo "CITY = $CITY"
      fi

      if [[ $key = "EMAIL" ]]; then
        EMAIL=$value
        echo "EMAIL = $EMAIL"
      fi

      if [[ $key = "PFX_PASS" ]]; then
        PFX_PASS=$value
        echo "PFX_PASS = $PFX_PASS"
      fi

      if [[ $key = "CERT_KEY_BIT" ]]; then
        CERT_KEY_BIT=$value
        echo "CERT_KEY_BIT = $CERT_KEY_BIT"
      fi

      if [[ $key = "COMMENT" ]]; then
        COMMENT=$value
        echo "COMMENT = $COMMENT"
      fi

      if [[ $key = "DNS1" ]]; then
        DNS1=$value
        echo "DNS1 = $DNS1"
      fi

      if [[ $key = "DNS2" ]]; then
        DNS2=$value
        echo "DNS2 = $DNS2"
      fi

      if [[ $key = "DNS3" ]]; then
        DNS3=$value
        echo "DNS3 = $DNS3"
      fi

      if [[ $key = "DNS4" ]]; then
        DNS4=$value
        echo "DNS4 = $DNS4"
      fi

      if [[ $key = "DNS5" ]]; then
        DNS5=$value
        echo "DNS5 = $DNS5"
      fi

      if [[ $key = "DNS6" ]]; then
        DNS6=$value
        echo "DNS6 = $DNS6"
      fi

      if [[ $key = "DNS7" ]]; then
        DNS7=$value
        echo "DNS7 = $DNS7"
      fi

      if [[ $key = "DNS8" ]]; then
        DNS8=$value
        echo "DNS8 = $DNS8"
      fi

      if [[ $key = "DNS9" ]]; then
        DNS9=$value
        echo "DNS9 = $DNS9"
      fi

      if [[ $key = "DNS10" ]]; then
        DNS10=$value
        echo "DNS10 = $DNS10"
      fi

      if [[ $key = "IP1" ]]; then
        IP1=$value
        echo "IP1 = $IP1"
      fi

      if [[ $key = "IP2" ]]; then
        IP2=$value
        echo "IP2 = $IP2"
      fi

      if [[ $key = "IP3" ]]; then
        IP3=$value
        echo "IP3 = $IP3"
      fi

      if [[ $key = "IP4" ]]; then
        IP4=$value
        echo "IP4 = $IP4"
      fi

      if [[ $key = "IP5" ]]; then
        IP5=$value
        echo "IP5 = $IP5"
      fi

      if [[ $key = "IP6" ]]; then
        IP6=$value
        echo "IP6 = $IP6"
      fi

      if [[ $key = "IP7" ]]; then
        IP7=$value
        echo "IP7 = $IP7"
      fi

      if [[ $key = "IP8" ]]; then
        IP8=$value
        echo "IP8 = $IP8"
      fi

      if [[ $key = "IP9" ]]; then
        IP9=$value
        echo "IP9 = $IP9"
      fi

      if [[ $key = "IP10" ]]; then
        IP10=$value
        echo "IP10 = $IP10"
      fi

    fi

    if [[ $line =~ ^$ ]]; then
      separator
      create_cnf
      edit_cert_cnf
      create_certs_use_openssl
      backup_cert_folder
    fi

    if [[ $current_line = $last_line ]]; then
      separator
      create_cnf
      edit_cert_cnf
      create_certs_use_openssl
      backup_cert_folder
    fi

  done < "$certs_conf_file"

}


function create_bundle {

  echo Start create bundle certificate
  read -p "Type name of new file bundle-certificate (example bundle.pem): " bundle_file
  answer="yes"

  if [ -f "$bundle_file" ]; then
    rm "$bundle_file"
  fi

  echo
  echo @@@@@@@@@@@@@@@@@ REMINDER @@@@@@@@@@@@@@@@
  echo Order for adding certificates:
  echo
  echo ROOT certificate first!
  echo After - intermediate certificate if needed.
  echo And after - end client/server certificate.
  echo @@@@@@@@@@@@@@@@@ REMINDER @@@@@@@@@@@@@@@@
  echo
  
  whiptail --title "REMINDER" --msgbox " Order for adding certificates: \n \n ROOT certificate first! \n After - intermediate certificate if needed. \n And after - end client/server certificate." 15 80

  while [ "$answer" = "yes" ]; do

    read -p "Type the path to the certificate file that we will add to bundle : " cert_file

    if [ ! -f "$cert_file" ]; then
      echo "FILE $cert_file NOT FOUND. Try again."
      continue
    fi

    openssl x509 -in "$cert_file" >> "$bundle_file"

    read -p "Do you want to add once more certificate? (Type yes. Default no): " answer
  done

  echo "Bundle created: $bundle_file"
  echo

  cat $bundle_file
}


#####################################
#############        ################
#############  main  ################
#############        ################
#####################################

echo
echo "Start script"

get_current_path

#echo "Choose what do you want:"
#echo "1. Create config templates or edit configs"
#echo "2. Create CA"
#echo "3. Create Server/Client certificates"
#echo "4. Create 1 + 2"
#echo "5. Create 1 + 3"
#echo "6. Create 2 + 3"
#echo "7. Create all 1 + 2 + 3"
#echo "8. Create bundle certificate"

#read -p "Type number of your choice: " choice

choice=$(whiptail --title "Certificate Management" --menu "Choose what do you want:" 15 80 8 \
  "1" "Create config templates or edit configs" \
  "2" "Create CA" \
  "3" "Create Server/Client certificates" \
  "4" "Create 1 + 2 (Templates + CA)" \
  "5" "Create 1 + 3 (Templates + Server/Client certs)" \
  "6" "Create 2 + 3 (CA + Server/Client certs)" \
  "7" "Create 1 + 2 + 3 (Full setup)" \
  "8" "Create bundle certificate" 3>&1 1>&2 2>&3)
echo "Your choice: $choice"
separator

case $choice in
  1) create_config_templates ;;
  2) create_ca ;;
  3) create_certs ;;
  4) create_config_templates && create_ca ;;
  5) create_config_templates && create_certs ;;
  6) create_ca && create_certs ;;
  7) create_config_templates && create_ca && create_certs ;;
  8) create_bundle ;;
esac

separator
#print_tree


