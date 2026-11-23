require_relative 'Bar'

module SVG
  module Graph
    # A histogram of raw numeric observations, using shared bins for all series.
    class Histogram < Bar
      attr_accessor :bin_count

      def initialize(config)
        super(config.merge(:fields => ['']))
      end

      def set_defaults
        super
        init_with(:bar_gap => false, :scale_integers => true)
      end

      def add_data(conf)
        samples = conf[:data]
        unless samples.is_a?(Array) && !samples.empty? &&
               samples.all? { |value| value.is_a?(Numeric) && value.real? && value.finite? }
          raise ArgumentError, 'Histogram data must be a non-empty array of finite numbers'
        end

        @data << conf.merge(:data => samples.dup)
      end

      def burn
        raise ArgumentError, 'No histogram data available' if @data.empty?
        raise ArgumentError, ':bin_count must be a positive integer' unless bin_count.nil? || (bin_count.is_a?(Integer) && bin_count.positive?)

        samples = @data
        fields = @config[:fields]
        values = samples.flat_map { |series| series[:data] }
        count = bin_count || Math.sqrt(values.length).ceil
        min, max = values.minmax
        if min == max
          min -= 0.5
          max += 0.5
        end
        width = (max - min).to_f / count
        raise ArgumentError, 'Histogram range is too large or small for the requested bins' unless width.finite? && width.positive?

        @config[:fields] = count.times.map do |index|
          left = min + width * index
          right = index == count - 1 ? max : min + width * (index + 1)
          "#{@number_format % left} - #{@number_format % right}"
        end
        @data = samples.map do |series|
          counts = Array.new(count, 0)
          series[:data].each do |value|
            position = (value - min) / width
            nearest = position.round
            position = nearest if (position - nearest).abs <= Float::EPSILON * [position.abs, 1].max * 4
            index = [position.floor, count - 1].min
            counts[index] += 1
          end
          series.merge(:data => counts)
        end
        super
      ensure
        @data = samples if samples
        @config[:fields] = fields if fields
      end
    end
  end
end
