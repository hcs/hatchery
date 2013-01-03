SECRETS_DIR = File.join(File.dirname(__FILE__), '..', 'secrets')

def fetch_secret name
  file = File.join(SECRETS_DIR, name)
  `gpg -q -d #{shellescape file}`
end
