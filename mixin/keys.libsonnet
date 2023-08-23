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
	paraWantedKeys(root): {
		[if needController(root) then '_controller']: root.signatureSchema,
		_stash: root.signatureSchema,

		aura: 'Sr25519',

		sessionKeys: {
			aura: 'aura',
		},
	},
}
