namespace :friendly_id do
  desc "Make slugs for a model."
  task :make_slugs => :environment do
    raise 'USAGE: rake friendly_id:make_slugs MODEL=MyModelName' if ENV["MODEL"].nil?
    
    if !sluggable_class.friendly_id_config
      raise "Class \"#{sluggable_class.to_s}\" doesn't appear to be using slugs"
    end
    while records = sluggable_class.find(:all, :include => :slugs, :conditions => "slugs.id IS NULL", :limit => 1000) do
      break if records.size == 0
      records.each do |r|
        r.send(:set_slug)
        r.save!
        puts "#{sluggable_class.to_s}(#{r.id}) friendly_id set to \"#{r.slug.name}\""
      end
    end
  end

  desc "Regenereate slugs for a model."
  task :redo_slugs => :environment do
    raise 'USAGE: rake friendly_id:redo_slugs MODEL=MyModelName' if ENV["MODEL"].nil?
    
    if !sluggable_class.respond_to?(:friendly_id_config)
      raise "Class \"#{sluggable_class.to_s}\" doesn't appear to be using slugs"
    end
    sluggable_class.all.each { |model| model.save! }
  end
end

def sluggable_class
  if (ENV["MODEL"].split('::').size > 1)
    ENV["MODEL"].split('::').inject(Kernel) {|scope, const_name| scope.const_get(const_name)}
  else
    Object.const_get(ENV["MODEL"])
  end
end