require 'spec_helper'

module Ddr::IngestTools::ManifestArkMinter

  RSpec.describe ManifestParser do

    subject { described_class.new(manifest_file) }

    describe '#as_csv_table' do
      let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_some_arks.csv') }
      specify { expect(subject.as_csv_table).to be_a CSV::Table }
    end

    describe '#headers' do
      let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_some_arks.csv') }
      let(:expected_headers) { %w(ark visibility title contributor resource_type license file) }
      it 'parses out the list of headers' do
        expect(subject.headers).to include(*expected_headers)
      end
    end

    describe '#arks_missing?' do
      describe 'no arks assigned' do
        let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_no_arks.csv') }
        specify { expect(subject.arks_missing?).to be true }
      end
      describe 'some arks assigned' do
        let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_some_arks.csv') }
        specify { expect(subject.arks_missing?).to be true }
      end
      describe 'all arks assigned' do
        let(:manifest_file) { File.join('spec', 'fixtures', 'rdr_importer', 'manifests', 'manifest_with_all_arks.csv') }
        specify { expect(subject.arks_missing?).to be false }
      end
    end
  end

end
