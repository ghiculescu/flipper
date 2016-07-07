require 'delegate'
require 'flipper/instrumenters/noop'

module Flipper
  module Adapters
    # Public: Adapter that wraps another adapter and instruments all adapter
    # operations.
    class Instrumented < SimpleDelegator
      include ::Flipper::Adapter

      # Private: The name of instrumentation events.
      InstrumentationName = "adapter_operation.#{InstrumentationNamespace}".freeze

      # Private: What is used to instrument all the things.
      attr_reader :instrumenter

      # Public: The name of the adapter.
      attr_reader :name

      # Public: Initializes a new adapter instance.
      #
      # adapter - Vanilla adapter instance to wrap.
      #
      # options - The Hash of options.
      #           :instrumenter - What to use to instrument all the things.
      #
      def initialize(adapter, options = {})
        super(adapter)
        @adapter = adapter
        @name = :instrumented
        @instrumenter = options.fetch(:instrumenter, Instrumenters::Noop)
      end

      def features
        payload = {
          :operation => :features,
          :adapter_name => @adapter.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.features
        }
      end

      def add(feature)
        payload = {
          :operation => :add,
          :adapter_name => @adapter.name,
          :feature_name => feature.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.add(feature)
        }
      end

      def remove(feature)
        payload = {
          :operation => :remove,
          :adapter_name => @adapter.name,
          :feature_name => feature.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.remove(feature)
        }
      end

      def clear(feature)
        payload = {
          :operation => :clear,
          :adapter_name => @adapter.name,
          :feature_name => feature.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.clear(feature)
        }
      end

      def get(feature)
        payload = {
          :operation => :get,
          :adapter_name => @adapter.name,
          :feature_name => feature.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.get(feature)
        }
      end

      def enable(feature, gate, thing)
        payload = {
          :operation => :enable,
          :adapter_name => @adapter.name,
          :feature_name => feature.name,
          :gate_name => gate.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.enable(feature, gate, thing)
        }
      end

      def disable(feature, gate, thing)
        payload = {
          :operation => :disable,
          :adapter_name => @adapter.name,
          :feature_name => feature.name,
          :gate_name => gate.name,
        }

        @instrumenter.instrument(InstrumentationName, payload) { |payload|
          payload[:result] = @adapter.disable(feature, gate, thing)
        }
      end
    end
  end
end
