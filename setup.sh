#!/bin/bash

usage(){
  echo "Usage: $0 ENVIRONMENT"
  echo
  echo "ENVIRONMENT should be: development|test|production"

}

ENV=$1

if [ -z "$ENV" ]; then
  usage
  exit
fi

set -x # turns on stacktrace mode which gives useful debug information

echo "READING CONFIGIRATIONS"
USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['host']"`

UNDERSCORE='_'
COUCH_USER=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['username']"`
COUCH_PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['password']"`
PREFIX=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['prefix']"`
SUFFIX=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['suffix']"`
COUCH_HOST=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['host']"`
COUCH_PROTOCOL=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['protocol']"`
COUCH_PORT=`ruby -ryaml -e "puts YAML::load_file('config/couchdb.yml')['${ENV}']['port']"`
echo 'DROPING DATABASES'
bundle exec rake db:drop

#curl -X DELETE $COUCH_PROTOCOL://$COUCH_USER:$COUCH_PASSWORD@$COUCH_HOST:$COUCH_PORT/$PREFIX$UNDERSCORE$SUFFIX
#curl -X PUT $COUCH_PROTOCOL://$COUCH_USER:$COUCH_PASSWORD@$COUCH_HOST:$COUCH_PORT/$PREFIX$UNDERSCORE$SUFFIX

ESPROTOCOL=`ruby -ryaml -e "puts YAML::load_file('config/elasticsearchsetting.yml')['elasticsearch']['protocol']"`
ESHOST=`ruby -ryaml -e "puts YAML::load_file('config/elasticsearchsetting.yml')['elasticsearch']['host']"`
ESINDEX=`ruby -ryaml -e "puts YAML::load_file('config/elasticsearchsetting.yml')['elasticsearch']['index']"`
ESPORT=`ruby -ryaml -e "puts YAML::load_file('config/elasticsearchsetting.yml')['elasticsearch']['port']"`
ESTYPE=`ruby -ryaml -e "puts YAML::load_file('config/elasticsearchsetting.yml')['elasticsearch']['type']"`

echo 'DELETE elasticsearch index'
curl -XDELETE $ESPROTOCOL://$ESHOST:$ESPORT/$ESINDEX

echo 'SETTING UP NEW DATABASES'
export RAILS_ENV=$ENV

bundle exec rake db:create
bundle exec rake db:schema:load
bundle exec rake db:seed

./build_metadata.sh $ENV

rm public/sites/*.yml

echo "Done"

