module Ddr::IngestTools::DdrRdrMigrator
  class WorkNester

    attr_reader :logger, :manifest

    def initialize(logger: nil, manifest:)
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      nest_works
      manifest
    end

    private

    def nest_works
      add_parent_ark_column
      add_parent_ark_values
    end

    def add_parent_ark_column
      manifest.each do |row|
        row['parent_ark'] = nil
      end
    end

    def add_parent_ark_values
      item_rows.each do |row|
        row['parent_ark'] = collection_ark
      end
    end

    def collection_row
      manifest.find { |row| row['model'] == 'Collection' }
    end

    def item_rows
      manifest.select { |row| row['model'] == 'Item' }
    end

    def collection_ark
      @collection_ark ||= collection_row['ark']
    end

  end
end
