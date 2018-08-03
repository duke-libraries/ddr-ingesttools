#!/usr/bin/env ruby

require 'i18n'
require 'ddr/ingesttools'
require 'optparse'

options = {}

puts I18n.t('marquee')
puts I18n.t('suite.name')
puts I18n.t('ddr_rdr_migrator.name')
puts I18n.t('marquee')

# Parse command line arguments
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: migrate_ddr_to_rdr.rb [options]'

  opts.on('-f', '--files FILE_PATH', 'Path to exported files') do |v|
    options[:files] = v
  end

  opts.on('-m', '--metadata METADATA_FILE', 'Path to DDR metadata export file') do |v|
    options[:metadata] = v
  end

  opts.on('-o', '--outfile OUTPUT_FILE', 'Path to which updated manifest file should be written') do |v|
    options[:outfile] = v
  end

end

begin
  parser.parse!
  mandatory = [ :files, :metadata, :outfile ]
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
