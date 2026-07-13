package: defaults-release
version: v1

# CVMFS path templates — this group's declaration of where its packages,
# modulefiles and noarch content land on CVMFS (its structural choice). Under
# system: so they never affect a package hash. The build records them in each
# package's .meta.json (cvmfs_templates); the publish pipeline resolves them
# ({prefix} = the group/user CVMFS root, {platform}/{pkg}/{tag} per package),
# so the path is never re-defined downstream.
system:
  prefix:                     "/cvmfs/test.cvmfs.io/releases"
  cvmfs_user_prefix:          "{prefix}/user"
  cvmfs_path_template:        "{prefix}/{platform}/Packages/{pkg}/{tag}"
  cvmfs_modules_template:     "{prefix}/{platform}/Modules/modulefiles/{pkg}"
  cvmfs_shared_path_template: "{prefix}/noarch/{pkg}/{tag}"

env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++11"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"

requires:
  - lcg.bits
---
