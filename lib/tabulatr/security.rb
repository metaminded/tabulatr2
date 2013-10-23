require 'securerandom'

module Tabulatr
  module Security
    def self.sign(arglist, salt=nil)
      salt ||= SecureRandom.base64
      str = "#{Tabulatr.secret_tokens.first}-#{salt}-#{arglist}-#{Rails.application.config.secret_token}-#{Tabulatr.secret_tokens.last}"
      hash = Digest::SHA1.hexdigest(str)
      "#{arglist}-#{salt}-#{hash[5..40]}"
    end

    def self.validate(str)
      arglist, salt, hash = str.split('-')
      str == sign(arglist, salt)
    end

    def self.validate!(str)
      validate(str) or raise "SECURITY!"
    end
  end
end
