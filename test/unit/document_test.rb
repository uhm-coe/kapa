require 'test_helper'

class DocumentTest < ActiveSupport::TestCase
  test "is invalid without a person id" do
    document = Document.new
    assert !document.valid?
  end

  # test "url"

  test "returns data content type as is unless mimetype is PDF" do
    document = Document.new(:data_content_type => "application/x-pdf", :person_id => 1)
    assert_equal "application/pdf", document.content_type
  end

  test "returns data file size as file size" do
    document = Document.new(:data_file_size => 0, :person_id => 1)
    assert_equal 0, document.file_size
  end

  test "returns updated_at as date" do
    document = Document.new(:person_id => 1, :updated_at => DateTime.now)
    assert_equal document.updated_at, document.date
  end
end
