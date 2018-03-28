require 'fileutils'
require 'net/http'
require 'jwt'

require "firebase_idtoken/version"
require 'firebase_idtoken/configuration'

module FirebaseIdtoken

  # -------------------------------------------
  # Config
  #
  # FirebaseIdtoken.configure do |config|
  #   config.project_ids = 'my-project-id'
  #   config.cache_path = 'path/to/cache_file'
  #   config.cache_time = 60 * 60 * 2
  # end
  # -------------------------------------------

  class << self
    attr_accessor :configuration

    ALGORITHM = 'RS256'
    ISSUER_BASE_URL = 'https://securetoken.google.com/'
    CLIENT_CERT_URL = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def verify(token)
      raise 'id token must be a String' unless token.is_a?(String)

      full_decoded_token = decode_token(token)

      err_msg = validate_jwt(full_decoded_token)
      raise err_msg if err_msg

      public_key = fetch_public_keys[full_decoded_token[:header]['kid']]
      unless public_key
        raise 'Firebase ID token has "kid" claim which does not correspond to ' +
          'a known public key. Most likely the ID token is expired, so get a fresh token from your client ' +
          'app and try again.'
      end

      certificate = OpenSSL::X509::Certificate.new(public_key)
      decoded_token = decode_token(token, certificate.public_key, true, { algorithm: ALGORITHM, verify_iat: true })

      {
        'uid' => decoded_token[:payload]['sub'],
        'decoded_token' => decoded_token
      }
    end


    private

      def decode_token(token, key=nil, verify=false, options={})
        begin
          decoded_token = JWT.decode(token, key, verify, options)
        rescue JWT::ExpiredSignature => e
          raise 'Firebase ID token has expired. Get a fresh token from your client app and try again.'
        rescue => e
          raise "Firebase ID token has invalid signature. #{e.message}"
        end

        {
          payload: decoded_token[0],
          header: decoded_token[1]
        }
      end

      def fetch_public_keys
        cache_path = configuration.cache_path
        cache_time = configuration.cache_time
        data = nil
        begin
          # Fetch from cache if within an hour (UTC timezone)
          s = File.stat(cache_path)
          File.delete(cache_path) if (Time.now.utc - s.mtime.utc) > cache_time
          data = JSON.parse(open(cache_path).read)
        rescue => error
          puts "#{error.message}: Fetching public key from Google..."

          # Fetch keys from Google if no cache or after an hour
          uri = URI.parse(CLIENT_CERT_URL)
          https = Net::HTTP.new(uri.host, uri.port)
          https.use_ssl = true

          res = https.start {
            https.get(uri.request_uri)
          }
          json_string = res.body
          data = JSON.parse(json_string)

          if (data['error']) then
            msg = 'Error fetching public keys for Google certs: ' + data['error']
            msg += " (#{res['error_description']})" if (data['error_description'])
            raise msg
          else
            save_cache_file(json_string)
          end
        end
        data
      end

      def save_cache_file(json_string)
        cache_path = configuration.cache_path
        dirname = File.dirname(cache_path)
        unless File.directory?(dirname)
          puts "Creating a directory: #{dirname}"
          FileUtils.mkdir_p(dirname)
        end
        open cache_path, 'w' do |io|
          io.write json_string
        end
      end

      def validate_jwt(json)
        project_id = configuration.project_id
        raise 'You need to set Firebase project ID' unless project_id

        payload = json[:payload]
        header = json[:header]

        return 'Firebase ID token has no "kid" claim.' unless header['kid']
        return "Firebase ID token has incorrect algorithm. Expected \"#{ALGORITHM}\" but got \"#{header['alg']}\"." unless header['alg'] == ALGORITHM
        return "Firebase ID token has incorrect \"aud\" (audience) claim. Expected \"#{project_id}\" but got \"#{payload['aud']}\"." unless payload['aud'] == project_id

        issuer = ISSUER_BASE_URL + project_id
        return "Firebase ID token has incorrect \"iss\" (issuer) claim. Expected \"#{issuer}\" but got \"#{payload['iss']}\"."  unless payload['iss'] == issuer

        return 'Firebase ID token has no "sub" (subject) claim.' unless payload['sub'].is_a?(String)
        return 'Firebase ID token has an empty string "sub" (subject) claim.'  if payload['sub'].empty?
        return 'Firebase ID token has "sub" (subject) claim longer than 128 characters.' if payload['sub'].size > 128

        nil
      end

  end
end
