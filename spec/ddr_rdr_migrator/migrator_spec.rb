require 'spec_helper'
require 'tempfile'

module Ddr::IngestTools::DdrRdrMigrator
  RSpec.describe Migrator do

    subject { described_class.new(files: files, metadata: metadata, outfile: outfile) }

    let(:files) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'source', 'changeme-664',
                            'changeme-664-export-file') }
    let(:metadata) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'source', 'changeme-664', 'changeme-664.csv') }
    let(:outdir) { Dir.mktmpdir }
    let(:outfile) { File.join(outdir, 'manifest.csv') }
    let(:expected_outfile) { File.join('spec', 'fixtures', 'ddr_rdr_migrator', 'target', 'changeme-664',
                                       'manifest.csv') }

    after { FileUtils.remove_dir outdir }

    it 'produces the expected manifest file' do
      subject.call
      expect(CSV.read(outfile, headers: true)).to eq(CSV.read(expected_outfile, headers: true))
    end

  end
end
