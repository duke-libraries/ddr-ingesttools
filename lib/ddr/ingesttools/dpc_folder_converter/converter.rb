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
      SIF_MANIFEST_SHA1_FILENAME = 'manifest-sha1.txt'

      Results = Struct.new(:file_map, :errors)

      attr_reader :source, :target, :data_dir, :item_id_length, :checksums, :copy_files, :collection_title,
                  :admin_set, :metadata_headers
      attr_accessor :errors, :file_map, :local_id_metadata, :results

      def initialize(source:, target:, item_id_length:, checksums: nil, copy_files: false, collection_title: nil,
                      admin_set: nil)
        @source = source
        @target = target
        @item_id_length = item_id_length
        @checksums = checksums
        @copy_files = copy_files
        @collection_title = collection_title
        @admin_set = admin_set
        @metadata_headers = [ 'path', 'local_id' ]
        @metadata_headers << 'title' unless collection_title.nil?
        @metadata_headers << 'admin_set' unless admin_set.nil?
      end

      def call
        setup
        scan_files(source)
        output_metadata
        bagitup
        validate_checksums if checksums
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

      def included_extensions
        Ddr::IngestTools::DpcFolderConverter.config[:included_extensions]
      end

      def scan_files(dirpath, file_handler='handle_component'.to_sym)
        Dir.foreach(dirpath).each do |entry|
          next if [ '.', '..' ].include?(entry)
          path = File.join(dirpath, entry)
          if File.directory?(path)
            if entry == DPC_TARGETS_DIRNAME
              scan_files(path, :handle_target)
            elsif entry == INTERMEDIATE_FILES_DIRNAME
              scan_files(path, :handle_intermediate_file)
            else
              scan_files(path, file_handler)
            end
          else
            if included_extensions.include?(File.extname(entry))
              self.send(file_handler, path)
            end
          end
        end
      end

      def handle_component(file)
        base = File.basename(file, File.extname(file))
        item_id = item_id_length == 0 ? base : base[0, item_id_length]
        FileUtils.mkdir_p(File.join(data_dir, item_id))
        local_id_metadata[item_id] = item_id
        handle_file(file, item_id)
        local_id_metadata[File.join(item_id, File.basename(file))] = base
      end

      def handle_intermediate_file(file)
        FileUtils.mkdir_p(File.join(data_dir, INTERMEDIATE_FILES_DIRNAME))
        handle_file(file, INTERMEDIATE_FILES_DIRNAME)
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
        case
          when collection_title && admin_set
            metadata_rows << CSV::Row.new(metadata_headers, [ nil, nil, collection_title, admin_set ])
          when collection_title
            metadata_rows << CSV::Row.new(metadata_headers, [ nil, nil, collection_title ])
          when admin_set
            metadata_rows << CSV::Row.new(metadata_headers, [ nil, nil, admin_set ])
        end
        local_id_metadata.each_pair do |k,v|
          row_elements = [ k, v ]
          row_elements << nil if collection_title
          row_elements << nil if admin_set
          metadata_rows << CSV::Row.new(metadata_headers, row_elements)
        end
        File.open(File.join(data_dir, SIF_METADATA_FILENAME), 'w') do |file|
          file.puts(metadata_headers.join(Ddr::IngestTools::DpcFolderConverter.config[:csv_options][:col_sep]))
          metadata_rows.each do |row|
            file.puts(row.to_csv(Ddr::IngestTools::DpcFolderConverter.config[:csv_options]))
          end
        end
      end

      def bagitup
        bag = BagIt::Bag.new(target)
        bag.manifest!
      end

      def validate_checksums
        external_checksums = Ddr::IngestTools::ChecksumFile.new(checksums)
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
