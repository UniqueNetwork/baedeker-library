local {mixinRolloutNodes, ...} = import '../util/mixin.libsonnet';

{
	rewriteNodePaths(paths, for_nodes = true, for_chain = true, percent = 1, leave = null): local mkBin(obj) = if 'bin' in obj then {
		bin: if std.isString(obj.bin) && obj.bin in paths then paths[obj.bin] else obj.bin,
	} else {};
	function(prev) prev + mixinRolloutNodes(prev, function(node) if for_nodes then mkBin(node) else {}, function(chain) if for_chain then mkBin(chain) else {}, percent = percent, leave = leave)
}
