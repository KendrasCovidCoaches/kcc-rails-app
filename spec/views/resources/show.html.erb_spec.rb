require 'rails_helper'

RSpec.describe "resources/show", type: :view do
  before(:each) do
    @resource = assign(:resource, Resource.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
