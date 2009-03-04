class ConstituencyList

  def items
    Constituency.all.collect(&:to_tsv_line).join("\n")
  end

  def items= text
    @constituencies = {}
    text.each_line do |line|
      line.strip!
      unless line.blank? || line[/Constituency/]
        @constituencies[line] = Constituency.load_tsv_line(line)
      end
    end
    @constituencies
  end

  def constituencies
    @constituencies
  end
end
