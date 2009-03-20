module CountByMonth

  def self.included(base) # :nodoc:
    base.extend ClassMethods
  end

  module ClassMethods
    def count_by_month type, include_objects, created_attribute=:created_at
      count_by_month = ActiveSupport::OrderedHash.new
      first_month = send(type).minimum(created_attribute)

      if first_month
        first_month = first_month.at_beginning_of_month
        last_month = send(type).maximum(created_attribute).at_beginning_of_month
        months = [first_month]
        next_month = first_month.next_month
        while (next_month <= last_month)
          months << next_month
          next_month = next_month.next_month
        end
        months.each do |month|
          conditions = "MONTH(#{created_attribute}) = #{month.month} AND YEAR(#{created_attribute}) = #{month.year}"
          if include_objects
            count_by_month[month] = send(type, :conditions => conditions)
          else
            count_by_month[month] = send(type).count(:conditions => conditions)
          end
        end
      end
      count_by_month.to_a.sort {|a,b|b[0]<=>a[0]}
    end
  end

end
