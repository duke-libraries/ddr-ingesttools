require 'spec_helper'
require 'tempfile'

module Ddr::IngestTools::DdrRdrMigrator
  RSpec.describe Migrator do

    subject { described_class.new(checksum_file: checksum_file, files: files, metadata_file: metadata_file,
                                  outfile: outfile) }

    let(:files) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'source', 'changeme-664',
                            'changeme-664-export-file') }
    let(:metadata_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'source', 'changeme-664', 'changeme-664.csv') }
    let(:outdir) { Dir.mktmpdir }
    let(:checksum_file) { File.join(outdir, 'checksums.txt') }
    let(:expected_checksum_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'target', 'changeme-664',
                                             'checksums.txt') }
    let(:outfile) { File.join(outdir, 'manifest.csv') }
    let(:expected_outfile) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'target', 'changeme-664',
                                       'manifest.csv') }

    after { FileUtils.remove_dir outdir }

    it 'produces the expected manifest file' do
      subject.call
      expect(CSV.read(outfile, headers: true)).to eq(CSV.read(expected_outfile, headers: true))
      expect(File.read(checksum_file)).to eq(File.read(expected_checksum_file))
    end

  end
end
