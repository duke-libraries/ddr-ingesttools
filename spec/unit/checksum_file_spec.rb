module Ddr::IngestTools

  RSpec.describe ChecksumFile do

    subject { described_class.new(checksum_filepath) }

    let(:checksum_filepath) { File.join('spec', 'fixtures', 'files', 'manifest-sha1.txt') }

    describe 'digest' do
      it 'provides the requested digest' do
        expect(subject.digest('data/abc001/abc001002.tif')).to eq('d0a2f2482783ae3c38d06f3cdeaa1a306cc043ad')
        expect(subject.digest('not/in/checksum/file.txt')).to be nil
      end
    end
  end

end
