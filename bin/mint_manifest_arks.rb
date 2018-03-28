#!/usr/bin/env ruby

require 'i18n'
require 'ddr/ingesttools'
require 'optparse'

options = {}

puts I18n.t('marquee')
puts I18n.t('suite.name')
puts I18n.t('manifest_ark_minter.name')
puts I18n.t('marquee')

# Parse command line arguments
parser = OptionParser.new do |opts|
  opts.banner = 'Usage: mint_manifest_arks.rb [options]'

  opts.on('-c', '--config CONFIG_FILE', 'Path to configuration file') do |v|
    options[:config] = v
  end

  opts.on('-m', '--manifest MANIFEST_FILE', 'Path to manifest file for which ARKs are to be minted') do |v|
    options[:manifest] = v
  end

  opts.on('-o', '--output OUTPUT_FILE', 'Path to which updated manifest file should be written') do |v|
    options[:output] = v
  end
end

begin
  parser.parse!
  if options['config'].nil?
    puts I18n.t('manifest_ark_minter.use_default_config_file',
                default_config_file: Ddr::IngestTools::ManifestArkMinter::ManifestUpdater::DEFAULT_CONFIG_FILE)
  end
  mandatory = [ :manifest, :output ]
  missing = mandatory.select{ |param| options[param].nil? }
  unless missing.empty?
    raise OptionParser::MissingArgument.new(missing.join(', '))
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts parser
  exit(false)
end

updater = Ddr::IngestTools::ManifestArkMinter::ManifestUpdater.new(options)
updater.call
