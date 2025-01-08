# templating-template

A simple template for AntiRaid templates. To download this, you'll need ``git`` installed. Then clone recursively with ```git clone --recursive``

## Bundling

In order to use this template, you'll need a bundler that supports ``luaurc`` aliases. To make your life simpler, AntiRaid provides a prebuilt version of ``darklua`` with the PR for ``luaurc`` aliases support in as well as type function support. We hope that this PR will be merged upstream soon + type functions added by updating full moon but until then, you can download our prebuilt version of darklua from here: https://github.com/Anti-Raid/darklua/releases. Simply save this file as ``darklua.exe`` (Windows) or ``darklua``.

Simply either double-click ``build.cmd`` (Windows), or run ``make`` (all OS) to build the template. This will create a file called ``output.lua``. Copy paste the template in the AntiRaid website to use.