SECRETS_DIR = File.join(File.dirname(__FILE__), '..', 'secrets')

# From Ruby 1.9
def shellescape(str)
  # An empty argument will be skipped, so return empty quotes.
  return "''" if str.empty?

  str = str.dup

  # Process as a single byte sequence because not all shell
  # implementations are multibyte aware.
  str.gsub!(/([^A-Za-z0-9_\-.,:\/@\n])/n, "\\\\\\1")

  # A LF cannot be escaped with a backslash because a backslash + LF
  # combo is regarded as line continuation and simply ignored.
  str.gsub!(/\n/, "'\n'")

  return str
end

def fetch_secret name
  file = File.join(SECRETS_DIR, name)
  `gpg -q -d #{shellescape file}`
end
