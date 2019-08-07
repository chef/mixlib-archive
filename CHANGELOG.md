<!-- usage documentation: http://expeditor-docs.es.chef.io/configuration/changelog/ -->
# Change Log

<!-- latest_release 1.0.3 -->
## [1.0.3](https://github.com/chef/mixlib-archive/tree/1.0.3) (2019-08-07)

#### Merged Pull Requests
- Chefstyle fixes + test on Windows in Buildkite [#43](https://github.com/chef/mixlib-archive/pull/43) ([tas50](https://github.com/tas50))
<!-- latest_release -->

<!-- release_rollup since=1.0.1 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- Chefstyle fixes + test on Windows in Buildkite [#43](https://github.com/chef/mixlib-archive/pull/43) ([tas50](https://github.com/tas50)) <!-- 1.0.3 -->
- Remove Travis and update Github templates [#40](https://github.com/chef/mixlib-archive/pull/40) ([tas50](https://github.com/tas50)) <!-- 1.0.2 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v1.0.1](https://github.com/chef/mixlib-archive/tree/v1.0.1) (2019-01-16)

#### Merged Pull Requests
- Update expeditor config and order gemfile [#38](https://github.com/chef/mixlib-archive/pull/38) ([tas50](https://github.com/tas50))
<!-- latest_stable_release -->

## [v1.0.0](https://github.com/chef/mixlib-archive/tree/v1.0.0) (2019-01-16)

#### Merged Pull Requests
- mixlib-archive-tar create corrupt archives on Windows [#37](https://github.com/chef/mixlib-archive/pull/37) ([kenmacleod](https://github.com/kenmacleod))
- Require Ruby 2.4+ and bump to version 1.0 [#36](https://github.com/chef/mixlib-archive/pull/36) ([lamont-granquist](https://github.com/lamont-granquist))

## [v0.4.19](https://github.com/chef/mixlib-archive/tree/v0.4.19) (2018-12-12)

#### Merged Pull Requests
- Don&#39;t ship the readme in the gem artifact [#35](https://github.com/chef/mixlib-archive/pull/35) ([tas50](https://github.com/tas50))

## [v0.4.18](https://github.com/chef/mixlib-archive/tree/v0.4.18) (2018-10-15)

#### Merged Pull Requests
- Misc tweaks to gemfile / gemspec [#32](https://github.com/chef/mixlib-archive/pull/32) ([tas50](https://github.com/tas50))
- Add a mingw32 specific gemspec to limit files shipped on *nix [#33](https://github.com/chef/mixlib-archive/pull/33) ([tas50](https://github.com/tas50))

## [v0.4.16](https://github.com/chef/mixlib-archive/tree/v0.4.16) (2018-08-28)

#### Merged Pull Requests
- Ensure that paths like foo..bar.baz aren&#39;t ignored [#9](https://github.com/chef/mixlib-archive/pull/9) ([thommay](https://github.com/thommay))
- Fix mixlib-archive on Windows, add Appveyor [#31](https://github.com/chef/mixlib-archive/pull/31) ([stuartpreston](https://github.com/stuartpreston))
- Fix read_tar_magic to properly return an array when a file has less than 264 characters [#30](https://github.com/chef/mixlib-archive/pull/30) ([bdwyertech](https://github.com/bdwyertech))

## [v0.4.13](https://github.com/chef/mixlib-archive/tree/v0.4.13) (2018-08-03)

#### Merged Pull Requests
- add codeowners [#24](https://github.com/chef/mixlib-archive/pull/24) ([thommay](https://github.com/thommay))
- Move deps to the Gemfile and expand Rake tasks [#25](https://github.com/chef/mixlib-archive/pull/25) ([tas50](https://github.com/tas50))
- Add github issue template &amp; standardize expeditor config [#26](https://github.com/chef/mixlib-archive/pull/26) ([tas50](https://github.com/tas50))
- Update codeowners and add PR template [#27](https://github.com/chef/mixlib-archive/pull/27) ([tas50](https://github.com/tas50))
- bugfix to make dir.chdir threadsafe [#29](https://github.com/chef/mixlib-archive/pull/29) ([stevenoneill](https://github.com/stevenoneill))

## [v0.4.8](https://github.com/chef/mixlib-archive/tree/v0.4.8) (2018-06-21)

#### Merged Pull Requests
- Use the correct entry size for content with multi-byte characters. [#23](https://github.com/chef/mixlib-archive/pull/23) ([coderanger](https://github.com/coderanger))

## [v0.4.7](https://github.com/chef/mixlib-archive/tree/v0.4.7) (2018-06-07)

#### Merged Pull Requests
- fixup strange edge case around tar magic reading [#22](https://github.com/chef/mixlib-archive/pull/22) ([spion06](https://github.com/spion06))

## [v0.4.6](https://github.com/chef/mixlib-archive/tree/v0.4.6) (2018-05-08)

#### Merged Pull Requests
- update tar magic to identify oldgnu style tar headers [#21](https://github.com/chef/mixlib-archive/pull/21) ([spion06](https://github.com/spion06))

## [v0.4.5](https://github.com/chef/mixlib-archive/tree/v0.4.5) (2018-05-04)

#### Merged Pull Requests
- Fix up creating archives [#18](https://github.com/chef/mixlib-archive/pull/18) ([thommay](https://github.com/thommay))
- Fix up writing tar archives with the rubygems tar [#19](https://github.com/chef/mixlib-archive/pull/19) ([thommay](https://github.com/thommay))

## [v0.4.2](https://github.com/chef/mixlib-archive/tree/v0.4.2) (2018-04-25)

#### Merged Pull Requests
- use libarchive by preference [#17](https://github.com/chef/mixlib-archive/pull/17) ([thommay](https://github.com/thommay))

## [v0.4.1](https://github.com/chef/mixlib-archive/tree/v0.4.1) (2017-02-02)

[Full Changelog](https://github.com/chef/mixlib-archive/compare/v0.4.0...v0.4.1)

###Merged pull requests:

- Accept a single pattern to ignore [\#8](https://github.com/chef/mixlib-archive/pull/8) ([thommay](https://github.com/thommay))

## [v0.4.0](https://github.com/chef/mixlib-archive/tree/v0.4.0) (2017-02-02)
[Full Changelog](https://github.com/chef/mixlib-archive/compare/v0.3.0...v0.4.0)

**Fixed bugs:**

- Ignore directory traversing file\_names in an tar [\#6](https://github.com/chef/mixlib-archive/pull/6) ([thommay](https://github.com/thommay))

## [v0.3.0](https://github.com/chef/mixlib-archive/tree/v0.3.0) (2017-01-19)
[Full Changelog](https://github.com/chef/mixlib-archive/compare/v0.2.0...v0.3.0)

**Merged pull requests:**

- Use Rake 11 [\#5](https://github.com/chef/mixlib-archive/pull/5) ([tas50](https://github.com/tas50))
- Create archives as well as extracting them [\#4](https://github.com/chef/mixlib-archive/pull/4) ([thommay](https://github.com/thommay))

## [v0.2.0](https://github.com/chef/mixlib-archive/tree/v0.2.0) (2016-07-05)
[Full Changelog](https://github.com/chef/mixlib-archive/compare/v0.1.0...v0.2.0)

**Merged pull requests:**

- Add logging [\#3](https://github.com/chef/mixlib-archive/pull/3) ([thommay](https://github.com/thommay))
- Make extraction safer [\#2](https://github.com/chef/mixlib-archive/pull/2) ([thommay](https://github.com/thommay))

## [v0.1.0](https://github.com/chef/mixlib-archive/tree/v0.1.0) (2016-05-09)
[Full Changelog](https://github.com/chef/mixlib-archive/compare/053f20d5455cc463251f91d1413b973232909dc2...v0.1.0)

**Merged pull requests:**

- Turns out some tar archives don't contain dirs [\#1](https://github.com/chef/mixlib-archive/pull/1) ([thommay](https://github.com/thommay))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*