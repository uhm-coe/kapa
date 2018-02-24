class Kapa::ScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  desc "Generates controller and views for the model with the given NAME."

  class_option :orm, banner: "NAME", type: :string, required: true,
                     desc: "ORM to generate the controller for"

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  source_root File.expand_path('../templates', __FILE__)

  def invoke_active_record_model
    Rails::Generators.invoke 'active_record:model', [file_path, "--no-test-framework", "--parent=Kapa::KapaModel" ]
    module_file_path = File.join("app/models", class_path.join("/"))
    remove_file(File.join("#{File.join("app/models", class_path.join("/"))}.rb"))
  end

  def copy_controller_file
    template "controller.rb", File.join("app/controllers", class_path.join("/"), "#{controller_name}_controller.rb")
  end

  def copy_view_files
    template "new.html.erb", File.join("app/views", class_path.join("/"), controller_name, "new.html.erb")
    template "show.html.erb", File.join("app/views", class_path.join("/"), controller_name, "show.html.erb")
    template "index.html.erb", File.join("app/views", class_path.join("/"), controller_name, "index.html.erb")
    template "form.html.erb", File.join("app/views", class_path.join("/"), controller_name, "_#{file_name}_form.html.erb")
  end

end
