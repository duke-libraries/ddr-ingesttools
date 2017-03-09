require 'bagit'
require 'csv'
require 'fileutils'
require 'find'

module Ddr::IngestTools::DpcFolderConverter
    class Converter

      INTERMEDIATE_FILES_DIRNAME = 'intermediate_files'
      DPC_TARGETS_DIRNAME = 'targets'
      SIF_TARGETS_DIRNAME = 'dpc_targets'
      SIF_METADATA_FILENAME = 'metadata.txt'
      SIF_METADATA_HEADERS = [ 'path', 'local_id' ]
      SIF_MANIFEST_SHA1_FILENAME = 'manifest-sha1.txt'

      Results = Struct.new(:file_map, :errors)

      attr_reader :source, :target, :data_dir, :item_id_length, :checksum_file, :copy_files
      attr_accessor :errors, :file_map, :local_id_metadata, :results

      def initialize(source, target, item_id_length, checksum_file, copy_files)
        @source = source
        @target = target
        @item_id_length = item_id_length
        @checksum_file = checksum_file
        @copy_files = copy_files
      end

      def call
        setup
        find_files
        output_metadata
        bagitup
        validate_checksums if checksum_file
        Results.new(file_map, errors)
      end

      private

      def setup
        @data_dir = File.join(target, 'data')
        @errors = []
        @file_map = {}
        @local_id_metadata = {}
        FileUtils.mkdir_p data_dir
      end

      def find_files
        find_component_files(source).each { |file| handle_component(file) }
        find_target_files(source).each { |file| handle_target(file) }
      end

      def included_extensions
        Ddr::IngestTools::DpcFolderConverter.config[:included_extensions]
      end

      def find_component_files(dir)
        files = []
        Find.find(dir) do |path|
          Find.prune if path.include?(DPC_TARGETS_DIRNAME)
          Find.prune if path.include?(INTERMEDIATE_FILES_DIRNAME)
          next unless File.file?(path)
          next unless included_extensions.include?(File.extname(path))
          files << path
        end
        files
      end

      def find_target_files(dir)
        files = []
        Find.find(dir) do |path|
          next unless path.include?(DPC_TARGETS_DIRNAME)
          next unless File.file?(path)
          next unless included_extensions.include?(File.extname(path))
          files << path
        end
        files
      end

      def handle_component(file)
        base = File.basename(file, File.extname(file))
        item_id = item_id_length == 0 ? base : base[0, item_id_length]
        FileUtils.mkdir_p(File.join(data_dir, item_id))
        local_id_metadata[item_id] = item_id
        handle_file(file, item_id)
        local_id_metadata[File.join(item_id, File.basename(file))] = base
      end

      def handle_target(file)
        base = File.basename(file, File.extname(file))
        FileUtils.mkdir_p(File.join(data_dir, SIF_TARGETS_DIRNAME))
        handle_file(file, SIF_TARGETS_DIRNAME)
        local_id_metadata[File.join(SIF_TARGETS_DIRNAME, File.basename(file))] = base
      end

      def handle_file(file, folder_name)
        if copy_files
          FileUtils.cp file, File.join(data_dir, folder_name)
        else
          FileUtils.ln_s file, File.join(data_dir, folder_name)
        end
        file_map[file] = File.join(data_dir, folder_name, File.basename(file))
      end

      def output_metadata
        metadata_rows = []
        local_id_metadata.each_pair do |k,v|
          metadata_rows << CSV::Row.new(SIF_METADATA_HEADERS, [ k, v ])
        end
        File.open(File.join(data_dir, SIF_METADATA_FILENAME), 'w') do |file|
          file.puts(SIF_METADATA_HEADERS.join(Ddr::IngestTools::DpcFolderConverter.config[:csv_options][:col_sep]))
          metadata_rows.each do |row|
            file.puts(row.to_csv(Ddr::IngestTools::DpcFolderConverter.config[:csv_options]).strip)
          end
        end
      end

      def bagitup
        bag = BagIt::Bag.new(target)
        bag.manifest!
      end

      def validate_checksums
        external_checksums = Ddr::IngestTools::ChecksumFile.new(checksum_file)
        sif_manifest = Ddr::IngestTools::ChecksumFile.new(File.join(target, SIF_MANIFEST_SHA1_FILENAME))
        file_map.each do |source_path, target_path|
          external_checksum = external_checksums.digest(source_path)
          manifest_path = target_path.sub("#{target}/", '')
          sif_checksum = sif_manifest.digest(manifest_path)
          unless external_checksum == sif_checksum
            errors << I18n.translate('errors.checksum_mismatch', { c1: external_checksum, f1: source_path,
                                                                   c2: sif_checksum, f2: target_path })
          end
        end
      end
    end
end
