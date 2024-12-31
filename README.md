# templating-template

A simple template for AntiRaid templates.

## Bundling

In order to use this template, you'll need a bundler that supports ``luaurc`` aliases. To make your life simpler, AntiRaid provides a prebuilt version of ``darklua`` with the PR for ``luaurc`` aliases support in. We hope that this PR will be merged upstream soon but until then, you can download our prebuilt version of darklua from here: https://github.com/Anti-Raid/darklua/releases/tag/v100LUA. Simply save this file as ``darklua.exe`` (Windows) or ``darklua``.

Simply either double-click ``build.cmd`` (Windows), or run ``make`` (all OS) to build the template. This will create a file called ``output.lua``. Copy paste the template in the AntiRaid website to use.