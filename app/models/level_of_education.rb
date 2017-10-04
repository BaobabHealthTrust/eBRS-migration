class LevelOfEducation < ActiveRecord::Base
    self.table_name = :level_of_education
    self.primary_key = :level_of_education_id
    has_many :person_birth_details, foreign_key: "level_of_education_id"

    include EbrsMetadata

end
