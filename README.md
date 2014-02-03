# Automate your Loggly config with Puppet

If you've ever had to manage servers, you're probably very familiar with an age-old problem: "How do I keep track of what's happening on all of my systems?"

[Loggly](http://loggly.com/) is a tool that can help you solve that very problem by bringing your logs from all of your systems into a central, easy-to-use dashboard.

Unfortunately, if you've got more than a handful of servers, it quickly becomes tedious to manage their configuration by hand.  Since we're still years away from being able to delegate the setup to robot minions, the Loggly team has created a [Puppet](http://puppetlabs.com/puppet/what-is-puppet) module to get Puppet users up and running right away.

If you haven't yet implemented Puppet, you can always use our [Syslog Configurator](http://www.loggly.com/docs/sending-logs-unixlinux-system-setup/) script on each system.

Here's a short guide to getting, installing, and configuring the Puppet module for Loggly.

----

## Let's get started

This guide assumes that you already have a working Puppet infrastructure using either the Open Source version of Puppet, or Puppet Enterprise from Puppet Labs.

----

## Supported daemons
The Loggly Puppet module supports [rsyslog](http://www.rsyslog.com/) (the default syslog daemon on Ubuntu and Red Hat/CentOS), as well as the popular alternative [syslog-ng](http://www.balabit.com/network-security/syslog-ng).

----

## Supported distributions
Currently, the Loggly Puppet module has been tested on several Linux distributions:

* Ubuntu 12.04 LTS
* Ubuntu 13.10
* Fedora 19
* CentOS 6.x
* Red Hat Enterprise Linux 6.x

Linux distributions based on one of these supported systems should also work.

----

## Getting the Loggly Puppet module
The Loggly Puppet module can be obtained as a packaged module from the Puppet Forge, or directly from GitHub.  This is normally done on your Puppet master machine.

### From the Puppet Forge

#### Install the Loggly module using `puppet module`
Puppet can automatically fetch and install modules from the Puppet Forge, a community-maintained repository of useful Puppet modules.

For the Open Source version of Puppet, the default module directory is */etc/puppet/modules*.

```sh
puppet module install -i /etc/puppet/modules loggly-loggly
```

For Puppet Enterprise, the default directory is */etc/puppetlabs/puppet/modules*.

```sh
puppet module install -i /etc/puppetlabs/puppet/modules loggly-loggly
```

 You've now installed the Loggly module into your module path.  More information can be found in the [Installing Modules](http://docs.puppetlabs.com/puppet/3/reference/modules_installing.html) chapter of the Puppet documentation.

### From GitHub

For those who prefer a little more flexibility in their setups, the Loggly Puppet module can be installed directly from GitHub.  This allows you to track your changes and contribute fixes or enhancements back to the community in the form of [pull requests](https://help.github.com/articles/using-pull-requests).

#### Install Git

On Ubuntu:

```sh
apt-get install git
```

On Red Hat/CentOS:
```sh
yum install git
```


#### Change to your puppet module directory
For the Open Source version of Puppet, the default module directory is */etc/puppet/modules*.

    cd /etc/puppet/modules

For Puppet Enterprise, the default directory is */etc/puppetlabs/puppet/modules*.

    cd /etc/puppetlabs/puppet/modules

#### Clone the repo
    git clone https://github.com/loggly/loggly-puppet.git loggly

You've now installed the Loggly module into your module path.
----

## Finding your Customer Token
Now that you've installed the Loggly module into your module path, you'll need a little bit of information before you can configure your Puppet nodes.

Loggly uses a unique identifier called a Customer Token to associate data you send us with your account.  This token is included with data sent to Loggly so that you do not need to store your user name and password to your Loggly account on each node.  Customer Tokens can also be retired from the Loggly interface without disabling your account entirely.

You can use the Customer Token that was automatically generated for you, or create a new one.  If you have several groups of machines, you can create tokens for each group for security.

To obtain or create your Customer Token, visit our [Loggly support article](http://www.loggly.com/docs/customer-token-authentication-token/).  You will need it for the configuration section.

----

## Configuring the Puppet module
### Ubuntu

#### If you use the **rsyslog** daemon
rsyslog is the default syslog daemon on Ubuntu-style distributions, so configuration is very straightforward.
In your Puppet node definition, simply include the Loggly rsyslog class.  You will need your Customer Token you obtained from the Finding your Customer Token section of this guide.

For example:
```puppet
node 'my_server_node.example.net' {
    # Send syslog events to Loggly
    class { 'loggly::rsyslog':
        customer_token => 'de7b5ccd-04de-4dc4-fbc9-501393600000',
    }
}
```
TLS enabled by default in the Loggly syslog-ng module, so data sent from your systems to Loggly is encrypted and safe from unwanted eavesdropping.

#### If you use the **syslog-ng** daemon
syslog-ng is not installed by default on Ubuntu-style distributions, so ensure that the syslog-ng package is installed (a perfect job for Puppet!) before including the Loggly syslog-ng module.  You will need your Customer Token you obtained from the Finding your Customer Token section of this guide.

For example:
```puppet
node 'my_server_node.example.net' {
    # Install the syslog-ng package before configuring Loggly
    package { 'syslog-ng':
        ensure => installed,
        before => Class['loggly::syslog_ng'],
    }

    # Send syslog events to Loggly
    class { 'loggly::syslog_ng':
        customer_token => 'de7b5ccd-04de-4dc4-fbc9-501393600000',
    }
}
```
TLS enabled by default in the Loggly syslog-ng module, so data sent from your systems to Loggly is encrypted and safe from unwanted eavesdropping.

#### Additional information
More information on available configuration options can be found in the source code for the Loggly Puppet module.

### Red Hat/CentOS

#### If you use the rsyslog daemon
rsyslog is the default syslog daemon on Red Hat-style distributions, so configuration is very straightforward.
In your Puppet node definition, simply include the Loggly rsyslog class.  You will need your Customer Token you obtained from the Finding your Customer Token section of this guide.

For example:
```puppet
node 'my_server_node.example.net' {
    # Send syslog events to Loggly
    class { 'loggly::rsyslog':
        customer_token => 'de7b5ccd-04de-4dc4-fbc9-501393600000',
    }
}
```
TLS enabled by default in the Loggly rsyslog module, so data sent from your systems to Loggly is encrypted and safe from unwanted eavesdropping.

#### If you use the syslog-ng daemon
syslog-ng is not installed by default on Red Hat-style distributions, so ensure that the syslog-ng package is installed (a perfect job for Puppet!) before including the Loggly syslog-ng module.  You will need your Customer Token you obtained from the Finding your Customer Token section of this guide.

The syslog-ng package can be found in the [Extra Packages for Enterprise Linux](https://fedoraproject.org/wiki/EPEL) (EPEL) repository.   More information about installing the EPEL repository on your machines can be found at the [Fedora Project](https://fedoraproject.org/wiki/EPEL) site.

For example:
```puppet
node 'my_server_node.example.net' {
    # Install the syslog-ng package before configuring Loggly
    package { 'syslog-ng':
        ensure => installed,
        before => Class['loggly::syslog_ng'],
    }

    # Send syslog events to Loggly
    class { 'loggly::syslog_ng':
        customer_token => 'de7b5ccd-04de-4dc4-fbc9-501393600000',
    }
}
```
Unfortunately, the packages in the EPEL repository for syslog-ng are not compiled with TLS support by default, so TLS is
disabled by default on Red Hat-style distributions.  Data sent from your systems to Loggly will not be encrypted by default.


#### If you want to log custom logfiles

```puppet

node 'my_server_node.example.net' {
    class { 'loggly::rsyslog':
        customer_token => 'de7b5ccd-04de-4dc4-fbc9-501393600000',
    }

    loggly::rsyslog::logfile { "custom-logfile":
        logname  => "custom-logfile",
        filepath => "/var/log/custom-logfile.log"
    }

    loggly::rsyslog::logfile { "mysql":
        logname  => "mysql",
        filepath => "/var/log/mysqld.log"
    }
}
```


#### Additional information
More information on available configuration options can be found in the source code for the Loggly Puppet module.

----

## Finishing up

You now have a functional Puppet configuration for sending your ryslog or syslog-ng data to Loggly, and you didn't even *need* those robots.  See your data flowing into your Loggly account by [logging in to your Loggly dashboard](https://www.loggly.com/login/), where you can search, filter, and manipulate your syslog events.

Now go generate some data!
