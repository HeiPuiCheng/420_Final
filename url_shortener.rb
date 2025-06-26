#!/usr/bin/env ruby
# frozen_string_literal: true
#
# Minimal URL shortener using Sinatra + Sequel + SQLite.
# ------------------------------------------------------
# Dependencies (install once):
#   gem install sinatra sequel sqlite3
#
# Run with:
#   ruby url_shortener.rb
# Then open http://localhost:4567 in your browser.

require 'sinatra'
require 'sequel'
require 'securerandom'
require 'json'

# --- Database setup ---------------------------------------------------------
DB = Sequel.sqlite('urls.db')

# Create table on first run (id, slug, original_url, created_at)
unless DB.table_exists?(:urls)
  DB.create_table :urls do
    primary_key :id
    String  :slug, unique: true, null: false
    String  :original_url, text: true, null: false
    DateTime :created_at
  end
end

class Url < Sequel::Model(:urls); end

# --- Helper methods ---------------------------------------------------------
helpers do
  # Add "https://" if the user forgot
  def normalize(url)
    url =~ /\Ahttp/i ? url : "https://#{url}"
  end

  def generate_slug
    loop do
      slug = SecureRandom.urlsafe_base64(4)
      break slug unless Url.first(slug: slug)
    end
  end
end

# --- Routes -----------------------------------------------------------------

# Simple HTML form
get '/' do
  <<~HTML
    <h1>Ruby URL Shortener</h1>
    <form action="/shorten" method="post">
      <input style="width:300px" type="text" name="url" placeholder="https://example.com">
      <button>Shorten</button>
    </form>
  HTML
end

# Handle form submission
post '/shorten' do
  long = normalize(params[:url])
  slug = generate_slug
  Url.create(slug:, original_url: long, created_at: Time.now)
  <<~HTML
    <p>Original: <a href="#{long}">#{long}</a></p>
    <p>Short:   <a href="/#{slug}">#{request.base_url}/#{slug}</a></p>
    <a href="/">Shorten another</a>
  HTML
end

# JSON API endpoint
post '/api/shorten' do
  content_type :json
  payload = JSON.parse(request.body.read)
  long = normalize(payload['url'])
  slug = generate_slug
  Url.create(slug:, original_url: long, created_at: Time.now)
  { short: "#{request.base_url}/#{slug}", original: long }.to_json
end

# Redirect slug to original URL
get '/:slug' do
  link = Url.first(slug: params[:slug]) or halt 404, 'Not found'
  redirect link.original_url, 302
end

# --- Start server only if this file is executed directly --------------------
Sinatra::Application.run! if __FILE__ == $PROGRAM_NAME
