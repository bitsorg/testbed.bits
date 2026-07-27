package: defaults-release
version: v1

# CVMFS path templates — this group's declaration of where its packages,
# modulefiles and noarch content land on CVMFS (its structural choice). Under
# system: so they never affect a package hash. The build records them in each
# package's .meta.json (cvmfs_templates); the publish pipeline resolves them
# ({prefix} = the group/user CVMFS root, {platform}/{pkg}/{tag} per package),
# so the path is never re-defined downstream.
system:
  # {prefix} is the group ROOT (auth boundary). bits-console (ui-config.yaml:
  # cvmfs_prefix) injects the authoritative value, which WINS; the value below MUST
  # match it (kept in sync by bits-admin PR) or an injected build refuses to publish.
  # It lets local `bits build` (no injection) work and is a checked declaration.
  prefix:                     "/cvmfs/bits.cern.ch"
  cvmfs_user_prefix:          "{prefix}/user"
  cvmfs_releases_template:    "{prefix}/releases/{platform}/Packages/{pkg}/{tag}"
  cvmfs_modules_template:     "{prefix}/{platform}/Modules/modulefiles/{pkg}"
  cvmfs_shared_path_template: "{prefix}/noarch/{pkg}/{tag}"

env:
  # No CXXFLAGS here: testbed is only an umbrella for testing. The C++ standard
  # is owned by the compiler-axis defaults (defaults-gccNN / defaults-clang),
  # never the base profile, so it is never silently forced to an old value.
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"

requires:
  - lcg.bits
---
