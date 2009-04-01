class ConstituencyList

  attr_reader :constituencies, :invalid_constituencies, :unchanged_constituencies, :changed_constituencies, :unrecognized_constituencies, :ommitted_constituencies

  def items
    Constituency.all.collect(&:to_tsv_line).sort.join("\n")
  end

  def items= text
    constituencies = ActiveSupport::OrderedHash.new
    constituency_list = []
    lines = []
    text.each_line do |line|
      line.strip!
      lines << line unless(line.blank? || line[/Constituency/])
    end

    lines.sort.each do |line|
      loaded = Constituency.load_tsv_line(line)
      constituencies[line] = loaded
      constituency_list << ConstituencyItem.new(line, loaded[0], loaded[1])
    end

    @unchanged_constituencies = constituency_list.select{|x| x.new_constituency.nil? && !x.old.nil? }
    @changed_constituencies = constituency_list.select{|x| x.new_constituency }
    @invalid_constituencies = @changed_constituencies.select{|x| !x.new_constituency.valid? }
    @changed_constituencies = @changed_constituencies - @invalid_constituencies
    @unrecognized_constituencies = constituency_list.select{|x| x.old.nil? && x.new_constituency.nil? }

    @ommitted_constituencies = Constituency.all
    constituency_list.each { |x| @ommitted_constituencies.delete(x.old) if x.old }

    @constituencies = constituencies
  end

end

class ConstituencyItem
  attr_reader :line, :old, :new_constituency
  def initialize line, old, new_constituency
    @line, @old, @new_constituency = line, old, new_constituency
  end
end
