require 'spec_helper'

module Ddr::IngestTools::DdrRdrMigrator

  RSpec.describe WorkNester do

    subject { described_class.new(manifest: manifest) }

    let(:ddr_headers) do
      %w[
          pid model title alternative creator contributor affiliation publisher available temporal description
          subject based_near language resource_type format related_url provenance bibliographic_citation
          ark doi license
        ]
    end
    let(:rdr_headers) do
      %w[
          pid model title alternative creator contributor affiliation publisher available temporal description
          subject based_near language resource_type format related_url provenance bibliographic_citation
          ark doi license parent_ark
        ]
    end
    let(:ddr_data) do
      [  %w[ test:1 Collection a b c d e f g h i j k l m n o p q r s t ],
         %w[ test:2 Item aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at ],
         %w[ test:3 Item ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt ]
      ]
    end
    let(:rdr_data) do
      [  %w[ test:1 Collection a b c d e f g h i j k l m n o p q r s t ],
         %w[ test:2 Item aa ab ac ad ae af ag ah ai aj ak al am an ao ap aq ar as at r ],
         %w[ test:3 Item ba bb bc bd be bf bg bh bi bj bk bl bm bn bo bp bq br bs bt r ]
      ]
    end
    let(:manifest) do
      CSV::Table.new([ CSV::Row.new(ddr_headers, ddr_data[0]),
                       CSV::Row.new(ddr_headers, ddr_data[1]),
                       CSV::Row.new(ddr_headers, ddr_data[2])
                     ])
    end
    let(:expected_manifest) do
      CSV::Table.new([ CSV::Row.new(rdr_headers, rdr_data[0]),
                       CSV::Row.new(rdr_headers, rdr_data[1]),
                       CSV::Row.new(rdr_headers, rdr_data[2])
                     ])
    end

    it 'adds and populates the parent ark column' do
      expect(subject.call).to eq(expected_manifest)
    end

  end

end
