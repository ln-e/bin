#!/bin/bash
#automatic hosts generation

SITES_DIR=/Users/ibodnar/Sites/
APACHE_CONFIG_DIR=/private/etc/apache2/other/
DOMAIN_SUFFIX=dev
APACHECTL=`which apachectl`

[ -f ~/.makeapachehosts ] && . ~/.makeapachehosts

NEED_RESTART=0

sites=`find ${SITES_DIR} -name "*.$DOMAIN_SUFFIX"`

for site in ${sites}; do
  name=`basename ${site}`
  domain=`echo ${name} | cut -d. -f1`
  USE_PARSER=0

  # detect parser usage
  if [ -f "${site}/auto.p" ] || [ -f "${site}/www/auto.p" ] || [ -f "${site}/web/auto.p" ]; then
    USE_PARSER=1
  fi

  path="$site"
  # fix for hosts with root in web or www
  if [ -f "${site}/web/index.php" ] || [ -f "${site}/web/app.php" ] || [ -f "${site}/web/auto.p" ]; then
	  path="${site}/web"
  fi
  if [ -f "${site}/www/index.php" ] || [ -f "${site}/www/app.dev" ] || [ -f "${site}/www/auto.p" ]; then
    path="${site}/www"
  fi

  [ "`echo ${name} | cut -c1-4`" == "www." ] && alias=`echo ${name} | cut -c5-` || alias=""

  cat /etc/hosts | grep "$name" > /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
  echo "127.0.0.1 $name $alias" >> /etc/hosts
  fi;

  ls -la ${APACHE_CONFIG_DIR} | grep "$name.conf" > /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    config_file="${APACHE_CONFIG_DIR}${name}.conf"
    echo "<VirtualHost *:80>" > ${config_file}
    if [ ${USE_PARSER} -eq 1 ]; then
      echo "" >> ${config_file}
      echo "  Action parser3-handler /cgi-bin/${domain}.parser/parser3" >> ${config_file}
      echo "  AddHandler parser3-handler html" >> ${config_file}
      echo "" >> ${config_file}
    fi

    echo "  DocumentRoot $path/" >> ${config_file}
    echo "  ServerName $name" >> ${config_file}
    
    if [ "$alias" != "" ]; then
      echo "  ServerAlias $alias" >> ${config_file}
    fi

    echo "</VirtualHost>" >> ${config_file}
    NEED_RESTART=1
  fi
done;

sites=`find ${APACHE_CONFIG_DIR} -name "*.$DOMAIN_SUFFIX.conf"`

for site in ${sites}; do
  name=`basename ${site} | cut -d. -f1`
  name=${name}.dev

  ls -la ${SITES_DIR} | grep "$name" > /dev/null 2>&1
  if [ ! $? -eq 0 ]; then
    cat /etc/hosts | grep "$name" > /dev/null 2>&1
      if [ $? -eq 0 ]; then
        cat /etc/hosts | grep -v "$name" > /etc/hosts2
        mv /etc/hosts2 /etc/hosts
      fi;
    rm -f ${APACHE_CONFIG_DIR}${name}.conf
    NEED_RESTART=1
  fi
done;


[ ${NEED_RESTART} -eq 1 ] && ${APACHECTL} restart
