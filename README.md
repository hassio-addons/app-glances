# Home Assistant Add-on: Glances (Patched)

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]

[![Github Actions][github-actions-shield]][github-actions]
![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]

> **Maintained by [Florian Horner][maintainer].**
> Based on the original [hassio-addons/addon-glances][upstream] by [Franck Nijhof][frenck].

Glances is a cross-platform system monitoring tool written in Python.

![The Glances Hass.io add-on](images/screenshot.png)

## Why this fork exists

The upstream [hassio-addons/addon-glances][upstream] add-on ships Glances 4.3.2
with a first-boot crash (502 Bad Gateway) and deprecated CI config.
I forked it to get a working install, then added MQTT export since the
plumbing was already there.

Bug fixes have been submitted upstream as PRs. Fork-only features
(MQTT export, security hardening) go beyond what upstream currently offers.

## What changed here

### Sent upstream / pending upstream

| Change | Upstream PR |
|--------|------------|
| Remove deprecated `codenotary` signing + `armv7` | [hassio-addons/addon-glances#603][upstream-603] |
| Fix 502 on first boot (`mkdir -p /config`) | [hassio-addons/addon-glances#604][upstream-604] |
| Full modernization (MQTT, hardening, deps) | [hassio-addons/addon-glances#609][upstream-609] |

### Fork-only changes

- **MQTT export** — full config, docs, and `--export mqtt` flag
- **InfluxDB consolidation** — single Glances process handles web UI + export (removed separate `influxdb/run` service)
- **InfluxDB version validation** — error on unsupported version instead of silent misconfiguration
- **Security hardening** — Content-Security-Policy, HSTS, Host header fix, `client_max_body_size` 4G → 1m, removed deprecated `X-XSS-Protection`
- **Nginx restart supervision** — automatic restart on crash without container restart
- **CI hardening** — workflow refs pinned to commit hash, ShellCheck added
- **Dependency cleanup** — removed dead packages (`netifaces`, `scandir`)
- **ShellCheck directives** — added to all shell scripts

## About

Glances is a cross-platform monitoring tool which aims to present a maximum of
information in a minimum of space through a Web-based interface.

Glances can export all system statistics to InfluxDB and/or MQTT, allowing
you to look at all your system information and its behavior over time.

[:books: Read the full add-on documentation][docs]

## Installation

Add this repository to your Home Assistant add-on store:

```
https://github.com/florianhorner/addon-glances-patched
```

Then install "Glances" from the store and follow the [documentation][docs].

## Switch back to upstream

If your only need was the first-boot fix and it gets merged upstream:

1. Remove this repository URL from your add-on store
2. Re-add the original: `https://github.com/hassio-addons/addon-glances`
3. Reinstall Glances from the store and restart

MQTT export and security hardening are fork-only — switching back
will remove those features.

## Support

Got questions?

- [Open an issue][issue] on this fork's GitHub.
- The [Home Assistant Discord chat server][discord-ha] for general Home
  Assistant discussions and questions.
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

## Contributing

This is an active open-source project. Contributions are welcome.

See our [contribution guidelines](.github/CONTRIBUTING.md).

## Authors & contributors

The original add-on was created by [Franck Nijhof][frenck].
This fork is maintained by [Florian Horner][maintainer].

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License

Copyright (c) 2019-2025 Franck Nijhof

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-no-red.svg
[armv7-shield]: https://img.shields.io/badge/armv7-no-red.svg
[commits-shield]: https://img.shields.io/github/commit-activity/y/florianhorner/addon-glances-patched.svg
[commits]: https://github.com/florianhorner/addon-glances-patched/commits/main
[contributors]: https://github.com/florianhorner/addon-glances-patched/graphs/contributors
[discord-ha]: https://discord.gg/c5DvZ4e
[docs]: https://github.com/florianhorner/addon-glances-patched/blob/main/glances/DOCS.md
[forum]: https://community.home-assistant.io/t/home-assistant-community-add-on-glances/97102
[frenck]: https://github.com/frenck
[github-actions-shield]: https://github.com/florianhorner/addon-glances-patched/workflows/CI/badge.svg
[github-actions]: https://github.com/florianhorner/addon-glances-patched/actions
[i386-shield]: https://img.shields.io/badge/i386-no-red.svg
[issue]: https://github.com/florianhorner/addon-glances-patched/issues
[license-shield]: https://img.shields.io/github/license/florianhorner/addon-glances-patched.svg
[maintainer]: https://github.com/florianhorner
[maintenance-shield]: https://img.shields.io/maintenance/yes/2026.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-production-green.svg
[reddit]: https://reddit.com/r/homeassistant
[releases-shield]: https://img.shields.io/github/release/florianhorner/addon-glances-patched.svg
[releases]: https://github.com/florianhorner/addon-glances-patched/releases
[repository]: https://github.com/florianhorner/addon-glances-patched
[upstream]: https://github.com/hassio-addons/addon-glances
[upstream-603]: https://github.com/hassio-addons/addon-glances/pull/603
[upstream-604]: https://github.com/hassio-addons/addon-glances/pull/604
[upstream-609]: https://github.com/hassio-addons/addon-glances/pull/609
