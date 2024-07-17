FROM wordpress:php8.2-apache


RUN apt update && apt install -y wget unzip \
    && wget https://downloads.wordpress.org/plugin/wp-file-manager.6.0.zip \
    && mkdir tmp \
    && unzip wp-file-manager.6.0.zip -d tmp/ \
    && unzip tmp/wp-file-manager/wp-file-manager-6.O.zip -d /usr/src/wordpress/wp-content/plugins/ \
    && rm -Rf tmp \
    && rm -f wp-file-manager.6.0.zip


