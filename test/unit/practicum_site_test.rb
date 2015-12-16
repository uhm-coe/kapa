require 'test_helper'

class PracticumSiteTest < ActiveSupport::TestCase
  test "is invalid without a name" do
    practicum_site = PracticumSite.new(:code => "3700")
    assert !practicum_site.valid?
  end

  test "is invalid without a code" do
    practicum_site = PracticumSite.new(:name => "Hogwarts School")
    assert !practicum_site.valid?
  end

  test "is invalid if code is already taken" do
    practicum_site = PracticumSite.new(:name => "Iolani School", :code => "946")
    assert !practicum_site.valid?
  end

  test "returns site contact as an OpenStruct" do
    practicum_site = PracticumSite.new(:name => "Hogwarts School", :code => "3700")
    assert_instance_of OpenStruct, practicum_site.site_contact
  end

  test "returns level range if level from is not 99" do
    practicum_site = PracticumSite.new(:name => "Hogwarts School", :code => "3700", :level_from => "K", :level_to => "12")
    assert_equal "K-12", practicum_site.grades
  end

  test "returns N/A if level is 99" do
    practicum_site = PracticumSite.new(:name => "Hogwarts School", :code => "3700", :level_from => "99", :level_to => "12")
    assert_equal "N/A", practicum_site.grades
  end

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
