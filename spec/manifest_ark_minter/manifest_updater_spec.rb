require 'spec_helper'
require 'tempfile'

module Ddr::IngestTools::ManifestArkMinter

  RSpec.describe ManifestUpdater do

    subject { described_class.new(config: config_file, manifest: manifest_file, output: output_file) }

    let(:config_file) { File.join('spec', 'fixtures', 'rdr_importer', 'configs', 'default.yml') }
    let(:output_dir) { Dir.mktmpdir }
    let(:output_file) { File.join(output_dir, 'output.csv') }

    after { FileUtils.remove_dir output_dir }

    describe 'manifest has ARKs for all rows' do
      let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_all_arks.csv') }
      it 'does not produce an output file' do
        expect{ subject.call }.not_to change{ File.exist?(output_file) }
      end
    end

    describe 'manifest has ARKs for some rows' do
      let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_some_arks.csv') }
      it 'mints ARKs for rows without them' do
        expect_any_instance_of(Minter).to receive(:mint).exactly(2).times.and_call_original
        subject.call
        table = CSV.read(output_file, headers: true)
        # expect(table['ark']).to all(match(/ark:\/99999\/fk4/))
        expect(table['ark']).to match([ /ark:\/99999\/fk4/, 'ark:/99999/fk4ng5vp6m', /ark:\/99999\/fk4/ ])
      end
    end

    describe 'manifest has ARKs for no rows' do
      let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_no_arks.csv') }
      it 'mints ARKs for every row' do
        expect_any_instance_of(Minter).to receive(:mint).exactly(3).times.and_call_original
        subject.call
        table = CSV.read(output_file, headers: true)
        expect(table['ark']).to all(match(/ark:\/99999\/fk4/))
      end
    end

  end

end
