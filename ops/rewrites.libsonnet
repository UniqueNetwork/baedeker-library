local {mixinAllNodes, ...} = import '../util/mixin.libsonnet';

{
	rewriteNodePaths(paths): local mkBin(obj) = if 'bin' in obj then {
		bin: if std.isString(obj.bin) && obj.bin in paths then paths[obj.bin] else obj.bin,
	} else {};
	function(prev) prev + mixinAllNodes(prev, function(node) mkBin(node), function(chain) mkBin(chain))
}
