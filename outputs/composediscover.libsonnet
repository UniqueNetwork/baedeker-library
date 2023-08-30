local {flattenNodes, flattenChains, ...} = import '../util/mixin.libsonnet';

function(prev)
prev + {
	_output+:: {
		dockerComposeDiscover+: std.join('\n', [
			'%s_ID=%i' % [std.strReplace(std.asciiUpper(chain.path), '-', '_'), chain.paraId]
			for chain in flattenChains(prev)
			if 'paraId' in chain
		] + [
			'%s_HTTP_URL=http://BALANCER_URL/%s/' % [std.strReplace(std.asciiUpper(chain.path), '-', '_'), chain.path]
			for chain in flattenChains(prev)
		] + [
			'%s_URL=ws://BALANCER_URL/%s/' % [std.strReplace(std.asciiUpper(chain.path), '-', '_'), chain.path]
			for chain in flattenChains(prev)
		] + ['']),
	},
}
