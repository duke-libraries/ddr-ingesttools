require 'csv'
require 'find'

module Ddr::IngestTools::DpcFolderConverter
    class Converter

      METADATA_HEADERS = [ 'path', 'local_id' ]

      attr_reader :source, :target, :item_id_length
      attr_accessor :local_id_metadata

      def initialize(source, target, item_id_length=0)
        @source = source
        @target = target
        @item_id_length = item_id_length
        @local_id_metadata = {}
      end

      def call
        FileUtils.mkdir_p target
        find_component_files(source).each { |file| handle_component(file) }
        find_target_files(source).each { |file| handle_target(file) }
        output_metadata
      end

      private

      def included_extensions
        Ddr::IngestTools::DpcFolderConverter.config[:included_extensions]
      end

      def find_component_files(dir)
        files = []
        Find.find(dir) do |path|
          Find.prune if path.include?('targets')
          Find.prune if path.include?('intermediate_files')
          next unless File.file?(path)
          next unless included_extensions.include?(File.extname(path))
          files << path
        end
        files
      end

      def find_target_files(dir)
        files = []
        Find.find(dir) do |path|
          next unless path.include?('targets')
          next unless File.file?(path)
          next unless included_extensions.include?(File.extname(path))
          files << path
        end
        files
      end

      def handle_component(file)
        base = File.basename(file, File.extname(file))
        item_id = item_id_length == 0 ? base : base[0, item_id_length]
        FileUtils.mkdir_p(File.join(target, item_id))
        local_id_metadata[item_id] = item_id
        FileUtils.cp file, File.join(target, item_id)
        local_id_metadata[File.join(item_id, File.basename(file))] = base
      end

      def handle_target(file)
        base = File.basename(file, File.extname(file))
        FileUtils.mkdir_p(File.join(target, 'dpc_targets'))
        FileUtils.cp file, File.join(target, 'dpc_targets')
        local_id_metadata[File.join('dpc_targets', File.basename(file))] = base
      end

      def output_metadata
        metadata_rows = []
        local_id_metadata.each_pair do |k,v|
          metadata_rows << CSV::Row.new(METADATA_HEADERS, [ k, v ])
        end
        File.open(File.join(target, 'metadata.txt'), 'w') do |file|
          file.puts(METADATA_HEADERS.join(Ddr::IngestTools::DpcFolderConverter.config[:csv_options][:col_sep]))
          metadata_rows.each do |row|
            file.puts(row.to_csv(Ddr::IngestTools::DpcFolderConverter.config[:csv_options]).strip)
          end
        end
      end

    end
end
