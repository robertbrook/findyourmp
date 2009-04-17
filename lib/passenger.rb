module FindYourMP; end

module FindYourMP::Passenger

  class << self
    def passenger_path
      '/var/lib/gems/1.8/gems/passenger-2.1.2/bin'
    end

    def memory_stats_cmd
      "#{passenger_path}/passenger-memory-stats"
    end

    def status_cmd
      "#{passenger_path}/passenger-status"
    end
  end
end