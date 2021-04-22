require 'rails_helper'

RSpec.describe "resources/index", type: :view do
  before(:each) do
    assign(:resources, [
      Resource.create!(),
      Resource.create!()
    ])
  end

  it "renders a list of resources" do
    render
  end
end
