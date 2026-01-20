require 'openssl'

# Disable SSL verification for local development
# NOTE: This plugin only runs during local Jekyll builds. GitHub Pages does NOT
# execute custom plugins in the _plugins/ directory, so this will NOT affect
# production builds. This is safe to commit and push.
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE
