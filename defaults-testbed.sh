package: defaults-testbed
version: v1

# Testbed overlay: redirect the PUBLISH DESTINATION, change nothing else.
#
# Select by appending it to the wrapped group's own chain, e.g.
#     bits build --defaults alidist::o2::testbed  O2
# (bits prepends the release base, so that is really
#  release::alidist::o2::testbed). It must come LAST: readDefaults deep-merges
# the chain in order and the last profile wins per key, so a `testbed` placed
# earlier would have its prefix overwritten by the group's.
#
# WHY THIS EXISTS
#
# The point of the Testbed group is to re-run an existing group's build exactly
# as it runs in production, but pointed at the testbed's own services. That only
# works if the packages keep their production identity, so the certified store
# is reused and nothing recompiles.
#
# A package's hash is computed from its own recipe text, its sources and
# patches, its dependencies' hashes, and the merged env / append_path /
# prepend_path dicts. It is NOT computed from the CVMFS destination: builds are
# relocatable and the store is group-agnostic, and the publish step relocates
# each tarball to the consuming group's path.
#
# So this file declares ONLY a system: block. system: never reaches env, and is
# therefore never hashed. Adding an `env:`, `requires:`, `disable:` or
# `overrides:` key here would change every hash and silently turn a
# store-reusing publish test into a full stack rebuild — which is the exact
# thing the overlay exists to avoid. If you are tempted to add one, it belongs
# in the group's own defaults, not here.
#
# valid_defaults_exempt marks this as a structural/overlay layer rather than a
# build flavor, exactly as defaults-alidist does. A package's valid_defaults
# gate (e.g. O2Physics -> [o2, o2-epn, ...]) is checked only against flavor
# defaults; without this flag `testbed` would be read as a flavor, and any
# package declaring valid_defaults would reject the build outright.
valid_defaults_exempt: true

system:
  # The CVMFS root the testbed publishes into. This is an AUTHORIZATION
  # boundary, and bits fails closed when a recipe-declared prefix disagrees
  # with the one bits-console injects:
  #
  #   CVMFS prefix mismatch: the defaults/recipe prefix %r disagrees with the
  #   authoritative bits-console prefix %r ... a build will not publish while
  #   they differ.
  #
  # So this MUST stay equal to cvmfs_prefix in
  # bits-console/communities/Testbed/ui-config.yaml. That check is the whole
  # reason a wrapped group can be redirected safely: the overlay's prefix is
  # what makes the injected testbed prefix legal, instead of looking like a
  # recipe trying to redirect a build into another group's tree.
  prefix:                     "/cvmfs/test.cvmfs.io"
  cvmfs_user_prefix:          "{prefix}/user"
  cvmfs_releases_template:    "{prefix}/releases/{platform}/Packages/{pkg}/{tag}"
  cvmfs_modules_template:     "{prefix}/{platform}/Modules/modulefiles/{pkg}"
  cvmfs_shared_path_template: "{prefix}/noarch/{pkg}/{tag}"
---
