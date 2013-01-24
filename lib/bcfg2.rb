module Bcfg2
  def install_bcfg2
    ssh 'sudo add-apt-repository -y ppa:bcfg2/precisetesting'
    ssh 'sudo apt-get update'
    ssh 'sudo apt-get install -y bcfg2'

    # This should be updated in tandem with the corresponding file in the config
    # repo
    dropbear '/etc/ssl/certs/config.pem', <<-END
      -----BEGIN CERTIFICATE-----
      MIIGYTCCBEmgAwIBAgIJAP7pvjrcGVPPMA0GCSqGSIb3DQEBBQUAMH0xCzAJBgNV
      BAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRzMRIwEAYDVQQHEwlDYW1icmlk
      Z2UxITAfBgNVBAoTGEhhcnZhcmQgQ29tcHV0ZXIgU29jaWV0eTEfMB0GA1UEAxMW
      Y29uZmlnLmhjcy5oYXJ2YXJkLmVkdTAeFw0xMjEyMTkwMzM2NDdaFw0yMjEyMTcw
      MzM2NDdaMH0xCzAJBgNVBAYTAlVTMRYwFAYDVQQIEw1NYXNzYWNodXNldHRzMRIw
      EAYDVQQHEwlDYW1icmlkZ2UxITAfBgNVBAoTGEhhcnZhcmQgQ29tcHV0ZXIgU29j
      aWV0eTEfMB0GA1UEAxMWY29uZmlnLmhjcy5oYXJ2YXJkLmVkdTCCAiIwDQYJKoZI
      hvcNAQEBBQADggIPADCCAgoCggIBAL2EUyPbXie99SO68GX+E9f2nSA4zuk8rNy0
      UmtD/0w9BUm5v3Rz+OVfqx7SiW/IELglq11mQ/e8JpNbDbARpuhrlduJKJWXch0F
      D6wV1rcwT+vyZWzCIZteZVpSEkLLXjphKm0eU5Q4rx82Jvx0QtEAbk4o/rlAaXZf
      fOtUyMHQkVSZQQVmLJZyHpHvlbRNTDbpIGGpHQsiz4L/efSo9Nsh4B9YzVeIgkiU
      BJVjv4X1tDYHDmLR+CDvZx+ooj/dayHrTIgKjhCJtIi/i6R/pFOQa9MKb0sX4S9q
      11BKa1xalAUhgUBvPV3srocbGmzgcZHbUHjGZsaKOr9yi5XppG1XCDVmJLDoEG3e
      Wi2mr39pRe4lD1aKobBEiNC19+oleL/5GFuccMmOlOdBmENuKoxR4HUHXj5RoqKR
      Dy5YaKRAOZVfm01Y0bIJL1eGYHewFEx083Z/hUZwjklA3IkUWkx/dBDc0Csbq6MH
      qwJ4Es14P4sn7QpheMne5X562rwiusObeGuDluVoF+6VKyUdgAmO+6w4a5LOVp87
      p8Lj3yQofYmQQ3ssRkSuGRtUnagcFjuNTBJCUa7PzNWBW61GDrX+kdfK/kFzJrd2
      PBfeajmTjRaM7gVxQJuOn/PDO3CK3mYWfdhJtE3SvyMm6fqp+hNHTTVTYRacAxkB
      ilanuTCpAgMBAAGjgeMwgeAwHQYDVR0OBBYEFHyPt4q8+6xbHgXMhEi/XBFhcEGp
      MIGwBgNVHSMEgagwgaWAFHyPt4q8+6xbHgXMhEi/XBFhcEGpoYGBpH8wfTELMAkG
      A1UEBhMCVVMxFjAUBgNVBAgTDU1hc3NhY2h1c2V0dHMxEjAQBgNVBAcTCUNhbWJy
      aWRnZTEhMB8GA1UEChMYSGFydmFyZCBDb21wdXRlciBTb2NpZXR5MR8wHQYDVQQD
      ExZjb25maWcuaGNzLmhhcnZhcmQuZWR1ggkA/um+OtwZU88wDAYDVR0TBAUwAwEB
      /zANBgkqhkiG9w0BAQUFAAOCAgEAKJ/l0jOPx1oieMYAFgFN1mjzBL4+3N3Fkfzq
      VfpydiaMA5Hj4pOFz4wpQF4MgdWLBn6aZ2NjIBT/k7jl/WKO3wOU/kKmAZpdAQ1K
      Dca9KAUoxqFJN2Ns2NqXXf8PlrRxwrl66j0qtSIIjRyJ3y/8Np5iI0f2uSLE6UYs
      Vg68qb+4PC72JeexHZvhL85zxzQ8k8273Uh1UpJ4xqzIpagBxo6PscinVISGJWik
      UrqBpDkJUNNykkgE9ktBOIo0+ATnGLfNkdKrZ/NW3XsxN6Ox5efaw3hIDIyyP3O1
      fAqRujfsbWunAUJ6y5aOna9wtSmOMm+N1jzRy7evyEFdOi8APxxEbzKzc8ItEo+H
      ck2WYb/+NtJmSpT2YI0AE57aim+IMbNJj4Z2WJ2TabpJRx+AChsvEFzSxj2cfNOH
      YwRR3eRwxPSuVWfbhvqRvawMITYc7TfnA4w0mINRJiIz0bw/hllhEyEU2iWnjCCv
      cNP9pevd9LFAYzXFNfOq9KeIdmxIeAJ2Y6qvYeEQNNif6Wq534OEFk3kl3URxC+z
      itWKR972UAqiGJB898lUV8m/P7SMdPKS/Df87Rlmiwr+nV3YYXkxm9rhH7LOaGpQ
      xbdF5BH7DfQNVtCX+S0L0aAyHeeEXl4M2i0J+kSNNHQjG4rpliyTgVLtHicdTI48
      Lg9WYV8=
      -----END CERTIFICATE-----
    END

    dropbear '/etc/bcfg2.conf', <<-END
      # Hatchery bootstrapped bcfg2.conf
      [communication]
      protocol = xmlrpc/ssl
      password = #{fetch_secret 'bcfg2-password'}
      ca = /etc/ssl/certs/config.pem
      user = #{hostname}

      [components]
      bcfg2 = https://10.0.2.4:6789
    END
  end

  def bcfg2 full=false
    ssh 'sudo bcfg2 -vqe'
  end

  def bootstrap
    raise 'Already bootstrapped' if bootstrapped?

    # Allow SSH as root, since we're about to nuke the ubuntu user
    key_url = 'http://169.254.169.254/latest/meta-data/public-keys/0/openssh-key'
    ssh "curl -s #{key_url} | sudo tee /root/.ssh/authorized_keys > /dev/null"
    disconnect

    @instance.tags['Bootstrapped'] = 'true'
    ssh 'sudo killall -u ubuntu'
    ssh 'sudo deluser --remove-home ubuntu'

    # We need to run at least twice, since some things come out wrong the first
    # time (for instance, the hcs user is not created in time on the first
    # invocation to have files chowned to it).
    bcfg2
    ssh 'sudo apt-get update'
    bcfg2
  end

  def bootstrapped?
    !@instance.tags['Bootstrapped'].nil?
  end

end
