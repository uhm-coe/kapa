class Kapa::CpGenerator < Rails::Generators::NamedBase

  source_root Kapa::Engine.root

  desc "Copy a file from Kapa::Engine to your application for customizing controllers, models, views, etc..."

  def copy_engine_file

    copy_file "#{Kapa::Engine.root}/#{file_path}", "#{Rails.root}/#{file_path}"
  end

end
