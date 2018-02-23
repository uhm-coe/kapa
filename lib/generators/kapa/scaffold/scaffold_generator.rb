class Kapa::ScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  desc "Generates controller and views for the model with the given NAME."

  class_option :orm, banner: "NAME", type: :string, required: true,
                     desc: "ORM to generate the controller for"

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  source_root File.expand_path('../templates', __FILE__)

  def copy_controller_file
    template "controller.rb", File.join("app/controllers", "#{controller_file_name}_controller.rb")
  end
end
