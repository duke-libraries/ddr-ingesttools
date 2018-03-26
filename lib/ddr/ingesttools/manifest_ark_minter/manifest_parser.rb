require 'csv'

module Ddr::IngestTools::ManifestArkMinter
  class ManifestParser

    attr_reader :manifest_file_path

    ARK_HEADER = 'ark'

    def initialize(manifest_file_path)
      @manifest_file_path = manifest_file_path
    end

    def as_csv_table
      @csv_table ||= CSV.read(manifest_file_path, headers: true)
    end

    def arks_missing?
      arks.any? { |value| value.compact.empty? }
    end

    def headers
      as_csv_table.headers
    end

    private

    def arks
      as_csv_table.values_at(ARK_HEADER)
    end

  end
end
