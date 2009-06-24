module FindYourMP
  module Timer

    def start_timing
      @start = Time.now
    end

    def log_duration percentage_complete=nil
      duration = Time.now - @start
      if percentage_complete
        estimated_time = (duration / percentage_complete)
        estimated_remaining = estimated_time - duration
        due = (Time.now + estimated_remaining).strftime('%I:%M%p').downcase
        estimated_remaining = estimated_remaining.seconds.ago
        puts "#{time_ago_in_words(estimated_remaining).capitalize} remaining, due to complete about #{due}."
      else
        puts "duration: #{duration}"
      end
    end
  end
end
