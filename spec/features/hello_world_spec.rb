require 'spec_helper'

feature 'hello world' do
  scenario "says hello" do
    visit('/')
    expect(page).to have_content('Hello world')
  end

  scenario 'returning query string data' do
    visit('?message=foo')
    expect(page).to have_content('message=foo')
  end
end
