conf = configuration_data()
conf.set ('API_VERSION', API_VERSION)
conf.set ('VERSION', PROJECT_VERSION)

debian_changelog = configure_file(input : 'changelog.in',
	output : 'changelog',
	configuration : conf)

debian_control = configure_file(input : 'control.in',
	output : 'control',
	configuration : conf)

debian_copyright = configure_file(input : 'copyright.in',
	output : 'copyright',
	configuration : conf)
	
debian_gir = configure_file(input : 'gir1.2-gxml.install.in',
	output : 'gir1.2-gxml-@0@-install'.format(API_VERSION),
	configuration : conf)
	
debian_bin = configure_file(input : 'libgxml-0.install.in',
	output : 'libgxml-@0@-0-install'.format(API_VERSION),
	configuration : conf)

debian_dev = configure_file(input : 'libgxml-dev.install.in',
	output : 'libgxml-@0@-dev-install'.format(API_VERSION),
	configuration : conf)

install_data([
        debian_changelog,
        debian_control,
        debian_copyright,
        debian_gir,
        debian_bin,
        debian_dev
    ],
    install_dir : meson.current_source_dir())
