# Hands-on 4: updating

Hello, the goal here is to:
* leverage auto-update feature
* boot an old version of Flatcar (stable-3374.2.5 for example)
* provision with ignition from hands-on-2
* control the update

Hint: two services are used:
* update-engine.service: to download the update from a release server (Nebraska)
* locksmithd.service: to handle the reboot strategy

# Step-by-step

```
# download a previous version of Flatcar and the qemu help
$ wget https://stable.release.flatcar-linux.net/amd64-usr/3374.2.5/flatcar_production_qemu_image.img.bz2
$ wget https://stable.release.flatcar-linux.net/amd64-usr/3374.2.5/flatcar_production_qemu.sh
$ chmod +x flatcar_production_qemu.sh
$ bzip2 -dk ./flatcar_production_qemu_image.img.bz2
# boot the instance with the nginx Ignition from a previous lab
$ ./flatcar_production_qemu.sh -i ../hands-on-2/config.json -- -display curses
# assert that `locksmithd.service` and `update-engine` are up and running
$ systemctl status update-engine.service locksmithd.service
# check the release number
$ cat /etc/os-release
# to accelerate the update, we can force it. NOTE: IT'S NOT REQUIRED TO DO THIS IN "REAL LIFE" IT'S JUST TO AVOID WAITING MINUTES BEFORE DOWNLOADING THE UPDATE
$ update_engine_client -update
# once rebooted
# check the release number
$ cat /etc/os-release
# assert that nginx is still running
$ curl localhost
```

# Resources

* https://www.flatcar.org/docs/latest/setup/releases/update-strategies/

# Demo

```
asciinema play demo.cast
```
