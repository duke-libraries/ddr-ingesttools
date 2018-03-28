require_relative 'manifest_ark_minter/configuration'
require_relative 'manifest_ark_minter/manifest_updater'
require_relative 'manifest_ark_minter/manifest_parser'
require_relative 'manifest_ark_minter/minter'

module Ddr::IngestTools
  module ManifestArkMinter

    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end
    end

  end
end
