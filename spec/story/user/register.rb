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

  user = {
    :login => 'specme',
    :email => 'specme@spec.org',
    :password => 'specme',
  }

  should 'see register link' do
    click_link 'Register'

    form = @page.form('register')

    form.login = user[:login]
    form.email = user[:email]
    form.password = user[:password]
    form.password_confirmation = user[:password]
    # form.remember_me
    captcha = @page.at('label[@for=form-captcha]').inner_text
    captcha =~ /What is (\d+) ([+-]) (\d+)/
    form.captcha = $1.to_i.send($2, $3.to_i)

    submit form, form.buttons.first

    check '#flashbox/.good', /welcome on board #{user[:login]}/
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

    form.login = user[:login]
    form.password = user[:password]
    # form.remember_me

    submit form, form.buttons.first
    check '#flashbox/.good', /Welcome back #{user[:login]}/
  end
end
