module ControllerMacros
  def login_user(user)
    before(:each) do
        expect(user).to_not be_nil
        session = Kapa::UserSession.create!(user, false)
        expect(session).to be_valid
        session.save
    end
  end
end