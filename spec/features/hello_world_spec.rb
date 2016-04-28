require 'spec_helper'

feature 'hello world' do
  scenario "says hello" do
    visit('/')
    expect(page).to have_content('Hello world')
  end

  scenario 'returning query string data' do
    visit('?message=foo')
    expect(page).to have_content('foo')
    expect(page).not_to have_content('message=')
  end

  scenario 'returning nothing' do
    visit('/')
    expect(page).to have_content('nothing!')
  end

  scenario 'returns a 202' do
    visit('/')
    expect(page.status_code).to eq(202)
  end
end
