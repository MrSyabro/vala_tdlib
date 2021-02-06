project('vala_tdlib', ['vala', 'c', 'cpp'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                     'c_std=gnu11',
                   ],
)

subdir('src')

vala_tdlib_dep = declare_dependency(link_with : tdlib)

