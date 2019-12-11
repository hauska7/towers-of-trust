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

  it 'do_vote' do
    donald = X.fixture.get("donald")
    the_spirit = X.fixture.get("the_spirit")

    controller.sign_in the_spirit

    post :do_vote, params: { mode: "regular", user_id: donald.id }

    expect(Vote.count).to eq 1
    vote = Vote.first!
    expect(vote.active?).to be true
    expect(vote.person).to eq donald
    expect(vote.voter).to eq the_spirit
    expect(the_spirit.reload.votes_count).to eq 0
    expect(donald.reload.votes_count).to eq 1

    post :do_vote, params: { mode: "regular", user_id: donald.id }

    expect(Vote.count).to eq 2
    expect(vote.reload.expired?).to be true
    vote_2 = Vote.last
    expect(vote_2.active?).to be true
    expect(vote_2.person).to eq donald
    expect(vote_2.voter).to eq the_spirit
    expect(the_spirit.reload.votes_count).to eq 0
    expect(donald.reload.votes_count).to eq 1

    controller.sign_out
    controller.sign_in donald

    post :do_vote, params: { mode: "regular", user_id: the_spirit.id }

    expect(Vote.count).to eq 3
    expect(vote_2.reload.expired?).to be true
    vote_3 = Vote.last
    expect(vote_3.active?).to be true
    expect(vote_3.person).to eq the_spirit
    expect(vote_3.voter).to eq donald
    expect(donald.reload.votes_count).to eq 0
    expect(the_spirit.reload.votes_count).to eq 1

    post :do_vote, params: { mode: "regular", user_id: donald.id }

    expect(Vote.count).to eq 4
    expect(vote_3.reload.expired?).to be true
    vote_4 = Vote.last
    expect(vote_4.active?).to be true
    expect(vote_4.person).to eq donald
    expect(vote_4.voter).to eq donald
    expect(donald.reload.votes_count).to eq 1
    expect(the_spirit.reload.votes_count).to eq 0

    post :do_vote, params: { mode: "take_back" }

    expect(Vote.count).to eq 4
    expect(vote_4.reload.expired?).to be true
    expect(donald.reload.votes_count).to eq 0
    expect(the_spirit.reload.votes_count).to eq 0
  end
end