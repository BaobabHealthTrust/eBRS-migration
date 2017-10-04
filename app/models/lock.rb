class Lock < CouchRest::Model::Base

  use_database "lock"
  property :user_id, String
  property :record_id, String
  property :locked, TrueClass, :default => true
  
  timestamps!
  
  before_save :set_user
  
  design do
    view :by__id
    view :by_user_id
    view :by_record_id
    view :by_user_id_and_record_id
    view :by_record_id_and_locked
    view :by_user_id_and_record_id_and_locked
    view :by_created_at
    view :by_updated_at
  end
  
  def set_user
    self.user_id = User.current_user.id rescue "admin"
  end
  
  def self.locked?(record_id)
    return Lock.by_record_id.key(record_id).first.locked rescue false 
  end
  
  def self.lock(record_id)
  
     lock =  Lock.by_record_id_and_locked.keys([[record_id, true]]).first rescue nil
     
     if lock.blank?
     		lock = Lock.by_user_id_and_record_id_and_locked.keys([[User.current_user.id, record_id, true]]).first rescue nil
     end
     
     locked = false
     
     if lock.blank?
       Lock.create(:record_id => record_id)
       locked = true
     end
    
    return lock
    
  end
  
  def self.locked_by_me?(record_id)
  	lock = Lock.by_user_id_and_record_id.keys([[User.current_user.id, record_id]]).first rescue nil
  	if lock.blank?
  		return false
  	else
  		return true
  	end
  end
  
  def self.release!(user_id = nil)
    if user_id.present?
   		 Lock.by_user_id.key(user_id).each { |lock| lock.destroy}
    else
       Lock.by__id.each { |lock| lock.destroy}
    end
  end
  
end
