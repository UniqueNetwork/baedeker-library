local {mixinRolloutNodes, mixinAllChains, ...} = import '../util/mixin.libsonnet';

{
	mixinExtraArgsAllNodes(chain, commonArgs):
	chain + mixinRolloutNodes(chain,
		function(node) node { extraArgs: commonArgs },
		function(chain) {}
	),

	extraArgsAllNodes(commonArgs):
	function(prev) self.mixinExtraArgsAllNodes(prev, commonArgs),

	mixinExtraNodeArgsAllChains(chain, commonArgs):
	mixinAllChains(chain, function(chain, path) self.mixinExtraArgsAllNodes(chain, commonArgs)),

	extraNodeArgsAllChains(commonArgs):
	function(prev) self.mixinExtraNodeArgsAllChains(prev, commonArgs),
}
