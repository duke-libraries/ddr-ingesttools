require 'fileutils'
require 'logger'
require 'tempfile'

module Ddr::IngestTools::ManifestArkMinter
  class ManifestUpdater

    attr_reader :config, :logger, :manifest, :output

    DEFAULT_CONFIG_FILE = 'manifest_ark_minter_config.yml'

    def initialize(config: DEFAULT_CONFIG_FILE, manifest:, output:, logger: nil)
      @config = config
      @manifest = manifest
      @output = output
      @logger = logger || Logger.new(STDOUT)
    end

    def call
      configure
      if needs_updating?
        update
      else
        logger.info("Manifest file already has ARKs ... nothing to mint")
      end
    end

    private

    def configure
      conf = YAML::load(IO.read(config))
      Ddr::IngestTools::ManifestArkMinter.configure do |config|
        config.ezid_default_shoulder = conf.fetch('ezid_default_shoulder')
        config.ezid_password = conf.fetch('ezid_password')
        config.ezid_user = conf.fetch('ezid_user')
      end
    end

    def update
      update_manifest_table
      write_updated_manifest
    end

    def update_manifest_table
      logger.info("Minting ARKs for manifest file")
      mint_counter = 0
      manifest_as_csv_table.each do |row|
        unless row['ark']
          row['ark'] = minter.mint
          mint_counter += 1
        end
      end
      logger.info("Minted #{mint_counter} ARK(s)")
    end

    def manifest_as_csv_table
      @manifest_as_csv_table ||= parser.as_csv_table
    end

    def write_updated_manifest
      File.open(output, 'w') do |f|
        f.write(manifest_as_csv_table.to_csv)
      end
      logger.info("Updated manifest file is at #{output}")
    end

    def needs_updating?
      parser.arks_missing?
    end

    def minter
      @minter ||= Minter.new
    end

    def parser
      @parser ||= ManifestParser.new(manifest)
    end

  end
end
