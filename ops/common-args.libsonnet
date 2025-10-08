local {mixinAllNodes, mixinAllChains, ...} = import '../util/mixin.libsonnet';

local
	mixinExtraArgsAllNodes(chain, commonArgs) =
	chain + mixinAllNodes(chain,
		function(node) node { extraArgs+: commonArgs },
		function(chain) {}
	)
;
{
	mixinExtraNodeArgsAllChains(chain, commonArgs):
	mixinAllChains(chain, function(chain, path) mixinExtraArgsAllNodes(chain, commonArgs)),
}
