module FindYourMP
  module PassengerManagement

    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end

    module ClassMethods
      def passenger_path
        '/var/lib/gems/1.8/gems/passenger-2.2.1/bin'
      end

      def memory_stats
        if RAILS_ENV == 'production'
          Process.fork {|| exec "#{memory_stats_cmd} >> memory_stats.txt" }
          Process.wait
          stats = File.new('memory_stats.txt').read.to_s
          File.delete('memory_stats.txt')
          stats
        else
          example_memory_stats
        end
      end

      def memory_stats_cmd
        "#{passenger_path}/passenger-memory-stats"
      end

      def status_cmd
        "#{passenger_path}/passenger-status"
      end

      def example_memory_stats
      %Q|-------------- Apache processes --------------
  PID    PPID  Threads  VMSize    Private  Name
  ----------------------------------------------
  2509   1     1        130.0 MB  0.2 MB   /usr/sbin/apache2 -k start
  18947  2509  1        130.2 MB  0.4 MB   /usr/sbin/apache2 -k start
  18951  2509  1        130.2 MB  0.4 MB   /usr/sbin/apache2 -k start
  18953  2509  1        130.2 MB  0.4 MB   /usr/sbin/apache2 -k start
  18955  2509  1        130.2 MB  0.3 MB   /usr/sbin/apache2 -k start
  18957  2509  1        130.2 MB  0.3 MB   /usr/sbin/apache2 -k start
  19146  2509  1        130.2 MB  0.5 MB   /usr/sbin/apache2 -k start
  24760  2509  1        130.3 MB  0.5 MB   /usr/sbin/apache2 -k start
  26528  2509  1        130.3 MB  0.5 MB   /usr/sbin/apache2 -k start
  26529  2509  1        130.3 MB  0.4 MB   /usr/sbin/apache2 -k start
  26763  2509  1        130.0 MB  0.1 MB   /usr/sbin/apache2 -k start
  ### Processes: 11
  ### Total private dirty RSS: 3.95 MB

  --------- Passenger processes ----------
  PID    Threads  VMSize    Private  Name
  ----------------------------------------
  18938  11       15.4 MB   0.4 MB   /passenger/ext/apache2/ApplicationPoolServerExecutable 0 /passenger/bin/passenger-spawn-server  /usr/bin/ruby1.8  /tmp/passenger.2509/status.fifo
  18942  2        54.5 MB   8.5 MB   Passenger spawn server
  28004  1        138.1 MB  50.9 MB  Passenger ApplicationSpawner: /mnt/sites/findyourmp/releases/20090415161705
  28006  1        140.9 MB  51.8 MB  Rails: /mnt/sites/findyourmp/releases/20090415161705
  ### Processes: 4
  ### Total private dirty RSS: 111.57 MB
  |
      end
    end
  end
end