class CouchdbSequence < ActiveRecord::Base
    self.table_name = :couchdb_sequence
    self.primary_key = :couchdb_sequence_id
    include EbrsMetadata
end
