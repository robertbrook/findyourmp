# require "cucumber"
# require "cucumber/treetop_parser/feature_en"

module FeaturesOutput

  # Cucumber.load_language("en")
  #
  # Cucumber::Tree::Feature.class_eval do
    # attr_reader :scenarios
  # end
  #
  # DATA_DIR = File.expand_path(File.dirname(__FILE__) + '/../features')
  # OUTPUT_DIR = File.expand_path(File.dirname(__FILE__) + '/../')
  #
  # def create_report(format)
    # files = Dir.new(DATA_DIR).entries
    # files.delete_if do |f|
      # f[-8..-1] != '.feature'
    # end
    #
    # case format
      # when 'html'
        # outputname = OUTPUT_DIR + '/features.html'
      # when 'text'
        # outputname = OUTPUT_DIR + '/features.txt'
    # end
    # outfile = File.new(outputname, 'w+')
    #
    # report(outfile, format, "Features Report", '<h1>') if format == 'html'
    #
    # files.map do |file|
      # feature = parser.parse_feature(DATA_DIR + '/' + file)
      #
      # report(outfile, format, feature.header.split("\n").first, "<h2>")
      #
      # feature.scenarios.each do |scenario|
        # next if scenario.is_a?(Cucumber::Tree::RowScenario)
        # report(outfile, format, "  Scenario: " + scenario.name, "<h3>")
        #
        # report(outfile, format, "<p>", "") if format == 'html'
        #
        # scenario.steps.each do |step|
          # #handle standard steps
          # if step.is_a?(Cucumber::Tree::Step)
            # report(outfile, format, "    " + step.keyword + " " + step.name, "")
            # report(outfile, format, "<br />", "") if format == 'html'
          # end
        # end
        #
        # report(outfile, format, "</p>", "") if format == 'html'
        #
        # report(outfile, format, "", "")
      # end
      #
      # report(outfile, format, "", "")
    # end
    #
    # outfile.close
  # end
  #
  # def report(file, format, text, tag)
    # case format
      # when 'text'
        # file.puts text
      # when 'html'
        # file.puts tag + text + tag.gsub('<', '</')
    # end
  # end
  #
  # def parser
    # @parser ||= Cucumber::TreetopParser::FeatureParser.new
  # end

end