#!/usr/bin/env bash
ENV=$1

echo "READING CONFIGURATIONS FOR METADATA"
USERNAME=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['username']"`
PASSWORD=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['password']"`
DATABASE=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['database']"`
HOST=`ruby -ryaml -e "puts YAML::load_file('config/database.yml')['${ENV}']['host']"`

echo $ENV
echo 'BUILDING METADATA'
mysqldump -u $USERNAME -p$PASSWORD $DATABASE --tables audit_trail_types birth_registration_type level_of_education  location location_tag location_tag_map mode_of_delivery person_attribute_types person_relationship_types person_identifier_types person_type_of_births person_type role statuses > metadata.sql

DIR=`pwd`
echo "GENERATED METADATA FILE : $DIR/metadata.sql"

