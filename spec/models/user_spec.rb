require "spec_helper"

describe User do
  describe "#avatar_url" do
    it "is the Gravatar image URL for the user's email address" do
      user = create(:user, email: "John.Doe@gmail.com ")

      uri = URI.parse(user.avatar_url)
      expect(uri.scheme).to eq("https")
      expect(uri.host).to eq("secure.gravatar.com")
      expect(uri.path).to eq("/avatar/e13743a7f1db7f4246badd6fd6ff54ff")
      query = Rack::Utils.parse_query(uri.query)
      expect(query["d"]).to eq("mm")
      expect(query["s"]).to eq("55")
    end
  end

  describe "#set_api_auth_token" do
    it "is set on creation" do
      user = create(:user, name: "John", api_auth_token: nil)

      token = user.api_auth_token
      expect(token).to be_present

      user.update!(name: "Jane")

      expect(user.api_auth_token).to eq(token)
    end
  end
end
