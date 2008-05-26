require 'ramaze'
require 'ramaze/spec/helper'

shared 'mechanize' do
  require 'mechanize'

  @agent = WWW::Mechanize.new
  @page = @agent.get("http://localhost:7007/")

  def get(*args)
    @page = @agent.get(*args)
  end

  def click_link(l)
    @page = @agent.click(links.text(l))
  end

  def links
    @page.links
  end

  def submit(*args)
    @page = @agent.submit(*args)
  end
end

describe 'User register' do
  require 'start'
  ramaze :adapter => :thin, :port => 7007, :run_loose => true
  behaves_like 'mechanize'

  def check(id, check)
    @page.at(id).inner_text.should =~ check
  end

  should 'see register link' do
    click_link 'Register'

    form = @page.form('register')

    form.login = 'manveru'
    form.email = 'm.fellinger@gmail.com'
    form.password = 'letmein'
    form.password_confirmation = 'letmein'
    # form.remember_me

    submit form, form.buttons.first

    check '#flashbox/.good', /welcome on board manveru/
  end

  should 'be logged in after registering' do
    links.text('Logout').should.not == nil
  end

  should 'log out' do
    click_link('Logout')
    check '#flashbox/.good', /You logged out successfully/
    links.text('Login').should.not == nil
  end

  should 'log in' do
    click_link('Login')

    form = @page.form('login')

    form.login = 'manveru'
    form.password = 'letmein'
    # form.remember_me

    submit form, form.buttons.first
    check '#flashbox/.good', /Welcome back manveru/
  end
end
