conf = configuration_data()
conf.set ('API_VERSION', API_VERSION)
conf.set ('VERSION', PROJECT_VERSION)

configure_file(input : 'changelog.in',
	output : 'changelog',
	configuration : conf,
	install : true,
	install_dir : meson.current_source_dir())

configure_file(input : 'control.in',
	output : 'control',
	configuration : conf,
	install : true,
	install_dir : meson.current_source_dir())

configure_file(input : 'copyright.in',
	output : 'copyright',
	configuration : conf,
	install : true,
	install_dir : meson.current_source_dir())
	
configure_file(input : 'gir1.2-gxml.install.in',
	output : 'gir1.2-gxml-@0@-install'.format(API_VERSION),
	configuration : conf,
	install : true,
	install_dir : meson.current_source_dir())
	
configure_file(input : 'libgxml-0.install.in',
	output : 'libgxml-@0@-0-install'.format(API_VERSION),
	configuration : conf,
	install : true,
	install_dir : meson.current_source_dir())

configure_file(input : 'libgxml-dev.install.in',
	output : 'libgxml-@0@-dev-install'.format(API_VERSION),
	configuration : conf,
	install : true,
	install_dir : meson.current_source_dir())
