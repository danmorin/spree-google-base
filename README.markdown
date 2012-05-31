SpreeGoogleBase
===============

This extension allows you to use Google Base to list products for free that will appear in Google Product Search (http://www.google.com/shopping).

[Learn more about Google Base](http://support.google.com/merchants/bin/answer.py?hl=en&answer=160540)

For product feed field definitions, (consult http://support.google.com/merchants/bin/answer.py?hl=en&answer=188494#US)

INSTALLATION
------------

1. Create google base account. Create google base ftp account (if applicable). Create data feed in google base with a type "Products" and name "google_base.xml".

2. Install the extension with one of the following commands

      Add `gem "spree_google_base", :git => 'git://github.com/jumph4x/spree-google-base.git'` to Gemfile
      Run `bundle install`
      Run `rails g spree_google_base:install`
      Run `rake db:migrate`

3. Edit product_type, priorities in spree admin (/admin/taxon_map)

4. Set preferences in spree admin panel (/admin/google_base_settings) for the feed title, public domain, feed description, ftp login and password. FTP login is not required - you may schedule upload from the public directory.

5. Issue the command 'rake spree_google_base:generate_and_transfer' to generate feed. Verify feed exists (YOUR_APP_ROOT/tmp/google_base_v.xml).


ADVANCED CONFIGURATION
------------

You can modify fields set for export and list of 'g:' attributes. Look at config/initializers/google_base.rb
You can override values of GOOGLE_BASE_ATTR_MAP and GOOGLE_BASE_FILTERED_ATTRS arrays with help of Array#delete, Array#delete_at, Array#<<, Array#+=, etc.
Also you can override methods from product_decorator.rb in your site extension.


CRONJOBS
--------

There are two options to regulate google base product update:

A) Setup cronjobs to run 'rake spree_google_base:generate' and 'rake spree_google_base:transfer'


Development of this extension is sponsored by [End Point][1] and by [FCP Groton][2].

[1]: http://www.endpoint.com/
[2]: http://www.fcpgroton.com/
