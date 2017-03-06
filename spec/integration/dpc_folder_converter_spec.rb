module Ddr::IngestTools::DpcFolderConverter

  RSpec.describe Converter do

    let(:source_directory) { Dir.mktmpdir('dpc') }
    let(:target_directory) { Dir.mktmpdir('sif') }
    let(:item_id_length) { 6 }
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

    subject { Converter.new(source_directory, target_directory, item_id_length) }

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

    it 'produces the correct standard ingest format directory' do
      subject.call
      expect(Dir.entries(target_directory)).to match_array([ '.', '..', 'abc001', 'abc002', 'abc003', 'dpc_targets', 'metadata.txt' ])
      expect(Dir.entries(File.join(target_directory, 'abc001'))).to match_array([ '.', '..', 'abc001001.tif', 'abc001002.tif' ])
      expect(Dir.entries(File.join(target_directory, 'abc002'))).to match_array([ '.', '..', 'abc002001.tif' ])
      expect(Dir.entries(File.join(target_directory, 'abc003'))).to match_array([ '.', '..', 'abc003001.wav', 'abc003002.wav' ])
      expect(Dir.entries(File.join(target_directory, 'dpc_targets'))).to match_array([ '.', '..', 'T001.tif', 'T002.tif' ])
      expect(FileUtils.compare_file(File.join(target_directory, 'abc001', 'abc001001.tif'),
                                    File.join(source_directory, 'abc001001.tif'))).to be true
      expect(FileUtils.compare_file(File.join(target_directory, 'abc001', 'abc001002.tif'),
                                    File.join(source_directory, 'abc001002.tif'))).to be true
      expect(FileUtils.compare_file(File.join(target_directory, 'abc002', 'abc002001.tif'),
                                    File.join(source_directory, 'abc002001.tif'))).to be true
      expect(FileUtils.compare_file(File.join(target_directory, 'abc003', 'abc003001.wav'),
                                    File.join(source_directory, 'g', 'abc003001.wav'))).to be true
      expect(FileUtils.compare_file(File.join(target_directory, 'abc003', 'abc003002.wav'),
                                    File.join(source_directory, 'g', 'abc003002.wav'))).to be true
      expect(FileUtils.compare_file(File.join(target_directory, 'dpc_targets', 'T001.tif'),
                                    File.join(source_directory, 'targets', 'T001.tif'))).to be true
      expect(FileUtils.compare_file(File.join(target_directory, 'dpc_targets', 'T002.tif'),
                                    File.join(source_directory, 'targets', 'T002.tif'))).to be true
      metadata_lines = File.readlines(File.join(target_directory, 'metadata.txt')).map(&:strip)
      expect(metadata_lines).to match_array(expected_metadata)
    end

  end
end
