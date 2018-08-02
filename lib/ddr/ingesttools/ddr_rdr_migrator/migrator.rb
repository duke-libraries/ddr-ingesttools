module Ddr::IngestTools::DdrRdrMigrator
  class Migrator

    attr_reader :base_path, :files_subpath, :logger, :metadata_file, :outfile
    attr_writer :manifest

    def initialize(base_path:, files_subpath:, logger: nil, metadata_file:, outfile:)
      @base_path = base_path
      @files_subpath = files_subpath
      @logger = logger || Logger.new(STDOUT)
      @metadata_file = metadata_file
      @outfile = outfile
    end

    def call
      sort_manifest
      rename_columns
      add_file_paths
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

    def rename_columns
      self.manifest = column_renamer.call
    end

    def column_renamer
      ColumnRenamer.new(manifest: manifest)
    end

    def file_path_adder
      FilePathAdder.new(base_path: base_path, files_subpath: files_subpath, logger: logger, manifest: manifest)
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
