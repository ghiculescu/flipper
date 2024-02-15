require 'delegate'
require 'flipper/api/v1/decorators/gate'

module Flipper
  module Api
    module V1
      module Decorators
        class Feature
          def initialize(feature)
            @feature = feature
          end

          # Public: Returns instance as hash that is ready to be json dumped.
          def as_json(exclude_gates: false, exclude_gate_names: false)
            result = {
              'key' => @feature.key,
              'state' => @feature.state.to_s,
            }

            unless exclude_gates
              gate_values = @feature.adapter.get(@feature)
              result['gates'] = @feature.gates.map do |gate|
                Decorators::Gate.new(gate, gate_values[gate.key]).as_json(exclude_name: exclude_gate_names)
              end
            end

            result
          end
        end
      end
    end
  end
end
