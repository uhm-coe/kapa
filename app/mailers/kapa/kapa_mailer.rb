# Generic mailer for apps using the engine. Send staff-editable emails with
#   Kapa::KapaMailer.build_from_text_template(code, headers, locals).deliver_now
# Apps may subclass it for their own named emails (e.g. class UserMailer < Kapa::KapaMailer).
class Kapa::KapaMailer < ActionMailer::Base
  include Kapa::KapaMailerBase
end
