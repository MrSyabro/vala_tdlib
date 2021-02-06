tdjson_dep = declare_dependency(

	sources: ['tdjson.vapi','tdlog.vapi'],

	dependencies: [

	dependency('Td', modules: [
			'Td::tdjson',
			'Td::tdcore',
			'Td::tdutils',
			'Td::tdsqlite'
	], method:'cmake'),
	meson.get_compiler('cpp').find_library('stdc++'),

	]

)

project_deps = [
	dependency('gio-2.0'),
	dependency('json-glib-1.0'),
	dependency('gee-0.8'),
	tdjson_dep,
]

project_sources = files(
	'TDInterface.vala'
)

tdlib = shared_library('tdlib',
  sources: project_sources,
  dependencies: project_deps,
  install : true)
