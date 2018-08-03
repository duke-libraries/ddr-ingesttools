module Ddr::IngestTools::DdrRdrMigrator
  class FilePathAdder

    attr_reader :files, :logger, :manifest

    def initialize(files:, logger: nil, manifest:)
      @files = files
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      scan_files(files)
      update_manifest
      manifest
    end

    private

    def item_files
      @item_files ||= {}
    end

    def scan_files(dirpath)
      Dir.foreach(dirpath).each do |entry|
        next if [ '.', '..' ].include?(entry)
        file_loc = File.join(dirpath, entry)
        if File.directory?(file_loc)
          scan_files(file_loc)
        else
          handle_file(file_loc)
        end
      end
    end

    def handle_file(file_loc)
      partial_path = file_partial_path(file_loc)
      add_to_item_files(partial_path) if payload_file?(partial_path)
    end

    def add_to_item_files(partial_path)
      item_pid = item_pid(partial_path)
      item_files[item_pid] ||= []
      item_files[item_pid] << partial_path
    end

    def file_partial_path(file_loc)
      file_loc.sub(files, '').sub(/^#{File::SEPARATOR}/, '')
    end

    def payload_file?(partial_path)
      partial_path.start_with?(File.join('data', 'objects')) && !File.basename(partial_path).start_with?('.')
    end

    def item_pid(partial_path)
      munged_pid = partial_path.split(File::SEPARATOR)[-2]
      munged_pid.sub('_', ':')
    end

    def update_manifest
      add_file_column
      add_file_column_values
    end

    def add_file_column
      manifest.each do |row|
        row['file'] = nil
      end
    end

    def add_file_column_values
      item_files.each do |k,v|
        row = manifest.find { |row| row['pid'] == k }
        row['file'] = v.join('|')
      end
    end

  end
end
