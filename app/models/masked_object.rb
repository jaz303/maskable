class MaskedObject < ActiveRecord::Base
  
  belongs_to :masked_object, :polymorphic => true
  validates_presence_of :masked_object_id
  validates_uniqueness_of :masked_object_id, :scope => :masked_object_type
  
  belongs_to :mask_reason, :polymorphic => true
  validates_presence_of :mask_reason_id
  
  serialize :masked_attributes, Hash
  
  validates_numericality_of :depth
  
  def self.restore_graph(object)
    find(:all, :conditions => {
      :mask_reason_type => object.class.to_s,
      :mask_reason_id => object.id },
      :order => 'depth ASC'
    ).each(&:restore!)
  end
  
  def restore!
    masked_object.attributes = masked_attributes
    masked_object.save(false)
    destroy
  end
  
end
