# PowerTOP Autotuner alter
PowerTOP autotuner marks as `Good` all the devices on the board, including keyboard/mouse wireless receivers. So they doesn't work properly - sleeps after 3-4 seconds of idle and resumes with delay in ~1-2 seconds. That's sucks.

This service helps to exclude necessary devices from auto-tune. Just create a file `custom.sh` and and fill it with the following lines:
```bash
#!/bin/sh

<powertop command 0>
<powertop command 1>
...
```
, where each `<powertop command X>` is a command from powertop/Tunables.

Run the `powertop` command, visit `Tunables` tab, choose the device(-s) that you want to exclude from auto-tune, press Enter on the device (it will mark as `Bad` automatically) and then copy the command from the top (example: `echo 'on' > '/sys/bus/usb/devices/1-6/power/control';`).

Fill `custom.sh` with the commands, then run `install.sh`. After reboot (or manually start of the `powertop-at-alter` service) your devices will consume enough power to work as intended.
