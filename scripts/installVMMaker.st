Author useAuthor: 'installVMMaker' during: [
	path := CommandLineArguments default commandLineArguments nextToLast.
	defaultRemoteType := CommandLineArguments default commandLineArguments last asSymbol.

	Iceberg remoteTypeSelector: defaultRemoteType.

	Metacello new
		baseline: 'VMMaker';
			repository: 'tonel://' , path , '/smalltalksrc';
			load.
]
