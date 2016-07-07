require 'set'

module Flipper
  module Adapters
    # Public: Adapter for storing everything in memory (ie: Hash).
    # Useful for tests/specs.
    class Memory
      include ::Flipper::Adapter

      FeaturesKey = :flipper_features

      # Public: The name of the adapter.
      attr_reader :name

      # Public
      def initialize(source = nil)
        @source = source || {}
        @name = :memory
      end

      def features
        set_members(FeaturesKey)
      end

      def add(feature)
        features.add(feature.key)
        true
      end

      def remove(feature)
        features.delete(feature.name.to_s)
        clear(feature)
        true
      end

      def clear(feature)
        feature.gates.each do |gate|
          delete key(feature, gate)
        end
        true
      end

      def get(feature)
        result = {}

        feature.gates.each do |gate|
          result[gate.key] = case gate.data_type
          when :boolean, :integer
            read key(feature, gate)
          when :set
            set_members key(feature, gate)
          else
            raise "#{gate} is not supported by this adapter yet"
          end
        end

        result
      end

      def enable(feature, gate, thing)
        case gate.data_type
        when :boolean, :integer
          write key(feature, gate), thing.value.to_s
        when :set
          set_add key(feature, gate), thing.value.to_s
        else
          raise "#{gate} is not supported by this adapter yet"
        end

        true
      end

      def disable(feature, gate, thing)
        case gate.data_type
        when :boolean
          clear(feature)
        when :integer
          write key(feature, gate), thing.value.to_s
        when :set
          set_delete key(feature, gate), thing.value.to_s
        else
          raise "#{gate} is not supported by this adapter yet"
        end

        true
      end

      def inspect
        attributes = [
          "name=:memory",
          "source=#{@source.inspect}",
        ]
        "#<#{self.class.name}:#{object_id} #{attributes.join(', ')}>"
      end

      private

      def key(feature, gate)
        "#{feature.key}/#{gate.key}"
      end

      def read(key)
        @source[key.to_s]
      end

      def write(key, value)
        @source[key.to_s] = value.to_s
      end

      def delete(key)
        @source.delete(key.to_s)
      end

      def set_add(key, value)
        ensure_set_initialized(key)
        @source[key.to_s].add(value.to_s)
      end

      def set_delete(key, value)
        ensure_set_initialized(key)
        @source[key.to_s].delete(value.to_s)
      end

      def set_members(key)
        ensure_set_initialized(key)
        @source[key.to_s]
      end

      def ensure_set_initialized(key)
        @source[key.to_s] ||= Set.new
      end
    end
  end
end
