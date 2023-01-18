# frozen_string_literal: true

# Released under the MIT License.
# Copyright, 2022-2023, by Samuel Williams.

unless YAML.respond_to?(:unsafe_load)
  def YAML.unsafe_load(body)
    load(body)
  end
end
