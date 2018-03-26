require 'spec_helper'

module Ddr::IngestTools::ManifestArkMinter

  RSpec.describe Minter do

    describe '#initialize' do
      describe 'Ezid::Identifier defaults' do
        before { described_class.new }
        let(:ark_defaults) { { export: described_class::DEFAULT_EXPORT,
                               profile: described_class::DEFAULT_PROFILE,
                               status: described_class::DEFAULT_STATUS } }
        it 'configures Ezid::Identifer defaults' do
          expect(Ezid::Identifier.defaults).to match(ark_defaults)
        end
      end
      describe 'Ezid::Client configuration' do
        let(:configuration) { Configuration.new }
        before do
          configuration.ezid_default_shoulder = 'ark:/99999/fk4'
          configuration.ezid_password = 'apitest'
          configuration.ezid_user = 'apitest'
          allow(Ddr::IngestTools::ManifestArkMinter).to receive(:configuration) { configuration }
          described_class.new
        end
        it 'configures the Ezid::Client' do
          expect(Ezid::Client.config.default_shoulder).to eq('ark:/99999/fk4')
          expect(Ezid::Client.config.password).to eq('apitest')
          expect(Ezid::Client.config.user).to eq('apitest')
        end
      end
    end

    describe '#mint' do
      let(:configuration) { Configuration.new }
      before do
        configuration.ezid_default_shoulder = 'ark:/99999/fk4'
        configuration.ezid_password = 'apitest'
        configuration.ezid_user = 'apitest'
        allow(Ddr::IngestTools::ManifestArkMinter).to receive(:configuration) { configuration }
      end
      it 'calls Ezid::Identifier to mint an ark' do
        expect(Ezid::Identifier).to receive(:mint)
        subject.mint
      end
    end

  end

end
