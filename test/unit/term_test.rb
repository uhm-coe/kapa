require 'test_helper'

class TermTest < ActiveSupport::TestCase
  test "is invalid without a code" do
    term = Term.new(:description => "Spring 3000")
    assert !term.valid?
  end

  test "is invalid without a description" do
    term = Term.new(:code => "300030")
    assert !term.valid?
  end

  # test "selections"

  test "returns current term" do
    assert_equal "Spring 2015", Term.current_term.description
  end

  test "returns next term" do
    assert_equal "Summer 2015", Term.next_term.description
  end

  test "retrieves terms filtered by term range as an Array" do
    # Fall 2014 to Fall 2015
    range_of_terms = Term.terms_ids_by_range(2024241529, 2024241531)
    assert_instance_of Array, range_of_terms
    assert_equal 4, range_of_terms.length
  end

  # test "search"
end
