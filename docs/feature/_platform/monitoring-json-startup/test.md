# Monitoring JSON startup

Original config parse fails U+FEFF. Integration worker reads BOM-prefixed config+secrets and sends heartbeat/probes. All monitoring tests pass. PowerShell 5.1 parser reports no errors, generated JSON no BOM. No network SSH tunnel is opened by verification.

Results: Original config failed JSON.parse with U+FEFF; normalized config now parses. npm test: 6 passed, 0 failed, 5 pre-existing database integration tests skipped because database test credentials are not configured. Worker regression uses BOM-prefixed config and secrets and successfully sends local fixture heartbeat/probes. PowerShell runner fixture with SSH disabled and fake node exiting 7 returns exit 7; generated config and secrets have no BOM; syntax parser reports zero errors. No duplicate monitoring or matching SSH process was present during inspection. No remote SSH tunnel opened; restart the service through runner.
