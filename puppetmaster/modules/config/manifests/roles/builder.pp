class config::roles::builder {
  require closure
  $build_root = '/opt/media_compile'
  $build_apps_root = "$build_root/apps"
  $build_ve_root = "$build_root/ve"
  $build_envs = ['local', 'dev', 'staging', 'production']
  Exec {
    path      => "${::path}",
    logoutput => on_failure,
  }

  file { "$build_root":
    ensure  => directory,
    owner   => root,
  }
  file { "$build_apps_root":
    ensure  => directory,
    owner   => root,
    require => File[$build_root],
  }
  file { "$build_ve_root":
    ensure  => directory,
    owner   => root,
    require => File[$build_root],
  }
  define build_project () {
    $env = $name
    $project_root = "${build_apps_root}/${env}"
    $project_dir = "${build_apps_root}/${env}/unisubs"

    file { "${project_root}":
      ensure  => directory,
      owner   => root,
    }
    exec { "config::roles::builder::clone_repo_${env}":
      command => "git clone https://github.com/pculture/unisubs.git ${project_dir}",
      creates => "${project_dir}",
      timeout => 900,
      require => [ Package['git-core'], File["${project_root}"] ],
    }
    # unisubs closure library link
    file { "config::roles::builder::unisubs_closure_library_link_build_${env}":
      ensure  => link,
      path    => "${project_dir}/media/js/closure-library",
      target  => "${closure::closure_local_dir}",
      require => [Exec["config::roles::builder::clone_repo_${env}"], Class['closure'] ],
    }
  }

  build_project { $build_envs: 
    require         => [ File[$build_apps_root], File[$build_ve_root] ],
  }
}
