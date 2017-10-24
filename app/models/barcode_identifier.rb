class BarcodeIdentifier < ActiveRecord::Base
    self.table_name = :barcode_identifiers
    self.primary_key = :barcode_identifier_id
    belongs_to :person, foreign_key: "person_id"
    include EbrsAttribute
end
