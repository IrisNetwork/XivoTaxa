# Installation d'ElasticSearch
## Clef gpg
wget --no-check-certificate -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
### Depot
echo "deb http://packages.elasticsearch.org/elasticsearch/1.5/debian stable main" | sudo tee -a /etc/apt/sources.list
### Paquet
aptitude install elasticsearch openjdk-7-jre

## Les plugins
### Browser
/usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head
### Connecteur SGBD
/usr/share/elasticsearch/bin/plugin --install jdbc --url http://xbib.org/repository/org/xbib/elasticsearch/plugin/elasticsearch-river-jdbc/1.5.0.2/elasticsearch-river-jdbc-1.5.0.2-plugin.zip
### Connecteur PG
cd ~elasticsearch/plugins/jdbc
wget --no-check-certificate https://jdbc.postgresql.org/download/postgresql-9.1-903.jdbc4.jar
chmod 644 *

## Demarrage auto
update-rc.d elasticsearch defaults 95 10
## Et démarrage
/etc/init.d/elasticsearch start

# River
## La lancer
curl -XPUT 'localhost:9200/_river/my_jdbc_river/_meta' -d '{
    "type" : "jdbc",
    "interval" : "15s",
    "jdbc" : {
        "url" : "jdbc:postgresql://127.0.0.1:5432/asterisk",
        "user" : "asterisk",
        "password" : "proformatique",
        "sql" : [
            {
                "statement" : "SELECT date,source_exten,source_line_identity,destination_exten,destination_line_identity,EXTRACT(EPOCH FROM duration) AS duration,answered,valo FROM call_log WHERE stats = 1"
            },
            {
                "statement" : "UPDATE call_log SET stats = 2 where stats = 1",
                "write" : "true"
            }
        ]
    }
}'

## La couper
### curl -XDELETE 'localhost:9200/_river/my_jdbc_river/'

# Mise en place du cron de valorisation
cp TaxaXivo /etc/cron.hourly/
