local {flattenChains, flattenNodes, ...} = import '../util/mixin.libsonnet';

function(prev) prev {
	_output+: {
		dockerCompose+: {
			_nginxLocations+:: [
				'location /apps/ { proxy_pass http://polkadot-apps/; }',
			],
			_nginxDependencies+:: ['polkadot-apps'],
			_composeConfig+:: {
				services+: {
					'polkadot-apps': {
						// TODO: We can provide custom endpoint list to this container using ENV. But changes to this file are needed.
						// https://github.com/polkadot-js/apps/blob/0366991f685a80147f46eb69a23285acb15bc6b7/packages/apps-config/src/endpoints/development.ts#L19
						image: 'jacogr/polkadot-js-apps:latest@sha256:af85e4a4449f2483e90ab4965214a527225f6d1f1fb7a71f8b514f7e0e467b20',
					},
				},
			},
			// Yep, sorry for this
			'ops/index.html': std.strReplace(importstr './debug.ejs', 'DATA_JSON', std.manifestJson({
				chains: [
					{
						path: chain.path,
					},
					for chain in flattenChains(prev)
				],
			})),
		},
	},
}
