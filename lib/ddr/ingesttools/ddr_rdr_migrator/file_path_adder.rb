module Ddr::IngestTools::DdrRdrMigrator
  class FilePathAdder

    attr_reader :checksum_file, :files, :import_checksums, :logger, :manifest

    def initialize(checksum_file:, files:, logger: nil, manifest:)
      @checksum_file = checksum_file
      @import_checksums = {}
      @files = files
      @logger = logger || Logger.new(STDOUT)
      @manifest = manifest
    end

    def call
      bag_checksums
      scan_files(files)
      update_manifest
      write_checksums
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
      if payload_file?(partial_path)
        add_to_item_files(partial_path)
        add_to_checksums(partial_path)
      end
    end

    def add_to_checksums(partial_path)
      checksum = bag_checksums[partial_path]
      import_checksums[File.join(files,  partial_path)] = checksum
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

    def write_checksums
      File.open(checksum_file, 'w') do |f|
        import_checksums.each do |k,v|
          f.puts "#{v}  #{k}"
        end
      end
    end

    def bag_checksums
      @bag_checksums ||= load_bag_checksums
    end

    def load_bag_checksums
      checksums = {}
      bag_checksum_file = File.join(files, 'manifest-sha1.txt')
      File.readlines(bag_checksum_file).each do |line|
        sum, path = line.chomp.split
        checksums[path] = sum
      end
      checksums
    end
  end
end
