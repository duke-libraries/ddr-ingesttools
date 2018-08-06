require 'spec_helper'
require 'tempfile'

module Ddr::IngestTools::DdrRdrMigrator

  RSpec.describe FilePathAdder do

    subject do
      described_class.new(checksum_file: checksum_file, files: files, manifest: manifest)
    end

    let(:files) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'source', 'changeme-664',
                            'changeme-664-export-file') }
    let(:manifest_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'manifests', 'sorted_manifest.csv') }
    let(:manifest) { CSV.read(manifest_file, headers: true) }
    let(:expected_manifest_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'manifests',
                                             'sorted_manifest_with_file_paths.csv') }
    let(:expected_manifest) { CSV.read(expected_manifest_file, headers: true) }
    let(:outdir) { Dir.mktmpdir }
    let(:checksum_file) { File.join(outdir, 'checksums.txt') }
    let(:expected_checksum_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'target', 'changeme-664',
                                             'checksums.txt') }

    after { FileUtils.remove_dir outdir }

    it 'adds the appropriate file paths to the manifest' do
      expect(subject.call).to eq(expected_manifest)
    end

    it 'creates a checksum file' do
      subject.call
      expect(File.read(checksum_file)).to eq(File.read(expected_checksum_file))
    end
  end

end
