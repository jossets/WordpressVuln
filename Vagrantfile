Vagrant.configure("2") do |config|
  config.vm.box = "generic/alpine318"
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.define "mywpsitecat"
  config.vm.hostname = "mywpsitecat"
  config.vm.provider :virtualbox do |vb|
        vb.name = "mywpsitecat"
  end
	
  # Files 
  config.vm.provision "file", source: "nginx_http_d_default.conf", destination: "/home/vagrant/nginx_http_d_default.conf" 
  config.vm.provision "file", source: "php_fpm_www.conf", destination: "/home/vagrant/php_fpm_www.conf"
  config.vm.provision "file", source: "profile_php8.sh", destination: "/home/vagrant/profile_php8.sh"
  
  # Install
  DB_PASSWD_ROOT="password"
  DB_PASSWD_WP="password"
  WP_ADMIN_LOGIN="wordpress_admin"
  WP_ADMIN_PASSWD="myadminpassword"
  WP_TITLE="My little kitty site" 
  WP_URL="http://localhost:8080"
  config.vm.provision "shell", path: "install_service.sh", args: ["-dbpr", DB_PASSWD_ROOT, "-dbpw", DB_PASSWD_WP, "-wpl", WP_ADMIN_LOGIN, "-wpp", WP_ADMIN_PASSWD, "-wt", WP_TITLE, "-wu", WP_URL, "-v"]
end