# FirebaseIdToken

Retrieved auth UID using ID token sent from client. (Ruby implementation)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'firebase_id_token'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install firebase_id_token

## Configuration

```ruby
FirebaseIdToken.configure do |config|
  config.project_ids = 'my-project-id'      # Default: nil
  config.cache_path  = 'path/to/cache_file' # Default: tmp/firebase_public_key
  config.cache_time  = 60 * 60 * 2          # Default: 60 * 60
end
```

## Usage

```ruby
require('firebase_id_token')

# Token comes from client side
token = 'eyJhbGciOiJSUzI1NiIs.....ajmRoVHvI7A'
FirebaseIdToken.verify(token)

# Result
=> {"uid"=>"oyvaFVD2xxxxxxxxZPFVnH1X8Xv1",
 "decoded_token"=>
  {:payload=>
    {"iss"=>"https://securetoken.google.com/xem-cloud",
     "name"=>"User Name",
     "picture"=>
      "https://lh5.googleusercontent.com/-xxxxxx/xxxxxxxxx/AAAAAAAAAT4/xxxxxxx/photo.jpg",
     "aud"=>"Your Project ID",
     "auth_time"=>1522240359,
     "user_id"=>"oyvaFVD2xxxxxxxxZPFVnH1X8Xv1",
     "sub"=>"oyvaFVD2xxxxxxxxZPFVnH1X8Xv1",
     "iat"=>1522240388,
     "exp"=>1522243988,
     "email"=>"youremail@example.com",
     "email_verified"=>true,
     "firebase"=>
      {"identities"=>
        {"google.com"=>["108658900000000862749"],
         "email"=>["youremail@example.com"]},
       "sign_in_provider"=>"google.com"}},
   :header=>
    {"alg"=>"RS256", "kid"=>"f5b18276a4866100000000c3e9434974d1f1db51"}}}
```

## Related Docs
- https://firebase.google.com/docs/auth/admin/verify-id-tokens



## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
