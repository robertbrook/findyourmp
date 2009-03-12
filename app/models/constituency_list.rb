class ConstituencyList

  def items
    Constituency.all.collect(&:to_tsv_line).join("\n")
  end

  def items= text
    @constituencies = ActiveSupport::OrderedHash.new
    lines = []
    text.each_line do |line|
      line.strip!
      lines << line unless(line.blank? || line[/Constituency/])
    end

    lines.sort.each do |line|
      @constituencies[line] = Constituency.load_tsv_line(line)
    end

    @constituencies
  end

  def unchanged_constituencies
    @constituencies.to_a.select{|x| x[1] && x[1][1].nil? }
  end

  def changed_constituencies
    @constituencies.to_a.select{|x| x[1] && x[1][1] }
  end

  def unrecognized_constituencies
    @constituencies.to_a.select{|x| x[1].nil? }
  end

  def ommitted_constituencies
    constituencies = Constituency.all
    @constituencies.each do |x|
      constituencies.delete(x[1][0]) if x[1]
    end
    constituencies
  end

  def constituencies
    @constituencies
  end
end
