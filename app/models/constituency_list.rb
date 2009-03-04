class ConstituencyList

  def items
    Constituency.all.collect(&:to_tsv_line).join("\n")
  end

  def items= text
    @constituencies = {}
    text.each_line do |line|
      @constituencies[line] = Constituency.load_tsv_line(line)
    end
    @constituencies
  end

  def constituencies
    @constituencies
  end
end
