package: defaults-release
version: v1

# CVMFS layout — the single source of truth for where this group's packages,
# modulefiles and noarch content land on CVMFS. The build resolves these
# (%(architecture)s → the effective arch, e.g. x86_64-el8) and records the
# absolute paths in every package's .meta.json (cvmfs_layout); the publish
# pipeline reads them from there, so the path is never re-defined downstream.
cvmfs_dir:   /cvmfs/test.cvmfs.io/releases
install_dir: '%(architecture)s/Packages'
module_dir:  '%(architecture)s/Modules/modulefiles'
shared_dir:  noarch

env:
  CXXFLAGS: "-fPIC -g -O2 -std=c++11"
  CFLAGS: "-fPIC -g -O2"
  CMAKE_BUILD_TYPE: "RELWITHDEBINFO"

requires:
  - lcg.bits
---
