require 'test_helper'

class CurriculumTest < ActiveSupport::TestCase
  test "is invalid without a person id" do
    curriculum = Curriculum.new(:program_id => 1)
    assert !curriculum.valid?
  end

  test "is invalid without a program id" do
    curriculum = Curriculum.new(:person_id => 1)
    assert !curriculum.valid?
  end

  test "sets default options" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1)
    curriculum.save
    assert_equal curriculum.program.major, curriculum.major_primary
    assert_equal curriculum.distribution, curriculum.distribution
    assert_equal curriculum.program.track, curriculum.track
    assert_equal curriculum.program.location, curriculum.location
  end

  test "returns track description" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :track => "L")
    curriculum.save
    assert_equal "Licensure", curriculum.track_desc
  end

  test "returns primary major description" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :major_primary => "DDS")
    curriculum.save
    assert_equal "Disability & Diversity Studies", curriculum.major_primary_desc
  end

  test "returns secondary major description" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :major_secondary => "EDEA")
    curriculum.save
    assert_equal "Educational Administration", curriculum.major_secondary_desc
  end

  test "returns distribution description" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :distribution => "MAN")
    curriculum.save
    assert_equal "Manoa", curriculum.distribution_desc
  end

  test "returns location description" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :location => "Oahu")
    curriculum.save
    assert_equal "Oahu", curriculum.location_desc
  end

  test "returns the curriculum code" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :distribution => "MAN", :track => "L")
    curriculum.save
    assert_equal "GCERT/DDS/MAN/L", curriculum.code
  end

  test "returns code description" do
    curriculum = Curriculum.new(:person_id => 1, :program_id => 1, :distribution => "MAN", :track => "L")
    curriculum.save
    assert_equal "GCERT/Disability & Diversity Studies/Manoa/Licensure", curriculum.code_desc
  end

  # test "search"

  # test "to_csv"

  # test "csv_columns"

  # test "csv_row"
end
