require 'csv'

module Ddr::IngestTools::DdrRdrMigrator
  class ColumnRenamer

    attr_reader :logger
    attr_accessor :manifest

    HEADER_MAP = { 'permanent_id' => 'ark',
                   'date' => 'available',
                   'spatial' => 'based_near',
                   'type' => 'resource_type',
                   'relation' => 'related_url',
                   'rights' => 'license',
                   'bibliographicCitation' => 'bibliographic_citation'
                 }

    def initialize(logger: nil, manifest:)
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      rename
    end

    private

    def rename
      csv_array = manifest.to_a
      csv_headers = csv_array[0]
      new_headers = csv_headers.map { |hdr| HEADER_MAP.fetch(hdr, hdr) }
      csv_array[0] = new_headers
      csv_string = CSV.generate { |csv_out| csv_array.each { |array| csv_out << array } }
      CSV.parse(csv_string, headers: true)
    end

  end
end
