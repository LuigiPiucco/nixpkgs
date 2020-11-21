{ targetRoot, wgetExtraOptions }:
''
  metaDir=${targetRoot}etc/ec2-metadata
  mkdir -m 0755 -p "$metaDir"

  echo "getting instance metadata..."

  wget_imds() {
    wget ${wgetExtraOptions} "$@"
  }

  if ! [ -e "$metaDir/ami-manifest-path" ]; then
    wget_imds -O "$metaDir/ami-manifest-path" http://169.254.169.254/1.0/meta-data/ami-manifest-path
  fi

  if ! [ -e "$metaDir/user-data" ]; then
    wget_imds -O "$metaDir/user-data" http://169.254.169.254/1.0/user-data && chmod 600 "$metaDir/user-data"
  fi

  if ! [ -e "$metaDir/hostname" ]; then
    wget_imds -O "$metaDir/hostname" http://169.254.169.254/1.0/meta-data/hostname
  fi

  if ! [ -e "$metaDir/public-keys-0-openssh-key" ]; then
    wget_imds -O "$metaDir/public-keys-0-openssh-key" http://169.254.169.254/1.0/meta-data/public-keys/0/openssh-key
  fi
''
