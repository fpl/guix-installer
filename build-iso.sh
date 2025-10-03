#!/bin/sh

# -----------------------------------------------------------------------------
# Utilities
# -----------------------------------------------------------------------------

die() {
    # **
    # Prints a message to stderr & exits script with non-successful code "1"
    # *

    printf '%s\n' "$@" >&2
    exit 1
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------

# Write out the channels file so it can be included
guix time-machine -C './guix/base-channels.scm' -- \
     describe -f channels > './guix/channels.scm' || exit 0
#
# Note that this outputs also specific commits to the channels file, which is not a great
# idea in general...
#

# Build the image
printf 'Attempting to build the image...\n\n'
printf 'Note that this script also builds a full kernel, be sure to have at least 30GBs on /tmp or choose a different TMPDIR for guix-daemon\n\n'
image=$(guix time-machine -C './guix/channels.scm' --substitute-urls='https://ci.guix.gnu.org https://bordeaux.guix.gnu.org https://substitutes.nonguix.org' -- system image -t iso9660 './guix/installer.scm') \
    || die 'Could not create image.'

release_tag=$(date +"%Y%m%d%H%M")
cp "${image}" "./guix-installer-${release_tag}.iso" ||
    die 'An error occurred while copying.'

printf 'Image was succesfully built: %s\n' "${image}"

# cleanup
unset -f die
unset -v image release_tag
