# testbed.bits

The test community for [bits](https://github.com/bitsorg/bits) and
[bits-console](https://gitlab.cern.ch/buncic/bits-console). It is used to re-run another
community's real build, unchanged, and publish the result to the self-contained CVMFS
publishing testbed ([cvmfs-testbed](https://github.com/bitsorg/cvmfs-testbed): its own
gateway, cvmfs-prepub, Stratum 0/1 and object store, serving the repository
`test.cvmfs.io`) instead of the production repository `bits.cern.ch`. Publishing changes can
therefore be tried end to end without touching production and without recompiling a stack.

The repository holds no package recipes, only one defaults file, `defaults-testbed.sh`. It is
an overlay that changes a single setting, `system.cvmfs_repository: test.cvmfs.io`, so a
group's tree moves from `/cvmfs/bits.cern.ch/<group>/...` to `/cvmfs/test.cvmfs.io/<group>/...`
and everything below the repository name stays as in production. In the
[bits-providers](https://github.com/bitsorg/bits-providers) registry, `testbed.bits` is listed
as the test community and requires [stacks.bits](https://github.com/bitsorg/stacks.bits),
which in turn requires [lcg.bits](https://github.com/bitsorg/lcg.bits).

## Getting started: trying the overlay locally

You can add the overlay to a group's build on your own machine to check what it resolves to.
Get bits as described in the [bits README](https://github.com/bitsorg/bits#installation),
then put this repository on the recipe search path of the group's build and add `testbed`
at the end of its defaults chain:

```bash
bits init testbed.bits                # or: git clone https://github.com/bitsorg/testbed.bits
bits init lhcb.bits && cd lhcb.bits   # the group whose build you want to re-run

bits build --dry-run --search-path "$PWD/../testbed.bits" \
           --defaults lhcb::gcc14::opt::testbed --set release=LCG_110 \
           --architecture x86_64-el9 lcg-view
```

Because the hashes are unchanged, the plan lists the same packages as the build without
`testbed`. For ALICE the chain is `alidist::o2::testbed`. To see the CVMFS path a package
would be published to, run
[`bits cvmfs-path`](https://github.com/bitsorg/bits/blob/main/docs/REFERENCE.md#bits-cvmfs-path)
with the same `--search-path`, `--defaults` and `--set` options.

## Notes for testbed users

### Why the overlay changes nothing else

A package's hash comes from its recipe, sources, patches, dependencies and the merged
`env:` of the defaults, not from where it is published. The `system:` block is never hashed,
so a build with `testbed` added has the same package hashes as the production build: the
certified store is reused and only the publish destination changes. Adding `env:`,
`requires:`, `disable:` or `overrides:` to `defaults-testbed.sh` would change every hash and
turn a publishing test into a full rebuild; such settings belong in the group's own
defaults.

`defaults-testbed.sh` is marked `valid_defaults_exempt: true`, so packages that restrict their
defaults with `valid_defaults` (for example ALICE's O2) accept it as a structural layer
rather than a build flavour.

### How it is used in testing

The **Testbed** community in bits-console (`communities/Testbed/ui-config.yaml`) is set up
as follows:

- `group_recipes` is this repository, and the community whose build is re-run (for example
  `lhcb.bits` or `alice.bits`) is added as an extra provider in **Settings -> Providers**; the
  CI job puts it on the recipe search path.
- `defaults_overlay: testbed`: the console appends `testbed` as the **last** element of
  whatever defaults chain the build selects, e.g. `alidist::o2` becomes
  `alidist::o2::testbed`. It must come last, because later profiles win when the chain is
  merged; the build form shows the full `--defaults` value that will be passed.
- `cvmfs_repo: test.cvmfs.io` and `cvmfs_prefix: /cvmfs/test.cvmfs.io`: bits refuses to
  publish unless the destination lies under this prefix. The same check is what stops the
  overlay from redirecting a build in a production community.
- `prepub_url` and `stratum0_url` point the publish job at the testbed's cvmfs-prepub and
  object store instead of the production ones.
- Platforms use the bits-containers image names: `x86_64-el9`, `x86_64-el10`,
  `aarch64-el9`, `x86_64-ubuntu2404`, `x86_64-ubuntu2604`.
- Publish options that the production communities do not offer yet, such as staged
  publishing and direct upload to S3, are enabled here so they can be compared and tested.

The testbed services must be running for a publish to succeed; see the
[cvmfs-testbed README](https://github.com/bitsorg/cvmfs-testbed#readme) and
[DEPLOYMENT.md](https://github.com/bitsorg/cvmfs-testbed/blob/master/DEPLOYMENT.md).

## More information

- [cvmfs-testbed](https://github.com/bitsorg/cvmfs-testbed): the testbed stack;
  [lhcb.bits](https://github.com/bitsorg/lhcb.bits) and [alice.bits](https://github.com/bitsorg/alice.bits):
  communities whose builds are re-run here; bits
  [Effect on build hashes](https://github.com/bitsorg/bits/blob/main/docs/REFERENCE.md#effect-on-build-hashes)
- [stacks.bits](https://github.com/bitsorg/stacks.bits#readme) and
  [lcg.bits](https://github.com/bitsorg/lcg.bits#readme) READMEs: profiles, releases,
  CVMFS layout and the recipe pool
- bits [User Guide](https://github.com/bitsorg/bits/blob/main/docs/USERGUIDE.md),
  [Cookbook](https://github.com/bitsorg/bits/blob/main/docs/COOKBOOK.md),
  [Reference](https://github.com/bitsorg/bits/blob/main/docs/REFERENCE.md)
- [bits-console](https://gitlab.cern.ch/buncic/bits-console): community configuration and
  the publish pipeline

## License

This repository does not contain a LICENSE file yet.
