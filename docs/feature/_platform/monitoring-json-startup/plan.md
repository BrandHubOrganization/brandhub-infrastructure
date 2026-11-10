# Monitoring JSON startup

Node removes only leading U+FEFF before JSON.parse for config/secrets. PowerShell writes UTF-8 without BOM and propagates worker exit code after cleanup. Normalize existing config BOM without printing data. No remote tunnel change.
