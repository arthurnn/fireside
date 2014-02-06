module Uploader
  module Config
    def self.options
      using_s3? ? s3_options : file_system_options
    end

    def self.using_s3?
      ENV["S3_BUCKET"].present?
    end

    def self.s3_options
      {
        path: "/uploads/:fingerprint.:extension",
        s3_credentials: {
          bucket: ENV["S3_BUCKET"],
          access_key_id: ENV["S3_ACCESS_KEY_ID"],
          secret_access_key: ENV["S3_SECRET_ACCESS_KEY"]
        },
        s3_protocol: "https",
        storage: :s3,
        url: ":s3_domain_url"
      }
    end

    def self.file_system_options
      { url: "/uploads/:fingerprint.:extension" }
    end
  end
end
