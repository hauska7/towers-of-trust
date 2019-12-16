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

  it 'do_vote' do
    fixture = X.fixture
    donald = fixture.get("donald")
    the_spirit = fixture.get("the_spirit")
    group = fixture.get("group")
    X.services.join_group(group, donald)
    X.services.join_group(group, the_spirit)

    controller.sign_in the_spirit

    post :do_trust, params: { mode: "regular", trustee_id: donald.id, group_id: group.id }

    expect(Vote.count).to eq 1
    vote = Vote.first!
    expect(vote.active?).to be true
    expect(vote.person).to eq donald
    expect(vote.voter).to eq the_spirit
    expect(vote.group).to eq group
    the_spirit_membership = group.query_membership(the_spirit)
    expect(the_spirit_membership.trust_count).to eq 0
    donald_membership = group.query_membership(donald)
    expect(donald_membership.trust_count).to eq 1

    post :do_trust, params: { mode: "regular", trustee_id: donald.id, group_id: group.id }

    expect(Vote.count).to eq 2
    expect(vote.reload.expired?).to be true
    vote_2 = Vote.last
    expect(vote_2.active?).to be true
    expect(vote_2.person).to eq donald
    expect(vote_2.voter).to eq the_spirit
    expect(vote_2.group).to eq group
    expect(the_spirit_membership.reload.trust_count).to eq 0
    expect(donald_membership.reload.trust_count).to eq 1

    controller.sign_out
    controller.sign_in donald

    post :do_trust, params: { mode: "regular", trustee_id: the_spirit.id, group_id: group.id }

    expect(Vote.count).to eq 3
    expect(vote_2.reload.expired?).to be true
    vote_3 = Vote.last
    expect(vote_3.active?).to be true
    expect(vote_3.person).to eq the_spirit
    expect(vote_3.voter).to eq donald
    expect(vote_3.group).to eq group
    expect(donald_membership.reload.trust_count).to eq 0
    expect(the_spirit_membership.reload.trust_count).to eq 1

    post :do_trust, params: { mode: "regular", trustee_id: donald.id, group_id: group.id }

    expect(Vote.count).to eq 4
    expect(vote_3.reload.expired?).to be true
    vote_4 = Vote.last
    expect(vote_4.active?).to be true
    expect(vote_4.person).to eq donald
    expect(vote_4.voter).to eq donald
    expect(vote_4.group).to eq group
    expect(donald_membership.reload.trust_count).to eq 1
    expect(the_spirit_membership.reload.trust_count).to eq 0

    post :do_trust, params: { mode: "back", trust_id: donald_membership.current_trust.id }

    expect(Vote.count).to eq 4
    expect(vote_4.reload.expired?).to be true
    expect(donald_membership.reload.trust_count).to eq 0
    expect(the_spirit_membership.reload.trust_count).to eq 0
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

    X.services.join_group(group, the_spirit) || fail

    membership = group.memberships.first!

    post :do_destroy, params: { mode: "group_membership", group_membership_id: membership.id }

    expect(group.reload.member?(the_spirit)).to be false
  end
end