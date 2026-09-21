# VelaSU Manager Quick App

The Manager is intentionally an unprivileged Vela Quick App.

Current bootstrap protocol:

1. Launch Manager once. It creates `internal://files/velasu_manager.marker`.
2. Switch to the VelaSU Bootstrap watchface.
3. Tap **ACTIVATE**.
4. The watchface locates the Manager sandbox under `/data`, loads the
   non-persistent native probe, runs read-only capability checks, and writes
   `velasu_probe.json` into the Manager sandbox.
5. Return to Manager. It polls and displays the result.

No arbitrary shell command interface is exposed to the Quick App at this stage.
