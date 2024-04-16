valadoc = find_program ('valadoc', required: false)
if valadoc.found()
outdir ='GXml-'+API_VERSION
gtkdoc_outdir ='gxml-'+API_VERSION
valacapi = run_command ('valac', '--api-version', check: false)
driver = '--driver='+valacapi.stdout().strip()
pkgname = '--package-name='+'GXml-'+API_VERSION
pkgversion = '--package-version='+PROJECT_VERSION
vapidirgee = '--vapidir='+gee_vapidir
vapidirgxml = '--vapidir='+join_paths (meson.current_source_dir (),'gxml')
vapidirvapi = '--vapidir='+join_paths (meson.current_source_dir (),'vapi')
docsdir = join_paths (get_option ('datadir'), 'devhelp','books')

driver_ops = []
if valacapi.stdout().version_compare('<0.42')
	message ('Vala is < 0.42: Enabling --driver for documentation')
	driver_ops += driver
endif

custom_target ('libgxml-valadocs',
		input : sources,
		output : outdir,
		command : [valadoc,
			driver_ops,
			'--doclet=devhelp',
			'--force',
			pkgname,
			pkgversion,
			'--pkg=glib-2.0',
			'--pkg=gio-2.0',
			'--pkg=libxml-2.0',
			'--pkg=gee-0.8',
			vapidirgee,
			vapidirgxml,
			configvapi,
			'--directory=@OUTDIR@',
			valasources],
		install : true,
		install_dir : docsdir)
endif
