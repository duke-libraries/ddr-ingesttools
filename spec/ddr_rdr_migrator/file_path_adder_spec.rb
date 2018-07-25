require 'spec_helper'

module Ddr::IngestTools::DdrRdrMigrator

  RSpec.describe FilePathAdder do

    subject do
      described_class.new(base_path: base_path, files_subpath: files_subpath, manifest: manifest)
    end

    let(:base_path) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'source') }
    let(:files_subpath) { File.join('changeme-664', 'changeme-664-export-file') }
    let(:manifest_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'manifests', 'sorted_manifest.csv') }
    let(:manifest) { CSV.read(manifest_file, headers: true) }
    let(:expected_manifest_file) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'manifests',
                                             'sorted_manifest_with_file_paths.csv') }
    let(:expected_manifest) { CSV.read(expected_manifest_file, headers: true) }

    it 'adds the appropriate file paths to the manifest' do
      expect(subject.call).to eq(expected_manifest)
    end

  end

end
