module Ddr::IngestTools::DdrRdrMigrator
  class ColumnRemover

    attr_reader :logger, :manifest

    UNNEEDED_COLUMNS = [ 'model', 'pid' ].freeze

    def initialize(logger: nil, manifest:)
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      remove
      manifest
    end

    private

    def remove
      UNNEEDED_COLUMNS.each { |col| manifest.delete(col) }
    end

  end
end
