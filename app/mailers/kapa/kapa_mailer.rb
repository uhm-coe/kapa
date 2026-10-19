# Generic mailer for apps using the engine. Send staff-editable emails with
#   Kapa::KapaMailer.build_from_content(code, headers, locals).deliver_now
# or an ERB email from app/views with
#   Kapa::KapaMailer.build({:template_path => "mailer", :template_name => "x", :layout => "student_mail", ...}, locals).deliver_now
class Kapa::KapaMailer < ActionMailer::Base
  include Kapa::KapaMailerBase
end
