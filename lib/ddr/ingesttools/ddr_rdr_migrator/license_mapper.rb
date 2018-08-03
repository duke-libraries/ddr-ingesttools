module Ddr::IngestTools::DdrRdrMigrator
  class LicenseMapper

    attr_reader :logger, :manifest

    LICENSE_MAP = { 'https://creativecommons.org/publicdomain/zero/1.0/' =>
                        'http://creativecommons.org/publicdomain/zero/1.0/' }

    def initialize(logger: nil, manifest:)
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      map_licenses
      manifest
    end

    private

    def map_licenses
      manifest.each do |row|
        if LICENSE_MAP.keys.include?(row['license'])
          row['license'] = LICENSE_MAP[row['license']]
        end
      end
    end

  end
end
