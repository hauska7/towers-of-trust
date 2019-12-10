require "rails_helper"

RSpec.describe MainController, type: :controller do
  render_views

  it 'main' do
    user = User.new
    user.set_email("kaczor.donald@email.com")
    user.set_default_password
    user.set_name("Donald")
    user.set_votes_count(11)
    user.save!

    get :main
  end

  # logged/unlogged/self
  it 'show_user' do
    user = User.new
    user.set_email("kaczor.donald@email.com")
    user.set_default_password
    user.set_name("Donald")
    user.set_votes_count(11)
    user.save!

    get :show_user, params: { user_id: user.id }
  end

  # do_vote regulat/take_back
end