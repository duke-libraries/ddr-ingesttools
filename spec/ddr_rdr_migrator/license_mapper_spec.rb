require 'spec_helper'

module Ddr::IngestTools::DdrRdrMigrator

  RSpec.describe LicenseMapper do

    subject { described_class.new(manifest: manifest) }

    let(:headers) do
      %w[ pid model title license ]
    end
    let(:ddr_data) do
      [  %w[ test:1 Collection a https://creativecommons.org/licenses/by-nc/4.0/ ],
         %w[ test:2 Item aa https://creativecommons.org/publicdomain/zero/1.0/ ],
         %w[ test:3 Item ba https://creativecommons.org/licenses/by/4.0/ ]
      ]
    end
    let(:rdr_data) do
      [  %w[ test:1 Collection a https://creativecommons.org/licenses/by-nc/4.0/ ],
         %w[ test:2 Item aa http://creativecommons.org/publicdomain/zero/1.0/ ],
         %w[ test:3 Item ba https://creativecommons.org/licenses/by/4.0/ ]
      ]
    end
    let(:manifest) do
      CSV::Table.new([ CSV::Row.new(headers, ddr_data[0]),
                       CSV::Row.new(headers, ddr_data[1]),
                       CSV::Row.new(headers, ddr_data[2])
                     ])
    end
    let(:expected_manifest) do
      CSV::Table.new([ CSV::Row.new(headers, rdr_data[0]),
                       CSV::Row.new(headers, rdr_data[1]),
                       CSV::Row.new(headers, rdr_data[2])
                     ])
    end

    it 'overwrites the appropriate manifest cells' do
      expect(subject.call).to eq(expected_manifest)
    end

  end

end
