require 'rails_helper'

RSpec.describe BuildController, type: :controller do
  render_views

  describe '#result' do
    it 'requires login' do
      get :result, params: { project: 'home:Iggy', format: 'xml' }
      expect(response).to have_http_status(401)
    end

    context 'with login' do
      let(:user) { create(:confirmed_user) }

      before do
        login(user)
      end

      it 'raises 404 on non-existant project' do
        get :result, params: { project: 'Wontbethere', format: 'xml' }
        expect(response).to have_http_status(404)
        assert_select 'status[code="unknown_project"]' do
          assert_select 'summary', 'Wontbethere'
        end
      end

      context 'with lastsuccess' do
        let(:distro) { create(:project) }
        let(:distro_repo) { create(:repository, project: distro, architectures: ['i586']) }
        let(:project) { create(:project, name: 'build_project') }
        let(:package) { create(:package, project: project) }
        let(:repo) { create(:repository, project: project, architectures: ['i586']) }

        before do
          repo.path_elements.create(link: distro_repo)
          project.store
        end

        it 'raises 400 on missing parameters' do
          get :result, params: { project: project, lastsuccess: 1, format: 'xml' }
          expect(response).to have_http_status(400)
          assert_select 'status', 'Required Parameter package missing'
        end

        it 'raises 404 on wrong package' do
          get :result, params: { project: project, package: 'wontbethere', pathproject: 'distro', lastsuccess: 1, format: 'xml' }
          expect(response).to have_http_status(404)
        end

        it 'raises 200 on wrong package', vcr: true do
          get :result, params: { project: project, package: package.name, pathproject: distro.name, lastsuccess: 1, format: 'xml' }
          expect(response).to have_http_status(404)
          puts response.body
        end
      end
    end
  end
end
