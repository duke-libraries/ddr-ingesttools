require 'ddr/ingesttools'

namespace :ingest_tools do
  namespace :dpc_folder do
    desc 'Convert DPC folder to Standard Ingest format'
    task :convert do
      raise 'Must specify source folder path. Ex.: SOURCE=/path/to/source/files' unless ENV['SOURCE']
      raise 'Must specify target folder path. Ex.: TARGET=/path/to/source/files' unless ENV['TARGET']
      unless ENV['ITEM_ID_LENGTH']
        puts "***WARNING: 'ITEM_ID_LENGTH' not provided.  Will create an 'item' folder for each component file."
      end
      converter_args = [ ENV['SOURCE'], ENV['TARGET'] ]
      converter_args << ENV['ITEM_ID_LENGTH'].to_i if ENV['ITEM_ID_LENGTH']
      converter = Ddr::IngestTools::DpcFolderConverter::Converter.new(*converter_args)
      converter.call
    end
  end
end
