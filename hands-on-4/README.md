# Hands-on 4: updating

Hello, the goal here is to:
* leverage auto-update feature
* boot an old version of Flatcar (stable-3510.2.0)
* provision with ignition from hands-on-2
* control the update

Hint: two services are used:
* update-engine.service: to download the update from a release server (Nebraska)
* locksmithd.service: to handle the reboot strategy

# Resources

* https://www.flatcar.org/docs/latest/setup/releases/update-strategies/

# Demo

```
asciinema play demo.cast
```
