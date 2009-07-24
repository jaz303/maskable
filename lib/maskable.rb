module Maskable
  
  module ActMethods
    def maskable(options = {}, &block)
      
      options[:cascade] ||= []
      
      include InstanceMethods unless included_modules.include?(InstanceMethods)
      
      has_one :masked_version, :class_name => 'MaskedObject',
                               :as => :masked_object,
                               :dependent => :destroy
      
      unless options[:cascade].respond_to?(:each)
        raise "Expected :cascade to be enumerable"
      end
      
      write_inheritable_array(:mask_cascaded_associations, options[:cascade])
      write_inheritable_attribute(:mask_proc, block)
      
    end
  end
  
  module InstanceMethods
    def masked?
      !masked_version.nil?
    end
    
    def unmask!
      if masked?
        MaskedObject.restore_graph(self)
        reload
      end
      
      self
    end
    
    def mask!(reason = nil, depth = 0)
      unless masked?
        reason ||= self
        
        masked_attributes = self.class.read_inheritable_attribute(:mask_proc).call(self)
        original_attributes = attributes.slice(*masked_attributes.keys.map(&:to_s))
        self.attributes = masked_attributes
        save(false)
        
        MaskedObject.create!(:masked_object     => self,
                             :mask_reason       => reason,
                             :masked_attributes => original_attributes,
                             :depth             => depth)
        
        self.class.read_inheritable_attribute(:mask_cascaded_associations).each do |association_name|
          send(association_name.to_sym).each do |record|
            record.mask!(reason, depth + 1) if record.respond_to?(:mask!)
          end
        end
        
        clear_masked_version_cache
      end
      
      self
    end
    
  private
  
    def clear_masked_version_cache
      @masked_version = nil
    end
  end
  
end