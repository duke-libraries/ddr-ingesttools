module Ddr::IngestTools
  class ChecksumFile

    attr_reader :digests

    def initialize(checksum_filepath)
      @digests = digest_hash(checksum_filepath)
    end

    def digest(filepath)
      digests[filepath]
    end

    private

    def digest_hash(checksum_filepath)
      h = {}
      File.open(checksum_filepath, 'r') do |file|
        file.each_line do |line|
          digest, path = line.chomp.split
          h[path] = digest
        end
      end
      h
    end

  end
end
