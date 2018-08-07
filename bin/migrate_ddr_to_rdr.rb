#!/usr/bin/env ruby

require 'i18n'
require 'ddr/ingesttools'
require 'optparse'

options = {}

puts I18n.t('marquee')
puts I18n.t('suite.name', version: Ddr::IngestTools::VERSION)
puts I18n.t('ddr_rdr_migrator.name')
puts I18n.t('marquee')

# Parse command line arguments
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: migrate_ddr_to_rdr.rb [options]'

  opts.on('-c', '--checksum_file CHECKSUM_FILE', 'File (with full path) to which checksum file should be written') do |v|
    options[:checksum] = v
  end

  opts.on('-f', '--files FILE_PATH', 'Path to exported files') do |v|
    options[:files] = v
  end

  opts.on('-m', '--metadata_file METADATA_FILE', 'DDR metadata export file (with full path)') do |v|
    options[:metadata] = v
  end

  opts.on('-o', '--outfile OUTPUT_FILE', 'File (with full path) to which updated manifest file should be written') do |v|
    options[:outfile] = v
  end

end

begin
  parser.parse!
  mandatory = [ :checksum_file, :files, :metadata_file, :outfile ]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts parser
  exit(false)
end

migrator = Ddr::IngestTools::DdrRdrMigrator::Migrator.new(options)
migrator.call
