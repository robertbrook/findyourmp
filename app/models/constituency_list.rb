class ConstituencyList

  attr_reader :constituencies, :unchanged_constituencies, :changed_constituencies, :unrecognized_constituencies, :ommitted_constituencies

  def items
    Constituency.all.collect(&:to_tsv_line).join("\n")
  end

  def items= text
    constituencies = ActiveSupport::OrderedHash.new
    lines = []
    text.each_line do |line|
      line.strip!
      lines << line unless(line.blank? || line[/Constituency/])
    end

    lines.sort.each do |line|
      constituencies[line] = Constituency.load_tsv_line(line)
    end

    constituency_list = constituencies.to_a
    @unchanged_constituencies = constituency_list.select{|x| x[1] && x[1][1].nil? }
    @changed_constituencies = constituency_list.select{|x| x[1] && x[1][1] }
    @unrecognized_constituencies = constituency_list.select{|x| x[1].nil? }

    @ommitted_constituencies = Constituency.all
    constituency_list.each { |x| @ommitted_constituencies.delete(x[1][0]) if x[1] }

    @constituencies = constituencies
  end

end
