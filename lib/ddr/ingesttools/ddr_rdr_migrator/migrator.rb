module Ddr::IngestTools::DdrRdrMigrator
  class Migrator

    attr_reader :checksum_file, :files, :logger, :metadata_file, :outfile
    attr_writer :manifest

    def initialize(checksum_file:, files:, logger: nil, metadata_file:, outfile:)
      @checksum_file = checksum_file
      @files = files
      @logger = logger || Logger.new(STDOUT)
      @metadata_file = metadata_file
      @outfile = outfile
    end

    def call
      sort_manifest
      rename_columns
      nest_works
      map_licenses
      overwrite_metadata
      add_file_paths
      remove_columns
      write_manifest
    end

    private

    def manifest
      @manifest ||= as_csv_table(metadata_file)
    end

    def sort_manifest
      sorted = manifest.sort_by { |row| [ row['model'], row['pid'] ] }
      self.manifest = CSV::Table.new(sorted)
    end

    def add_file_paths
      file_path_adder.call
    end

    def map_licenses
      license_mapper.call
    end

    def nest_works
      work_nester.call
    end

    def overwrite_metadata
      metadata_overwriter.call
    end

    def rename_columns
      self.manifest = column_renamer.call
    end

    def column_renamer
      ColumnRenamer.new(manifest: manifest)
    end

    def remove_columns
      self.manifest = column_remover.call
    end

    def column_remover
      ColumnRemover.new(logger: logger, manifest: manifest)
    end

    def file_path_adder
      FilePathAdder.new(checksum_file: checksum_file, files: files, logger: logger, manifest: manifest)
    end

    def license_mapper
      LicenseMapper.new(logger: logger, manifest: manifest)
    end

    def metadata_overwriter
      MetadataOverwriter.new(logger: logger, manifest: manifest)
    end

    def work_nester
      WorkNester.new(logger: logger, manifest: manifest)
    end

    def write_manifest
      File.open(outfile, 'w') do |f|
        f.write(manifest.to_csv)
      end
      logger.info("Updated manifest file is at #{outfile}")
    end

    def as_csv_table(file)
      ManifestParser.new(file).as_csv_table
    end

  end
end
