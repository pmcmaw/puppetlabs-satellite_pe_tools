# == Class: pe_satellite
#
# This module provides and configures a report processor to send puppet agent reports
# to a Satellite server
#
# === Parameters
#
# [*satellite_url*]
#   The full URL to the satellite server in format https://url.to.satellite
#
# [*ssl_ca*]
#   Optional. The file path to the CA certificate used to verify the satellite server
#   identitity. If not provided, the local Puppet Enterprise master's CA is used.
#
# [*ssl_cert*]
#   The file path to the certificate signed by the Satellite CA. It's used for Satellite
#   to verify the identity of the Puppet Enterprise master
#
# [*ssl_key*]
#   The file path to the key for the Puppet Enterprise master generated by Satellite
#
# === Examples
#
#  class { 'pe_satellite':
#    satellite_url => 'https://satellite.example.domain',
#    ssl_ca        => '/etc/puppetlabs/puppet/ssl/ca/satellite_crt.pem',
#    ssl_cert      => '/etc/puppetlabs/puppet/ssl/certs/satellite-master.example.domain.pem',
#    ssl_key       => '/etc/puppetlabs/puppet/ssl/public_keys/satellite-master.example.domain.pem',
#  }
#
# === Authors
#
# Puppet Labs <info@puppetlabs.com>
#
# === Copyright
#
# Copyright 2015 Puppet Labs
class pe_satellite(
  $satellite_url,
  $verify_satellite_certificate = true,
  $ssl_ca = '',
  $ssl_cert = '',
  $ssl_key = ''
) {

  $parsed_hash = parse_url($satellite_url)
  $satellite_hostname = $parsed_hash['hostname']

  if $verify_satellite_certificate {
    if $ssl_ca {
      $ssl_ca_real = $ssl_ca
    } else {
      $ssl_ca_real = "/etc/puppetlabs/puppet/ssl/certs/ca.pem"
    }

    if $ssl_cert {
      $ssl_cert_real = $ssl_cert
    } else {
      $ssl_cert_real = "/etc/puppetlabs/puppet/ssl/certs/${satellite_hostname}.pem"
    }

    if $ssl_key {
      $ssl_key_real = $ssl_key
    } else {
      $ssl_key_real = "/etc/puppetlabs/puppet/ssl/private_keys/${satellite_hostname}.pem"
    }
  } else {
    $ssl_ca_real = false
    $ssl_key_real = false
    $ssl_cert_real = false
  }

  $satellite_config = {
    url      => $satellite_url,
    ssl_ca   => $ssl_ca_real,
    ssl_cert => $ssl_cert_real,
    ssl_key  => $ssl_key_real
  }

  file { '/etc/puppetlabs/puppet/pe_satellite.yaml':
    ensure  => file,
    content => to_yaml($satellite_config),
    owner   => pe-puppet,
    group   => pe-puppet,
    mode    => 0644,
  }

}
