module DataMapper

  module Types

    class UtcDateTime < DataMapper::Type

      primitive DateTime

      def self.load(value, property)
        if value.nil?
          nil
        elsif value.is_a?(DateTime)
          ::DateTime.new(value.year, value.month, value.day, value.hour, value.min, value.sec, 0)
        else
          raise ArgumentError.new("+value+ must be nil or a DateTime")
        end
      end

      def self.dump(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          Time.parse(value).utc.to_datetime
        elsif value.is_a?(DateTime)
          Time.parse(value.to_s).utc.to_datetime
        else
          raise ArgumentError.new("+value+ must be nil or a String or a DateTime")
        end
      end

    end # class UtcDateTime

    UTCDateTime = UtcDateTime

  end

  module Timestamp

    def set_timestamps
      return unless dirty? || new_record?
      TIMESTAMP_PROPERTIES.each do |name,(_type,proc)|
        if model.properties.named?(name)
          self.send("#{name}=", proc.call(self, model.properties[name]))
        end
      end
    end

    def utc_timestamped?
      self.class.utc_timestamped?
    end

    module ClassMethods

      def timestamps(*names)
        raise ArgumentError, 'You need to pass at least one argument' if names.empty?

        # if the last element in names is a Hash:
        # extract this hash and look for a :utc key
        opts = names.last.is_a?(Hash) ? names.pop : nil
        @utc = opts && opts[:utc] && (names.include?(:created_at) || names.include?(:updated_at))

        names.each do |name|
          case name
            when *TIMESTAMP_PROPERTIES.keys
              type = TIMESTAMP_PROPERTIES[name].first
              property name, type, :required => true, :auto_validation => false

              if type == DateTime && @utc # UTC makes no sense for Date
                define_method "#{name}=", UTC::PROPERTY_WRITER.call(name, type)
                define_method "#{name}",  UTC::PROPERTY_READER.call(name, type)
              end

            when :at
              timestamps(:created_at, :updated_at, :utc => @utc)
            when :on
              timestamps(:created_on, :updated_on) # UTC makes no sense for Date
            else
              raise InvalidTimestampName, "Invalid timestamp property name '#{name}'"
          end
        end
      end

      def utc_timestamped?
        !!@utc
      end

    end

    module UTC
      PROPERTY_WRITER = lambda { |name, type|
        lambda { |dt| attribute_set(name, Time.parse(dt.to_s).utc.send("to_#{type.name.downcase}")) }
      }
      PROPERTY_READER = lambda { |name, type|
        lambda {
          return nil unless dt = attribute_get(name)
          if type == Date
            Date.new(dt.year, dt.month, dt.day, 0)
          elsif type == DateTime
            DateTime.new(dt.year, dt.month, dt.day, dt.hour, dt.min, dt.sec, 0)
          else
            nil
          end
        }
      }
    end

  end

end
