local
needController({validatorIdAssignment, ...}) =
	if validatorIdAssignment == 'none' || validatorIdAssignment == 'collatorSelection' then false
	else if validatorIdAssignment == 'staking' then true
	else error "unknown validatorIdAssignment: %s" % validatorIdAssignment,
;

{
	relayWantedKeys(root): {
		[if needController(root) then '_controller']: root.signatureSchema,
		_stash: root.signatureSchema,

		gran: 'Ed25519',
		babe: 'Sr25519',
		imon: 'Sr25519',
		para: 'Sr25519',
		asgn: 'Sr25519',
		audi: 'Sr25519',
		// rococo: beefy is required
		beef: 'Ecdsa',

		sessionKeys: {
			grandpa: 'gran',
			babe: 'babe',
			im_online: 'imon',
			authority_discovery: 'audi',
			para_assignment: 'asgn',
			para_validator: 'para',
			beefy: 'beef',
		},
	},
	paraWantedKeys(root, ed = false): {
		[if needController(root) then '_controller']: root.signatureSchema,
		_stash: root.signatureSchema,

		// COMPAT: asset-hub on polkadot uses ed25519 instead of sr25519 for session keys.
		// https://github.com/paritytech/cumulus/blob/d4bb2215bb28ee05159c4c7df1b3435177b5bf4e/parachains/common/src/lib.rs#L57-L62
		aura: if !ed then 'Sr25519' else 'Ed25519',

		sessionKeys: {
			aura: 'aura',
		},
	},
}
