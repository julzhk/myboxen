require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # node versions
  nodejs::version { '0.8': }
  nodejs::version { '0.10': }
  nodejs::version { '0.12': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.8': }
  ruby::version { '2.2.4': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}

include osx::finder::unhide_library
include osx::finder::show_hidden_files
include osx::safari::enable_developer_mode
include osx::finder::show_all_filename_extensions
include osx::finder::no_file_extension_warnings
include osx::safari::enable_developer_mode

# set your own dock size
class { 'osx::dock::icon_size':
  size => 20
}

# ...  ('right', 'left', 'top', 'bottom')
class { 'osx::dock::position':
  position => 'bottom'
}

# some more custom apps
# include textwrangler
include dropbox
include charles
include evernote
include keepassx
include tower
include vagrant_manager
include chrome
include skitch
include spotify
include steam
include pgadmin3
include slack
include appcleaner
include quotefixformac
include ccleaner
include graphviz
include caffeine
include kindle
include pycharm

include iterm2::stable


include sublime_text_2
sublime_text_2::package { 'Emmet':
  source => 'sergeche/emmet-sublime'
}





include dockutil

dockutil::item { 'Add iTerm':
        item     => "/Applications/iTerm.app",
        label    => "iTerm",
        action   => "add",
        position => 2,
    }