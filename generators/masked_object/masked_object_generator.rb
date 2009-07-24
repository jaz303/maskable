class MaskedObjectGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'created_masked_objects.rb',
                           'db/migrate',
                           :migration_file_name => 'create_masked_objects'
    end
  end
end
