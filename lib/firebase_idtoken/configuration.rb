class FirebaseIdtoken::Configuration
  attr_accessor :project_id, :cache_path, :cache_time

  def initialize
    @project_id = nil
    @cache_path = 'tmp/firebase_public_key'
    @cache_time = 60 * 60
  end
end
