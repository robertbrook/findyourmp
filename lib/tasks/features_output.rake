require File.expand_path(File.dirname(__FILE__) + '/../features_output')

namespace :features do
  include FeaturesOutput

  desc "Produce plain text report of Features"
  task :report do
    create_report('text')
  end

  desc "Produce HTML report of Features"
  task :report_html do
    create_report('html')
  end

end