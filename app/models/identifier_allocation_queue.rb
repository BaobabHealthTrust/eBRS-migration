class IdentifierAllocationQueue < ActiveRecord::Base
    self.table_name = :identifier_allocation_queue
    self.primary_key = :identifier_allocation_queue_id

    belongs_to :core_person, foreign_key: "person_id"

    before_create :check_active_allocation_queue


  def check_active_allocation_queue
    last_run_time = File.mtime("#{Rails.root}/public/sentinel").to_time
    job_interval = 1.5
    now = Time.now

    if (now - last_run_time).to_f > job_interval
      AllocationQueue.perform_in(1)
    end
  end
    
end
