class ModeOfDelivery < ActiveRecord::Base
    self.table_name = :mode_of_delivery
    self.primary_key = :mode_of_delivery_id
    include EbrsMetadata

    has_many :person_birth_details, foreign_key: "mode_of_delivery_id"
end
