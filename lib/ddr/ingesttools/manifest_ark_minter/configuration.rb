module Ddr::IngestTools::ManifestArkMinter
  class Configuration

    attr_accessor :ezid_default_shoulder, :ezid_password, :ezid_user

    def initialize
      @ezid_default_shoulder = nil
      @ezid_password = nil
      @ezid_user = nil
    end

  end
end
