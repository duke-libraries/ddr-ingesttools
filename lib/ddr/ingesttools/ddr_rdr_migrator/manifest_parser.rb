require 'csv'

module Ddr::IngestTools::DdrRdrMigrator
  class ManifestParser

    attr_reader :manifest_file_path

    def initialize(manifest_file_path)
      @manifest_file_path = manifest_file_path
    end

    def as_csv_table
      @csv_table ||= CSV.read(manifest_file_path, headers: true)
    end

    def headers
      as_csv_table.headers
    end

  end
end
