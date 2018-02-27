class Kapa::ScaffoldGenerator < Rails::Generators::NamedBase
  include Rails::Generators::ResourceHelpers

  desc "Generates controller and views for the model with the given NAME."

  class_option :orm, banner: "NAME", type: :string, required: true,
                     desc: "ORM to generate the controller for"

  argument :attributes, type: :array, default: [], banner: "field:type field:type"

  source_root File.expand_path('../templates', __FILE__)

  def initialize(args = [], local_options = {}, config = {})
    super
    @model_options = args
  end

  def generate_model
    @model_options[0] = "create_#{plural_name}"
    @model_options << "yml:text"
    @model_options << "json:text"
    @model_options << "--timestamps"
    Rails::Generators.invoke 'active_record:migration', @model_options
    Rails::Generators.invoke 'active_record:model', [file_path, "--no-test-framework", "--parent=Kapa::KapaModel" ]
    remove_file(File.join("#{File.join("app/models", class_path.join("/"))}.rb"))
  end

  def generate_controller
    template "controller.rb", File.join("app/controllers", "#{controller_name}_controller.rb")
  end

  def generate_views
    template "new.html.erb", File.join("app/views", controller_name, "new.html.erb")
    template "show.html.erb", File.join("app/views", controller_name, "show.html.erb")
    template "index.html.erb", File.join("app/views", controller_name, "index.html.erb")
    template "form.html.erb", File.join("app/views", controller_name, "_#{file_name}_form.html.erb")
  end

  def add_routes
    Rails::Generators.invoke 'resource_route', [controller_name]
    inject_into_file "#{Rails.root}/config/initializers/kapa.rb", "  #{plural_table_name}\n", :after => "Rails.configuration.available_routes = %w{\n"
    puts "A new route was added.  Please restart to apply the new configration and run rake kapa:admin:user_role to give Admin users a permisison to access the new route."
  end
end
