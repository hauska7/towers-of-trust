require "rails_helper"

RSpec.describe MainController, type: :controller do
  render_views

  it 'main' do
    donald = X.fixture.get("donald")

    get :main
  end

  it 'show_user' do
    donald = X.fixture.get("donald")

    get :show_user, params: { user_id: donald.id }

    the_spirit = X.fixture.get("the_spirit")

    controller.sign_in the_spirit

    get :show_user, params: { user_id: donald.id }
    get :show_user, params: { user_id: the_spirit.id }
  end

  it 'show_group' do
    group = X.fixture.get("group")

    # no members
    get :show_group, params: { group_id: group.id }

    # with members
    the_spirit = X.fixture.get("the_spirit")
    X.services.join_group(group, the_spirit) || fail

    get :show_group, params: { group_id: group.id }
  end

  it 'do_trust' do
    fixture = X.fixture
    donald = fixture.get("donald")
    the_spirit = fixture.get("the_spirit")
    group = fixture.get("group")
    X.services.join_group(group, donald)
    X.services.join_group(group, the_spirit)
    donald_gmember = group.query_gmember(donald)
    the_spirit_gmember = group.query_gmember(the_spirit)

    controller.sign_in the_spirit

    post :do_trust, params: { mode: "regular", trustee_id: donald_gmember.id }

    expect(Trust.count).to eq 1
    trust = Trust.first!
    expect(trust.active?).to be true
    expect(trust.trustee).to eq donald_gmember
    expect(trust.truster).to eq the_spirit_gmember
    expect(trust.group).to eq group
    expect(the_spirit_gmember.reload.trust_count).to eq 0
    expect(donald_gmember.reload.trust_count).to eq 1

    post :do_trust, params: { mode: "regular", trustee_id: donald_gmember.id }

    expect(Trust.count).to eq 2
    expect(trust.reload.expired?).to be true
    trust_2 = Trust.last
    expect(trust_2.active?).to be true
    expect(trust_2.trustee).to eq donald_gmember
    expect(trust_2.truster).to eq the_spirit_gmember
    expect(trust_2.group).to eq group
    expect(the_spirit_gmember.reload.trust_count).to eq 0
    expect(donald_gmember.reload.trust_count).to eq 1

    controller.sign_out
    controller.sign_in donald

    post :do_trust, params: { mode: "regular", trustee_id: the_spirit_gmember.id }

    expect(Trust.count).to eq 3
    expect(trust_2.reload.expired?).to be true
    trust_3 = Trust.last
    expect(trust_3.active?).to be true
    expect(trust_3.trustee).to eq the_spirit_gmember
    expect(trust_3.truster).to eq donald_gmember
    expect(trust_3.group).to eq group
    expect(donald_gmember.reload.trust_count).to eq 0
    expect(the_spirit_gmember.reload.trust_count).to eq 1

    post :do_trust, params: { mode: "regular", trustee_id: donald_gmember.id }

    expect(Trust.count).to eq 4
    expect(trust_3.reload.expired?).to be true
    trust_4 = Trust.last
    expect(trust_4.active?).to be true
    expect(trust_4.trustee).to eq donald_gmember
    expect(trust_4.truster).to eq donald_gmember
    expect(trust_4.group).to eq group
    expect(donald_gmember.reload.trust_count).to eq 1
    expect(the_spirit_gmember.reload.trust_count).to eq 0

    post :do_trust, params: { mode: "back", trust_id: donald_gmember.current_trust.id }

    expect(Trust.count).to eq 4
    expect(trust_4.reload.expired?).to be true
    expect(donald_gmember.reload.trust_count).to eq 0
    expect(the_spirit_gmember.reload.trust_count).to eq 0
  end

  it 'create_group' do
    the_spirit = X.fixture.get("the_spirit")

    controller.sign_in the_spirit

    post :do_create, params: { mode: "group", group: { name: "A nice group" } }

    expect(Group.count).to eq 1
    group = Group.first!
    expect(group.name).to eq "A nice group"
    expect(group.moderator).to eq the_spirit
  end

  it 'join group' do
    the_spirit = X.fixture.get("the_spirit")

    controller.sign_in the_spirit

    group = X.fixture.get("group")

    expect(group.all_members?([the_spirit])).to be false

    post :do_create, params: { mode: "group_membership", group_id: group.id }

    expect(group.reload.member?(the_spirit)).to be true
  end

  it 'leave group' do
    the_spirit = X.fixture.get("the_spirit")

    controller.sign_in the_spirit

    group = X.fixture.get("group")

    X.services.join_group(group, the_spirit)

    gmember = group.query_gmember(the_spirit) || fail

    post :do_destroy, params: { mode: "group_membership", group_membership_id: gmember.id }

    expect(group.reload.member?(the_spirit)).to be false
  end
end