doc = PersonBirthDetail.find_by_document_id(ARGV[0]) rescue nil

if doc.present?
  doc.save
end