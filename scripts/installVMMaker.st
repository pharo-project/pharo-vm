Author useAuthor: 'installVMMaker' during: [
	| path defaultRemoteType |
	path := CommandLineArguments new commandLineArguments nextToLast.
	defaultRemoteType := CommandLineArguments new commandLineArguments last asSymbol.

	Iceberg remoteTypeSelector: defaultRemoteType.

	Metacello new
		baseline: 'VMMaker';
			repository: 'tonel://' , path , '/smalltalksrc';
			load.
]
