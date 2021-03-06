require 'spec_helper'

describe Ldap::SyncJob do
  subject(:group) do
    create(:cms_group, name: unique_id, ldap_host: ENV["ldap_host"],
           ldap_dn: "dc=city,dc=shirasagi,dc=jp", ldap_auth_method: "anonymous")
  end
  subject(:item) { create(:ldap_import) }
  subject { Ldap::SyncJob.new }

  describe "#call" do
    it do
      expect { subject.call(group.id, item.id) }.not_to raise_error
      expect(subject.results).not_to be_nil
    end
  end
end
