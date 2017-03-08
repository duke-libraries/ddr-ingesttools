module Ddr::IngestTools::DpcFolderConverter

  RSpec.describe Converter do

    shared_examples 'a conversion to standard ingest format' do
      subject { described_class.new(*converter_args) }
      it 'produces the correct standard ingest format directory' do
        subject.call
        expect(Array(Find.find(target_directory))).to match_array(expected_files)
        expect(FileUtils.compare_file(File.join(data_directory, 'abc001', 'abc001001.tif'),
                                      File.join(source_directory, 'abc001001.tif'))).to be true
        expect(FileUtils.compare_file(File.join(data_directory, 'abc001', 'abc001002.tif'),
                                      File.join(source_directory, 'abc001002.tif'))).to be true
        expect(FileUtils.compare_file(File.join(data_directory, 'abc002', 'abc002001.tif'),
                                      File.join(source_directory, 'abc002001.tif'))).to be true
        expect(FileUtils.compare_file(File.join(data_directory, 'abc003', 'abc003001.wav'),
                                      File.join(source_directory, 'g', 'abc003001.wav'))).to be true
        expect(FileUtils.compare_file(File.join(data_directory, 'abc003', 'abc003002.wav'),
                                      File.join(source_directory, 'g', 'abc003002.wav'))).to be true
        expect(FileUtils.compare_file(File.join(data_directory, 'dpc_targets', 'T001.tif'),
                                      File.join(source_directory, 'targets', 'T001.tif'))).to be true
        expect(FileUtils.compare_file(File.join(data_directory, 'dpc_targets', 'T002.tif'),
                                      File.join(source_directory, 'targets', 'T002.tif'))).to be true
        metadata_lines = File.readlines(File.join(data_directory, 'metadata.txt')).map(&:strip)
        expect(metadata_lines).to match_array(expected_metadata)
        expect(FileUtils.compare_file(File.join(target_directory, 'manifest-sha1.txt'),
                                      File.join('spec', 'fixtures', 'files', 'manifest-sha1.txt'))).to be true
      end
    end

    let(:source_directory) { Dir.mktmpdir('dpc') }
    let(:target_directory) { Dir.mktmpdir('sif') }
    let(:data_directory) { File.join(target_directory, 'data') }
    let(:item_id_length) { 6 }
    let(:converter_args) { [ source_directory, target_directory, item_id_length ] }
    let(:expected_files) { [
        target_directory,
        File.join(target_directory, 'bag-info.txt'),
        File.join(target_directory, 'bagit.txt'),
        data_directory,
        File.join(data_directory, 'abc001'),
        File.join(data_directory, 'abc001', 'abc001001.tif'),
        File.join(data_directory, 'abc001', 'abc001002.tif'),
        File.join(data_directory, 'abc002'),
        File.join(data_directory, 'abc002', 'abc002001.tif'),
        File.join(data_directory, 'abc003', 'abc003001.wav'),
        File.join(data_directory, 'abc003'),
        File.join(data_directory, 'abc003', 'abc003002.wav'),
        File.join(data_directory, 'dpc_targets'),
        File.join(data_directory, 'dpc_targets', 'T001.tif'),
        File.join(data_directory, 'dpc_targets', 'T002.tif'),
        File.join(data_directory, 'metadata.txt'),
        File.join(target_directory, 'manifest-md5.txt'),
        File.join(target_directory, 'manifest-sha1.txt'),
        File.join(target_directory, 'tagmanifest-md5.txt'),
        File.join(target_directory, 'tagmanifest-sha1.txt')
    ] }
    let(:expected_metadata) { [
        "path\tlocal_id",
        "abc001\tabc001",
        "abc002\tabc002",
        "abc003\tabc003",
        "abc001/abc001001.tif\tabc001001",
        "abc001/abc001002.tif\tabc001002",
        "abc002/abc002001.tif\tabc002001",
        "abc003/abc003001.wav\tabc003001",
        "abc003/abc003002.wav\tabc003002",
        "dpc_targets/T001.tif\tT001",
        "dpc_targets/T002.tif\tT002"
    ] }

    before do
      File.open(File.join(source_directory, 'Thumbs.db'), 'w') { |f| f.write('Thumbs') }
      File.open(File.join(source_directory, 'abc001001.tif'), 'w') { |f| f.write('abc001001') }
      File.open(File.join(source_directory, 'abc001002.tif'), 'w') { |f| f.write('abc001002') }
      File.open(File.join(source_directory, 'abc002001.tif'), 'w') { |f| f.write('abc002001') }
      File.open(File.join(source_directory, 'checksums.txt'), 'w') { |f| f.write('checksums') }
      Dir.mkdir(File.join(source_directory,'g'))
      File.open(File.join(source_directory, 'g', 'abc003001.wav'), 'w') { |f| f.write('abc003001') }
      File.open(File.join(source_directory, 'g', 'abc003002.wav'), 'w') { |f| f.write('abc003002') }
      Dir.mkdir(File.join(source_directory,'targets'))
      File.open(File.join(source_directory, 'targets', 'T001.tif'), 'w') { |f| f.write('T001') }
      File.open(File.join(source_directory, 'targets', 'T002.tif'), 'w') { |f| f.write('T002') }
    end

    describe 'files are copied' do
      before { converter_args << true }
      it_behaves_like 'a conversion to standard ingest format'
    end

    describe 'files are not copied' do
      before { converter_args << false }
      it_behaves_like 'a conversion to standard ingest format'
    end

  end
end
