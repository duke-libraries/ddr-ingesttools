require 'spec_helper'

module Ddr::IngestTools::DdrRdrMigrator

  RSpec.describe ColumnRenamer do

    subject do
      described_class.new(manifest: manifest)
    end

    let(:ddr_headers) do
      [ 'title', 'alternative', 'creator', 'contributor', 'affiliation', 'publisher', 'date', 'temporal',
        'description', 'subject', 'spatial', 'language', 'type', 'format', 'relation', 'rights',
        'provenance', 'citation', 'permanent_id', 'doi' ]
    end
    let(:rdr_headers) do
      [ 'title', 'alternative', 'creator', 'contributor', 'affiliation', 'publisher', 'available', 'temporal',
        'description', 'subject', 'based_near', 'language', 'resource_type', 'format', 'related_url', 'license',
        'provenance', 'bibliographic_citation', 'ark', 'doi' ]
    end
    let(:data) do
      [ 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't' ]
    end
    let(:manifest) { CSV::Table.new([ CSV::Row.new(ddr_headers, data) ]) }
    let(:expected_manifest) { CSV::Table.new([ CSV::Row.new(rdr_headers, data) ]) }

    it 'renames the appropriate manifest columns' do
      expect(subject.call).to eq(expected_manifest)
    end

  end

end
