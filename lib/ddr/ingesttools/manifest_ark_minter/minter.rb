require 'ezid-client'

module Ddr::IngestTools::ManifestArkMinter
  class Minter

    DEFAULT_EXPORT  = 'no'.freeze
    DEFAULT_PROFILE = 'dc'.freeze
    DEFAULT_STATUS  = Ezid::Status::RESERVED

    def initialize
      configure_ark
      configure_client
    end

    def mint
      Ezid::Identifier.mint
    end

    private

    def configure_ark
      Ezid::Identifier.defaults = {
          export: DEFAULT_EXPORT,
          profile: DEFAULT_PROFILE,
          status: DEFAULT_STATUS
      }
    end

    def configure_client
      Ezid::Client.configure do |config|
        config.default_shoulder = module_configuration.ezid_default_shoulder
        config.password = module_configuration.ezid_password
        config.user = module_configuration.ezid_user
        config.logger = Logger.new(File::NULL)
      end
    end

    def module_configuration
      Ddr::IngestTools::ManifestArkMinter.configuration
    end

  end
end
