require 'rails_helper'

RSpec.describe 'Licenses', type: :request do
  describe 'GET /licenses' do
    it 'should return two valid versions for half-expired license' do
      test_versions '21.10', '04.07.2021', nil, nil, '["21.06","21.07"]'
    end

    it 'should return max version for half-expired license with version limits' do
      test_versions '20.10', '04.07.2020', '19.01', '20.02', '["20.02"]'
    end

    def test_versions(last_version, paid_till, min_version, max_version, expected)
      expect(FlussonicLastVersion).to receive(:get).and_return(last_version)
      license = License.create paid_till: paid_till, min_version: min_version, max_version: max_version
      get licenses_versions_path, params: { id: license.id }
      expect(response.body).to eq(expected)
    end
  end
end
