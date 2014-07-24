class ApplicationCryptoProvider

  def self.encrypt(*tokens)
    digest = Digest::SHA1.hexdigest([*tokens].join)
    digest
  end

  # Does the crypted password match the tokens? Uses the same tokens that were used to encrypt.
  def self.matches?(crypted, *tokens)
    encrypt(*tokens) == crypted
  end
end
