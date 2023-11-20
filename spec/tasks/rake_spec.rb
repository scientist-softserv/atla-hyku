# frozen_string_literal: true

require 'rake'
load 'app/models/site.rb'

RSpec.describe "Rake tasks" do
  before(:all) do
    Rails.application.load_tasks
  end

  describe "hyku:upgrade:clean_migrations" do
    it 'requires a datesub argument'

    it 'removes unnecessary migrations' do
      original_migrations = Dir.glob(Rails.root.join('db', 'migrate', '*.rb'))
      time = Time.now.utc.strftime("%Y%m%d%H")
      run_task('hyrax:install:migrations')
      run_task('hyku:upgrade:clean_migrations', time)
      new_migrations = Dir.glob(Rails.root.join('db', 'migrate', '*.rb'))
      expect(new_migrations).to eq(original_migrations)
    end
  end

  describe "superadmin:grant" do
    let!(:user1) { FactoryBot.create(:user) }
    let!(:user2) { FactoryBot.create(:user) }

    before do
      user1.remove_role :superadmin
      user2.remove_role :superadmin
    end

    it 'requires user_list argument' do
      expect { run_task('hyku:superadmin:grant') }.to raise_error(ArgumentError)
    end

    it 'warns when a user is not found' do
      expect(run_task('hyku:superadmin:grant', 'missing@example.org')).to include 'Could not find user'
    end

    it 'grants a single user the superadmin role' do
      run_task('hyku:superadmin:grant', user1.email)
      expect(user1.has_role?(:superadmin)).to eq true
      expect(user2.has_role?(:superadmin)).to eq false
    end

    it 'grants a multiple users the superadmin role' do
      run_task('hyku:superadmin:grant', user1.email, user2.email)
      expect(user1.has_role?(:superadmin)).to eq true
      expect(user2.has_role?(:superadmin)).to eq true
    end
  end

  describe 'tenantize:task' do
    let(:accounts) { [Account.new(name: 'first'), Account.new(name: 'second')] }
    let(:task) { double('task') }

    before do
      # This omits a tenant that appears automatically created and is not switch-intoable
      allow(Account).to receive(:tenants).and_return(accounts)
    end

    it 'requires at least one argument' do
      expect { run_task('tenantize:task') }.to raise_error(ArgumentError, /rake task name is required/)
    end

    it 'requires first argument to be a valid rake task' do
      expect { run_task('tenantize:task', 'foobar') }.to raise_error(ArgumentError, /Rake task not found\: foobar/)
    end

    it 'runs against all tenants' do
      accounts.each do |account|
        expect(account).to receive(:switch).once.and_call_original
      end
      allow(Rake::Task).to receive(:[]).with('hyrax:count').and_return(task)
      expect(task).to receive(:invoke).exactly(accounts.count).times
      expect(task).to receive(:reenable).exactly(accounts.count).times
      run_task('tenantize:task', 'hyrax:count')
    end

    context 'when run against specified tenants' do
      let(:account) { accounts[0] }

      before do
        ENV['tenants'] = "garbage_value #{account.cname} other_garbage_value"
        allow(Account).to receive(:tenants).with(ENV['tenants'].split).and_return([account])
      end

      after do
        ENV.delete('tenants')
      end

      it 'runs against a single tenant and ignores bogus tenants' do
        expect(account).to receive(:switch).once.and_call_original
        allow(Rake::Task).to receive(:[]).with('hyrax:count').and_return(task)
        expect(task).to receive(:invoke).once
        expect(task).to receive(:reenable).once
        run_task('tenantize:task', 'hyrax:count')
      end
    end
  end

  # This code is copied from https://github.com/samvera/hyrax/pull/6241 to solve https://github.com/scientist-softserv/atla-hyku/issues/121
  describe "hyrax:embargo:deactivate_expired", :clean_repo do
    let!(:active) do
      [FactoryBot.valkyrie_create(:hyrax_work, :under_embargo),
       FactoryBot.valkyrie_create(:hyrax_work, :under_embargo)]
    end

    let!(:expired) do
      [FactoryBot.valkyrie_create(:hyrax_work, :with_expired_enforced_embargo),
       FactoryBot.valkyrie_create(:hyrax_work, :with_expired_enforced_embargo)]
    end

    before do
      load_rake_environment [File.expand_path("../../../lib/tasks/embargo_lease.rake", __FILE__)]
    end

    it "adds embargo history for expired embargoes" do
      expect { run_task 'hyrax:embargo:deactivate_expired' }
        .to change {
          Hyrax.query_service.find_many_by_ids(ids: expired.map(&:id))
               .map { |work| work.embargo.embargo_history }
        }
        .from(contain_exactly(be_empty, be_empty))
        .to(contain_exactly([start_with('An expired embargo was deactivated')],
                            [start_with('An expired embargo was deactivated')]))
    end

    it "updates the persisted work ACLs for expired embargoes" do
      expect { run_task 'hyrax:embargo:deactivate_expired' }
        .to change {
          Hyrax.query_service.find_many_by_ids(ids: expired.map(&:id))
               .map { |work| work.permission_manager.read_groups.to_a }
        }
        .from([contain_exactly('registered'), contain_exactly('registered')])
        .to([include('public'), include('public')])
    end

    it "updates the persisted work visibility for expired embargoes" do
      expect { run_task 'hyrax:embargo:deactivate_expired' }
        .to change {
          Hyrax.query_service.find_many_by_ids(ids: expired.map(&:id))
               .map(&:visibility)
        }
        .from(['authenticated', 'authenticated'])
        .to(['open', 'open'])
    end

    it "does not update visibility for works with active embargoes" do
      expect { run_task 'hyrax:embargo:deactivate_expired' }
        .not_to change {
          Hyrax.query_service.find_many_by_ids(ids: active.map(&:id))
               .map(&:visibility)
        }
        .from(['authenticated', 'authenticated'])
    end

    it "removes the work from Hyrax::EmbargoHelper.assets_under_embargo" do
      helper = Class.new { include Hyrax::EmbargoHelper }

      # this helper is the source of truth for listing currently enforced embargoes for the UI
      expect { run_task 'hyrax:embargo:deactivate_expired' }
        .to change { helper.new.assets_under_embargo }
        .from(contain_exactly(*(active + expired).map { |work| have_attributes(id: work.id) }))
        .to(contain_exactly(*active.map { |work| have_attributes(id: work.id) }))
    end
  end
end
