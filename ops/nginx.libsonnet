local {flattenChains, flattenNodes, ...} = import '../util/mixin.libsonnet';

function(prev)

prev {
	_output+: {
		dockerCompose+: {
			'ops/nginx.conf': std.join('\n\n', [
				local shared = {
					name: chain.path,
				};
				std.join('\n', [
					'upstream %(name)s-websocket {' % shared,
					std.join('\n', [
						'\tserver %s:9944;' % node.hostname
						for [?, node] in (chain?.nodes ?? {})
					]),
					'}',
					'upstream %(name)s-http {' % shared,
					std.join('\n', [
						'\tserver %s:9944;' % node.hostname
						for [?, node] in (chain?.nodes ?? {})
						if !(node?.legacyRpc ?? false)
					] + [
						'\tserver %s:9933;' % node.hostname
						for [?, node] in (chain?.nodes ?? {})
						if (node?.legacyRpc ?? false)
					]),
					'}',
				]),
				for chain in flattenChains(prev)
			] + ['server {', 'listen 80;', 'add_header Access-Control-Allow-Origin *;'] + [
				local shared = {
					name: chain.path,
				};
				std.join('\n', [
					'location /%(name)s/ { try_files /nonexistent @%(name)s-$http_upgrade; }' % shared,
					'location @%(name)s-websocket {' % shared,
					'\tproxy_pass http://%(name)s-websocket;' % shared,
					'\tproxy_http_version 1.1;',
					'\tproxy_set_header Upgrade "websocket";',
					'\tproxy_set_header Connection "upgrade";',
					'}',
					'location @%(name)s- {' % shared,
					'\tproxy_pass http://%(name)s-http;' % shared,
					'}',
				]),
				for chain in flattenChains(prev)
			] + ['}']),
			_composeConfig+:: {
				services+: {
					nginx+: {
						image: 'nginx:latest@sha256:48a84a0728cab8ac558f48796f901f6d31d287101bc8b317683678125e0d2d35',
						volumes+: [
							{
								type: 'bind',
								source: 'ops/nginx.conf',
								target: '/etc/nginx/conf.d/default.conf',
								read_only: true,
							},
						],
						depends_on: [
							node.hostname
							for node in flattenNodes(prev)
						],
					},
				},
			},
		},
	},
}
