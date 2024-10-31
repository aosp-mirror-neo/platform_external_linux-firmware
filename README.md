# About the linux-firmware project

Please be aware that this project is not just a local Android project.
It is actually intended to (roughly--see NOTES below) match up with the
upstream git repository hosted at:

<https://gitlab.com/kernel-firmware/linux-firmware.git>

Mirrored at:

<https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/>

See also the [upstream README.md].

The local Android project is managed with [Copybara], though used in a
slightly non-standard way. In order to fit into Android's infrastructure
that tracks licensing and also to let us to update each firmware
individually, our [Copybara] script doesn't act on the whole repo. Instead it
acts on smaller groups of upstream files and keeps each group in its own
directory.

Each group is a logical set of files that someone may want to include in
an Android product. All files in a given group must share the same license.
If two files normally go together but share different licenses then they'll
need separate groups and Android products will simply need to know to include
both groups.

## How to use this firmware in your Android product

First and foremost, you should **talk to the legal counsel** for your
Android product and make sure they have no problems with you including
any firmware that you want. Nearly all firmware here is classified with
a licnese that is "By Exception Only". That's normal / expected but you
still need to get approval.

After you've got approval, including this firmware in your Android product
is as simple as adding to your `PRODUCT_PACKAGES`. For instance, if you
wanted to include the r8152 firmware:

```
PRODUCT_PACKAGES += linux_firmware_r8152
```

## How to get your firmware added

In order to get firmware added to this repo, the process is roughly:

* Submit firmware to the upstream linux-firmware repo following
  instructions in the [upstream README.md].
* Add/modify a `firmware_import_workflow` to the [copy.bara.sky] file and
  land it as an `ANDROID:` change.
* Run `./run_copybara.sh ${NAME}`. That will generate an `IMPORT` CL for you.

The [Copybara] script should handle parsing the [upstream WHENCE] file
for you to confirm that you specified the correct licenses. If it gives
an error it's possible that you may need to improve the [copy.bara.sky]
script's license grokking logic.

Importing firmware files to this repo is considered a 3rd party import
and thus needs approval. Details in [go/android-linux-firmware-approval-flow].

If we have to (due to an urgent bugfix), there's no technical reason
we couldn't make local changes to firmware here, but this is
**strongly discouraged** because any of your changes will be lost the
next time someone runs [Copybara] for your firmware. If there is no
choice then special approval will be needed.

## Try to install only firmware you need

When thinking about getting firmware installed, remember that disk space
is at a premium. Products should specify exactly which firmware they need.
In other words, you'll want to create a group for "Marvell 8897 SDIO WiFi"
part, probably not "Marvell WiFi" or (even worse) a group of all firmare
for "Marvell".

## What about files that aren't appropriate for upstream linux-firmware?

If you have firmware that is not appropriate for the upstream
linux-firmware project then this isn't the repository you're looking for.
In such a case you should find another place to put your firmware.

Before trying to find another place for your firmware, however, please
remember that there's a pretty big benefit to getting firmware landed
in the upstream linux-firmware project. Notably we _want_ upstream to be
testing / using the same firmware that Android is using.  This makes it
more likely for our systems to keep working across kernel uprevs and also
more likely that someone upstream will fix a problem and we'll get the fix
through stable merges.

[Copybara]: https://github.com/google/copybara
[copy.bara.sky]: ./copy.bara.sky
[go/android-linux-firmware-approval-flow]: https://goto.google.com/android-linux-firmware-approval-flow
[upstream README.md]: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/README.md
[upstream WHENCE]: https://git.kernel.org/pub/scm/linux/kernel/git/firmware/linux-firmware.git/tree/WHENCE
[go/android-linux-firmware]: https://goto.google.com/android-linux-firmware
