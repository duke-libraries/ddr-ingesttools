require 'spec_helper'

module Ddr::IngestTools::DdrRdrMigrator

  RSpec.describe ColumnRemover do

    subject { described_class.new(manifest: manifest) }

    let(:ddr_headers) do
      [ 'pid', 'model', 'title', 'alternative', 'creator', 'contributor', 'affiliation', 'publisher', 'date',
        'temporal', 'description', 'subject', 'spatial', 'language', 'type', 'format', 'relation', 'rights',
        'provenance', 'bibliographicCitation', 'permanent_id', 'doi' ]
    end
    let(:rdr_headers) do
      [ 'title', 'alternative', 'creator', 'contributor', 'affiliation', 'publisher', 'date', 'temporal',
        'description', 'subject', 'spatial', 'language', 'type', 'format', 'relation', 'rights', 'provenance',
        'bibliographicCitation', 'permanent_id', 'doi' ]
    end
    let(:ddr_data) do
      [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v' ]
    end
    let(:rdr_data) do
      [ 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v' ]
    end
    let(:manifest) { CSV::Table.new([ CSV::Row.new(ddr_headers, ddr_data) ]) }
    let(:expected_manifest) { CSV::Table.new([ CSV::Row.new(rdr_headers, rdr_data) ]) }

    it 'removes the appropriate manifest columns' do
      expect(subject.call).to eq(expected_manifest)
    end

  end

end
