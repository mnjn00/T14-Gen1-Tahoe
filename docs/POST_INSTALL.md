# Post-install Checks

Run these from `T14_Tahoe_DYTC_TOOLS_V12` on the T14.

1. CPU PM check:

```text
05_CHECK_INTEL_CPU_PM_AFTER_REBOOT.command
```

2. Continuity check:

```text
06_CHECK_CONTINUITY_STATUS.command
07_ENABLE_HANDOFF_BEST_EFFORT.command
```

3. Battery/audio check:

```text
08_CHECK_BATTERY_AUDIO_STATUS.command
```

4. VoodooHDA volume fix if volume HUD appears but actual output level does not change:

```text
09_INSTALL_VOODOOHDA_VOLUME_FIX_V58.command
```

Reboot once after installing VoodooHDA.
