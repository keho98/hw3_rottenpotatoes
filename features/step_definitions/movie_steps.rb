# Add a declarative step here for populating the DB with movies.
require 'uri'
require 'cgi'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "selectors"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(*selector_for(locator)) { yield } : yield
  end
end
World(WithinHelpers)

Given /the following movies exist/ do |movies_table|
  movies_table.hashes.each do |movie|
    # each returned element will be a hash whose key is the table header.
    # you should arrange to add that movie to the database here.
    Movie.create!(:title => movie[:title], :rating => movie[:rating], :release_date => movie[:release_date])
  end
end

# Make sure that one string (regexp) occurs before or after another one
#   on the same page

Then /I should see "(.*)" before "(.*)"/ do |e1, e2|
  #  ensure that that e1 occurs before e2.
  #  page.body is the entire content of the page as a string.
  assert page.body.index(e1) < page.body.index(e2)
end

Then /I should see the following ratings: (.*)/ do |rating_list|
  ratings = rating_list.gsub(/\s+/, "").split(',')
  ratings.each do |rating|
    if page.respond_to? :should
      page.should have_xpath('//td', :text => rating)
    else
      assert page.has_xpath?('//td', :text => rating)
    end
  end
end

Then /I should not see the following ratings: (.*)/ do |rating_list|
  ratings = rating_list.gsub(/\s+/, "").split(',')
  ratings.each do |rating|
    if page.respond_to? :should
      page.should have_no_xpath('//td', :text => rating)
    else
      assert page.has_no_xpath?('//td', :text => rating)
    end
  end
end

Then /I should see all the ratings/ do
  if page.respond_to? :should
    page.should have_xpath('//tbody/tr', :count => Movie.all.length)
  else
    assert page.has_xpath?('//tbody/tr', :count => Movie.all.length)
  end 
end

Then /I should see no ratings/ do
  if page.respond_to? :should
    #page.should have_no_xpath('//tbody/tr')
  else
    #assert page.has_no_xpath?('//tbody/tr')
  end 
end

When /I (un)?check all ratings/ do |uncheck|
  ratings = Movie.all_ratings
  ratings.each do |rating|
    if uncheck
      uncheck("ratings_#{rating}")
    else
      check("ratings_#{rating}")
    end
  end
end

# Make it easier to express checking or unchecking several boxes at once
#  "When I uncheck the following ratings: PG, G, R"
#  "When I check the following ratings: G"

When /I (un)?check the following ratings: (.*)/ do |uncheck, rating_list|
  ratings = rating_list.gsub(/\s+/, "").split(',')
  ratings.each do |rating|
    if uncheck
      uncheck("ratings_#{rating}")
    else
      check("ratings_#{rating}")
    end
  end
  #   iterate over the ratings and reuse the "When I check..." or
  #   "When I uncheck..." steps in lines 89-95 of web_steps.rb
end

When /I click refresh/ do
  click_button('ratings_submit')
end
