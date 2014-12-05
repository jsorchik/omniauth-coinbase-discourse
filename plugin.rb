# name: omniauth-coinbase-discourse
# about: Authenticate on discourse with Coinbase
# version: 0.1.0
# author: jsorchik

gem 'money', '6.1.0'
gem 'monetize', '0.3.0'
gem 'httparty', '0.8.3'
gem 'coinbase', '2.1.1'
gem 'omniauth-coinbase', '1.0.2'

require 'auth/oauth2_authenticator'

class CoinbaseAuthenticator < ::Auth::OAuth2Authenticator

  CLIENT_ID = ENV['CB_CLIENT_ID']
  CLIENT_SECRET = ENV['CB_CLIENT_SECRET']

  def name
    'coinbase'
  end

  def after_authenticate(auth_token)
    result = Auth::Result.new

    # grab the info we need from omni auth
    data = auth_token[:info]
    raw_info = auth_token["extra"]["raw_info"]
    name = data["name"]
    cb_uid = auth_token["uid"]
    email = data["email"]

    # plugin specific data storage
    current_info = ::PluginStore.get("cb", "cb_uid_#{cb_uid}")

    result.user =
      if current_info
        User.where(id: current_info[:user_id]).first
      end

    result.name = name
    result.extra_data = { cb_uid: cb_uid }
    result.email = email

    result
  end

  def after_create_account(user, auth)
    data = auth[:extra_data]
    ::PluginStore.set("cb", "cb_uid_#{data[:cb_uid]}", {user_id: user.id })
  end

  def register_middleware(omniauth)
    omniauth.provider :coinbase,
     CLIENT_ID,
     CLIENT_SECRET,
     scope: 'user'
  end
end


auth_provider :title => 'with Coinbase',
    :message => 'Log in via Coinbase (Make sure pop up blockers are not enabled).',
    :frame_width => 920,
    :frame_height => 800,
    :authenticator => CoinbaseAuthenticator.new('coinbase', trusted: true)


register_css <<CSS

.btn-social.coinbase {
  background: #2b71b1;
}

CSS

