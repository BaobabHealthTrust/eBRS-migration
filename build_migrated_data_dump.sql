#!/usr/bin/env bash
ENV=$1
NM=$2

echo "READING CONFIGURATIONS FOR METADATA"
USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['host']"`

echo $ENV
echo 'BUILDING DATA WITHOUT SCHEMA'
mysqldump -u $USERNAME -p$PASSWORD  --no-create-info --ignore-table=$DATABASE.sessions --ignore-table=$DATABASE.schema_migrations --ignore-table=$DATABASE.audit_trail_types --ignore-table=$DATABASE.birth_registration_type --ignore-table=$DATABASE.couchdb_sequence --ignore-table=$DATABASE.level_of_education  --ignore-table=$DATABASE.location --ignore-table=$DATABASE.location_tag --ignore-table=$DATABASE.location_tag_map --ignore-table=$DATABASE.mode_of_delivery --ignore-table=$DATABASE.person_attribute_types --ignore-table=$DATABASE.person_relationship_types --ignore-table=$DATABASE.person_identifier_types --ignore-table=$DATABASE.person_type_of_births --ignore-table=$DATABASE.person_type --ignore-table=$DATABASE.role --ignore-table=$DATABASE.statuses $DATABASE > $NM

DIR=`pwd`
echo "GENERATED DUMP FILE : $DIR/bare_data.sql"

