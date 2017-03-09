#!/usr/bin/env ruby

require 'ddr/ingesttools'
require 'optparse'

options = {}

# Default options
options[:copy] = false

# Parse command line arguments
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: convert_dpc_folder.rb [options]'

  opts.on('-s', '--source SOURCE', 'Path to DPC Folder to be converted') do |v|
    options[:source] = v
  end

  opts.on('-t', '--target TARGET', 'Path to folder where Standard Ingest Format is to be built') do |v|
    options[:target] = v
  end

  opts.on('-i', '--item_id_length LENGTH', Integer, 'Number of characters to copy from the beginning of each file name',
          'to use as the local ID of the item of which that file is a component') do |v|
    options[:item_id_length] = v
  end

  opts.on('-c', '--checksums [CHECKSUM_FILE]', 'External checksum file') do |v|
    options[:checksums] = v
  end

  opts.on('--[no-]copy', 'Copy files to target location instead of using a symlink') do |v|
    options[:copy] = v
  end
end

begin
  parser.parse!
  mandatory = [ :source, :target, :item_id_length]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts parser
  exit(false)
end

converter_args = [ options[:source], options[:target], options[:item_id_length], options[:checksums], options[:copy] ]
converter = Ddr::IngestTools::DpcFolderConverter::Converter.new(*converter_args)
results = converter.call
puts I18n.translate('errors.count', { count: results.errors.size })
results.errors.each { |e| puts e }
