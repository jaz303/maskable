class CreateMaskedObjects < ActiveRecord::Migration
  def self.up
    create_table :masked_objects do |t|
      t.references :masked_object, :polymorphic => true, :null => false
      t.references :mask_reason, :polymorphic => true, :null => false
      t.integer :depth, :null => false, :default => 0
      t.text :masked_attributes
      t.timestamps
    end
  end

  def self.down
    drop_table :masked_objects
  end
end
