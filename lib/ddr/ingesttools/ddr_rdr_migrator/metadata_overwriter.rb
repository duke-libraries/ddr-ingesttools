module Ddr::IngestTools::DdrRdrMigrator
  class MetadataOverwriter

    attr_reader :logger, :manifest

    OVERWRITTEN_FIELDS = %w[ creator publisher available license ].freeze

    def initialize(logger: nil, manifest:)
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      overwrite
      manifest
    end

    private

    def overwrite
      populate_overwriting_attributes
      overwrite_values
    end

    def collection_row
      @collection_row = manifest.find { |row| row['model'] == 'Collection' }
    end

    def item_rows
      manifest.select { |row| row['model'] == 'Item' }
    end

    def overwrite_values
      item_rows.each do |row|
        collection_overwriting_attributes.each do |field, value|
          row[field] = value
        end
      end
    end

    def collection_overwriting_attributes
      @overwriting_attributes ||= populate_overwriting_attributes
    end

    def populate_overwriting_attributes
      attrs = {}
      OVERWRITTEN_FIELDS.each do |field|
        attrs[field] = collection_row[field] if collection_row[field]
      end
      attrs
    end

  end
end
