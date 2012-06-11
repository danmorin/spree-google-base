require 'net/ftp'

namespace :spree_google_base do
  task :generate_and_transfer => [:environment] do |t, args|
    SpreeGoogleBase::FeedBuilder.generate_and_transfer
  end
  
  task :delayed_generate_and_transfer => [:environment] do |t, args|
    SpreeGoogleBase::FeedBuilder.delay.generate_and_transfer
  end
end
