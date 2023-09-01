{
	setSudo(address): {
		_genesis+: {
			sudo+: {
				key: address,
			},
		}
	},
	resetBalances: {
		_genesis+: {
			balances+: {
				balances: [],
			},
		},
	},
	giveBalance(address, amount): {
		_genesis+: {
			balances+: {
				balances+: [
					[address, amount],
				],
			},
		},
	},
	setParaId(id): function(prev) prev {
		_genesis+: {
			parachainInfo+: { parachainId: id },
		},
		// COMPAT: cumulus template
		[if 'para_id' in prev then 'para_id']: id,
	},
	resetSessionKeys: {
		_genesis+: {
			session+: {
				keys: [],
			},
		}
	},
	addSessionKey(key): {
		_genesis+: {
			session+: {
				keys+: [key],
			},
		},
	},
	resetAuraKeys: {
		_genesis+: {
			aura+: {
				authorities: [],
			},
		},
	},
	addAuraKey(key): {
		_genesis+: {
			aura+: {
				authorities+: [key],
			},
		},
	},
	resetCollatorSelectionInvulnerables: {
		_genesis+: {
			collatorSelection+: {
				invulnerables: [],
			},
		}
	},
	addCollatorSelectionInvulnerable(key): {
		_genesis+: {
			collatorSelection+: {
				invulnerables+: [key],
			},
		},
	},
	resetParachainStakingCandidates: {
		_genesis+: {
			parachainStaking+: {
				candidates: [],
			},
		},
	},
	addParachainStakingCandidate(key): {
		_genesis+: {
			parachainStaking+: {
				candidates+: [key],
			},
		},
	},
	resetStakingInvulnerables: {
		_genesis+: {
			staking+: {
				invulnerables: [],
			},
		},
	},
	addStakingInvulnerable(key): {
		_genesis+: {
			staking+: {
				invulnerables+: [key],
			},
		},
	},
	resetStakingStakers: {
		_genesis+: {
			staking+: {
				stakers: [],
			},
		},
	},
	addStakingStaker(key): {
		_genesis+: {
			staking+: {
				stakers+: [key],
			},
		},
	},
	setStakingValidatorCount(count): {
		_genesis+: {
			staking+: {
				validatorCount: count,
			},
		},
	},
	resetAuthorMappingMappings: {
		_genesis+: {
			authorMapping+: {
				mappings: [],
			},
		},
	},
	addAuthorMappingMapping(key): {
		_genesis+: {
			authorMapping+: {
				mappings+: [key],
			},
		},
	},
	resetParas: {
		_genesis+: {
			paras+: {
				paras: [],
			},
		},
	},
	addPara(para_id, head, wasm, parachain = true): {
		_genesis+: {
			paras+: {
				paras+: [[
					para_id,
					{
						genesis_head: head,
						validation_code: wasm,
						parachain: parachain,
					},
				]],
			},
		},
	},

	resetHrmps: {
		_genesis+: {
			hrmp+: {
				preopenHrmpChannels: [],
			},
		},
	},
	openHrmp(sender, receiver, maxCapacity, maxMessageSize): {
		_genesis+: {
			hrmp+: {
				preopenHrmpChannels+: [
					[sender, receiver, maxCapacity, maxMessageSize],
				],
			},
		},
	},

	resetNetworking(root): {
		assert !(super?._networkingWasReset ?? false): 'network should not be reset twice',

		bootNodes: [
			'/dns/%s/tcp/30333/p2p/%s' % [node.hostname, node.nodeIdentity],
			for [?, node] in root.nodes
		],
		chainType: 'Live',
		telemetryEndpoints: [],
		codeSubstitutes: {},

		// COMPAT: cumulus template
		// In baedeker, relay chain config is passed explicitly, rendering this argument to not being used
		[if 'relay_chain' in root then 'relay_chain']: 'not_used',

		_networkingWasReset:: true,
	},

	simplifyGenesisName(): function(prev)
	local genesisKind = if 'runtime_genesis_config' in prev.genesis.runtime then 'rococo' else 'sane';
	prev {
		_genesisKind: genesisKind,
	} +
	if genesisKind == 'rococo' then {
		_genesis::: prev.genesis.runtime.runtime_genesis_config,
		genesis+: {
			runtime+: {
				runtime_genesis_config:: error 'unsimplify genesis name first',
			},
		},
	} else {
		_genesis::: prev.genesis.runtime,
		genesis+: {
			runtime:: error 'unsimplify genesis name first',
		},
	},

	unsimplifyGenesisName(): function(prev)
	prev {
		_genesis:: error 'simplify genesis name first',
		_genesisKind:: error 'genesis was resimplified',
	} +
	if prev?._genesisKind == 'rococo' then {
		genesis+: {
			runtime+: {
				runtime_genesis_config::: prev._genesis,
			},
		},
	} else if prev?._genesisKind == 'sane' then {
		genesis+: {
			runtime::: prev._genesis,
		},
	} else error 'unknown genesis kind: %s' % [prev._genesis],

	// FIXME: Merge polkaLaunchRelay and polkaLaunchPara?
	// Due to refactoring, pararelays are somewhat supported.

	polkaLaunchShared(root): [
		function(prev) if 'sudo' in prev._genesis then bdk.mixer([
			// On moonbeam it is not alice, but alith, which requires soft derivation path,
			// which is not even supported due to (see FIXME on cql.ecdsaSeed)
			// TODO: Implement soft derivations in cql.ecdsaSeed, and add another account on `root.signatureSchema == 'Ethereum'`?
			$.setSudo(root.addressSeed('//Alice')),
		])(prev) else prev,
		$.resetBalances,
		$.giveBalance(root.addressSeed('//Alice'), 2000000000000000000000000000000),
		$.giveBalance(root.addressSeed('//Bob'), 2000000000000000000000000000000),
		// Regardless of validator id assignment, every method (staking/collator-selection/etc) wants stash to have some
		// money.
		[
			$.giveBalance(node.wallets.stash, 2000000000000000000000000000000),
			for [?, node] in root.nodes
		],
		// pallet-session manages pallet-aura/pallet-grandpa, if there is no pallet-session: authority should be set directly for aura.
		// pallet-aura also should not have keys, if there keys are specified using pallet-aura.
		function(prev) bdk.mixer([
			if 'session' in prev._genesis then $.resetSessionKeys,
			if 'aura' in prev._genesis then $.resetAuraKeys,
		])(prev),
		function(prev) bdk.mixer(if 'session' in prev._genesis then [
			$.addSessionKey([
				// Account id
				if root.validatorIdAssignment == 'staking' then node.wallets.controller
				else node.wallets.stash,
				// Validator id
				node.wallets.stash,
				local k = node.keys; {
					[name]: k[key]
					for [name, key] in node.wantedKeys.sessionKeys
				},
			])
			for [?, node] in root.nodes
		] else if 'aura' in prev._genesis then [
			$.addAuraKey(node.keys.aura)
			for [?, node] in root.nodes
		] else [])(prev),
	],

	// Alter spec in the same way as polkadot-launch does this, in most cases this should
	// be everything needed to start working node
	polkaLaunchRelay(root, hrmp = []): $.polkaLaunchShared(root) + [
		function(prev) if 'staking' in prev._genesis then bdk.mixer([
			$.resetStakingInvulnerables,
			$.resetStakingStakers,
			[
				[
					$.addStakingInvulnerable(node.wallets.stash),
					$.addStakingStaker([
						node.wallets.stash,
						node.wallets.controller,
						100000000000000,
						'Validator',
					]),
				],
				for [?, node] in root.nodes
			],
			$.setStakingValidatorCount(std.length(root.nodes)),
		])(prev) else prev,
		function(prev) bdk.mixer([
			[
				$.resetParas,
			],
			[
				// FIXME: Also bump parachainRegistrar last id if para_id >= 2000?
				$.addPara(para.paraId, para.genesisHead, para.genesisWasm),
				for [paraname, para] in root.parachains
			],
		])(prev),
		function(prev) bdk.mixer([
			[
				$.resetHrmps,
			],
			[
				$.openHrmp(ch[0], ch[1], ch[2], ch[3]),
				for ch in hrmp
			],
		])(prev),
		function(prev) if 'configuration' in prev._genesis then prev {
			_genesis+: {
				configuration+: {
					config+: {
						hrmp_max_parachain_outbound_channels: 20,
						hrmp_max_parathread_outbound_channels: 20,
						hrmp_max_parachain_inbound_channels: 20,
						hrmp_max_parathread_inbound_channels: 20,
						pvf_checking_enabled: true,
						max_validators: 300,
						max_validators_per_core: 20,
						scheduling_lookahead: 1,
					},
				},
			},
		} else prev,
		// function(prev) std.trace(prev),
	],
	polkaLaunchPara(root): $.polkaLaunchShared(root) + [
		function(prev) if 'collatorSelection' in prev._genesis then bdk.mixer([
			$.resetCollatorSelectionInvulnerables,
			[
				$.addCollatorSelectionInvulnerable(node.wallets.stash),
				for [?, node] in root.nodes
			],
		])(prev) else prev,

		$.setParaId(root.paraId),
		// COMPAT: moonbeam
		function(prev) if 'parachainStaking' in prev._genesis then bdk.mixer([
			$.resetParachainStakingCandidates,
			[
				$.addParachainStakingCandidate([node.wallets.stash, 10000000000000000000000000]),
				for [?, node] in root.nodes
			],
		])(prev) else prev,
		// COMPAT: moonbeam
		function(prev) if 'authorMapping' in prev._genesis then bdk.mixer([
			$.resetAuthorMappingMappings,
			[
				$.addAuthorMappingMapping([node.keys?.aura ?? node.keys.nmbs, node.wallets.stash]),
				for [?, node] in root.nodes
			],
		])(prev) else prev,
	],

	genericRelay(root, hrmp = []): bdk.mixer([
		$.resetNetworking(root),
		$.simplifyGenesisName(),
		$.polkaLaunchRelay(root, hrmp),
		$.unsimplifyGenesisName(),
	]),
	genericPara(root): bdk.mixer([
		$.resetNetworking(root),
		$.simplifyGenesisName(),
		$.polkaLaunchPara(root),
		$.unsimplifyGenesisName(),
	]),
}
