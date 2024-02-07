# Hands-on 5: extending

Hello, the goal here is to:
* leverage systemd-sysext feature
* boot a Flatcar instance
* pull non-official Podman sysext image
* merge it to the system

# Step-by-step

* Open `./config.yaml` and find the TODO section.
* Add the following section (from https://coreos.github.io/butane/examples/#files):
```
storage:
  files:
    - path: /opt/extensions/podman.raw
      mode: 0644
      contents:
        source: https://github.com/tormath1/flatcar-podman-overlay/releases/download/v4.5.0/podman.raw
```
* Transpile the Butane configuration (`config.yaml`) to Ignition configuration (`config.json`) - it's possible to use Butane binary (https://coreos.github.io/butane/getting-started/#standalone-binary) or Docker image
```
$ docker run --rm -i quay.io/coreos/butane:latest < config.yaml > config.json
```
* Download a Flatcar image (or reuse the zipped one from previous hands-on). NOTE: Ignition runs at first boot, it won't work if you reuse your previous boot image.
```
cp ../hands-on-1/flatcar/flatcar_production_qemu_image.img.bz2 .
bzip2 --decompress --keep ./flatcar_production_qemu_image.img.bz2
cp ../hands-on-1/flatcar/flatcar_production_qemu.sh .
```
* Start the image with Ignition configuration
```
./flatcar_production_qemu.sh -i ./config.json -- -display curses
```
* Once on the instance, assert that the podman extension is downloaded in the right folder, then merge the systemd-sysext extension
```
$ ls /opt/extensions/
podman.raw
$ sudo ln -sv /opt/extensions/podman.raw /etc/extensions/podman.raw
'/etc/extensions/podman.raw' -> '/opt/extensions/podman.raw'
$ ls -l /etc/extensions/
total 0
lrwxrwxrwx. 1 root root 33 Feb  6 14:42 oem-qemu.raw -> /oem/sysext/oem-qemu-3760.2.0.raw
lrwxrwxrwx. 1 root root 26 Feb  6 14:44 podman.raw -> /opt/extensions/podman.raw
$ podman --version
-bash: podman: command not found
$ sudo systemd-sysext refresh
Using extensions 'oem-qemu', 'podman'.
Unmerged '/usr'.
Merged extensions into '/usr'.
$ podman --version
podman version 4.5.0
$ sudo podman run --rm docker.io/alpine echo hello from Podman on Flatcar
```

# Resources

* https://www.flatcar.org/docs/latest/provisioning/sysext/

# Demo

```
asciinema play demo.cast
```

or: https://asciinema.org/a/636549
