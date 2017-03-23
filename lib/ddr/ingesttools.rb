require_relative 'ingesttools/version'
require_relative 'ingesttools/dpc_folder_converter'
require_relative 'ingesttools/checksum_file'

require 'i18n'

module Ddr
  module IngestTools

    I18n.load_path = Dir['config/locales/*.yml']

  end
end
