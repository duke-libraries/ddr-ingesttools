require_relative 'ingesttools/version'
require_relative 'ingesttools/manifest_ark_minter'

require 'i18n'

module Ddr
  module IngestTools

    I18n.load_path = Dir[File.join(Gem.loaded_specs['ddr-ingesttools'].gem_dir, 'config', 'locales', '*.yml')]

  end
end
