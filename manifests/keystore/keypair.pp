#
#
# Definition: java::keystore::keypair
#
# Creates (or delete) a keypair from a java keystore.
#
# Args:
#   $name             - key alias in keystore
#   $keystore         - keystore filename (mandatory)
#   $basedir          - keystore location (mandatory)
#   $keyalg           - key algorithm - DEPRECATED
#   $keysize          - key size - DEPRECATED
#   $storepass        - keystore password (default: changeit)
#   $alias            - key pair alias (default: $name)
#   $validity         - key pair validity (default: 3650 days)
#   $commonName       - key pair common name (default: localhost)
#   $organisationUnit - key pair organisation unit (default: empty)
#   $organisation     - key pair organisation (default: empty)
#   $country          - key pair country (default: empty)
#   keypass           - private key password (default: changeit)
#
#
# Notes:
#   - keytool will update an existing keystore!
#   - according to https://issues.apache.org/bugzilla/show_bug.cgi?id=38217 ,
#     storepass and keypass should be the same. As it's not sure it has
#     to be the case in the future, we let you the choice about that.
#
#
define java::keystore::keypair(
  $keystore,
  $basedir,
  $country,
  $organisation,
  $ensure=present,
  $keyalg=undef,
  $keysize=undef,
  $storepass='changeit',
  $kalias='',
  $validity=3650,
  $commonName='localhost',
  $organisationUnit=undef,
  $keypass='changeit',
) {

  $_kalias = $kalias ? {
    ''      => $name,
    default => $kalias,
  }

  if $keyalg {
    fail '$keyalg is deprecated'
  }

  if $keysize {
    fail '$keysize is deprecated'
  }

  openssl::certificate::x509 { $_kalias:
    ensure       => $ensure,
    base_dir     => $basedir,
    country      => $country,
    organisation => $organisation,
    unit         => $organisationUnit,
    commonname   => $commonName,
    days         => $validity,
  }

  java_ks { "${_kalias}:${basedir}/${keystore}":
    ensure      => $ensure,
    certificate => "${basedir}/${_kalias}.crt",
    private_key => "${basedir}/${_kalias}.key",
    password    => $storepass,
  }
}
