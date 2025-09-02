<!-- usage documentation: http://expeditor-docs.es.chef.io/configuration/changelog/ -->
# Change Log

<!-- latest_release 1.3.1 -->
## [v1.3.1](https://github.com/chef/mixlib-archive/tree/v1.3.1) (2025-09-02)

#### Merged Pull Requests
- Add GitHub Security Actions Workflow [#72](https://github.com/chef/mixlib-archive/pull/72) ([sean-sype-simmons](https://github.com/sean-sype-simmons))
<!-- latest_release -->

<!-- release_rollup since=1.1.7 -->
### Changes not yet released to rubygems.org

#### Merged Pull Requests
- Add GitHub Security Actions Workflow [#72](https://github.com/chef/mixlib-archive/pull/72) ([sean-sype-simmons](https://github.com/sean-sype-simmons)) <!-- 1.3.1 -->
- Updating for Ruby 3.4 and Cookstyle [#71](https://github.com/chef/mixlib-archive/pull/71) ([johnmccrae](https://github.com/johnmccrae)) <!-- 1.3.0 -->
- add myself to codeowners [#70](https://github.com/chef/mixlib-archive/pull/70) ([jaymzh](https://github.com/jaymzh)) <!-- 1.2.4 -->
- Migrate from Chefstyle to Cookstyle [#68](https://github.com/chef/mixlib-archive/pull/68) ([dafyddcrosby](https://github.com/dafyddcrosby)) <!-- 1.2.3 -->
- [CI] Drop EOL Rubies [#69](https://github.com/chef/mixlib-archive/pull/69) ([dafyddcrosby](https://github.com/dafyddcrosby)) <!-- 1.2.2 -->
- Correct spelling mistakes [#65](https://github.com/chef/mixlib-archive/pull/65) ([EdwardBetts](https://github.com/EdwardBetts)) <!-- 1.2.1 -->
- Remove Ruby 2.4 support &amp; Test Ruby 3.0/3.1 [#63](https://github.com/chef/mixlib-archive/pull/63) ([poorndm](https://github.com/poorndm)) <!-- 1.2.0 -->
<!-- release_rollup -->

<!-- latest_stable_release -->
## [v1.1.7](https://github.com/chef/mixlib-archive/tree/v1.1.7) (2021-02-18)

#### Merged Pull Requests
- Convert destination to a String [#61](https://github.com/chef/mixlib-archive/pull/61) ([lamont-granquist](https://github.com/lamont-granquist))
<!-- latest_stable_release -->

## [v1.1.6](https://github.com/chef/mixlib-archive/tree/v1.1.6) (2021-02-17)

#### Merged Pull Requests
- Cache gems and test on Ruby 3 [#59](https://github.com/chef/mixlib-archive/pull/59) ([tas50](https://github.com/tas50))
- Fix creating archives on windows with a CRLF [#60](https://github.com/chef/mixlib-archive/pull/60) ([lamont-granquist](https://github.com/lamont-granquist))

## [v1.1.3](https://github.com/chef/mixlib-archive/tree/v1.1.3) (2021-02-10)

#### Merged Pull Requests
- Remove encoding comment we don&#39;t need [#51](https://github.com/chef/mixlib-archive/pull/51) ([tas50](https://github.com/tas50))
- Remove Dir.chdir calls from libarchive extraction [#54](https://github.com/chef/mixlib-archive/pull/54) ([lamont-granquist](https://github.com/lamont-granquist))
- Remove the pry-stack_explorer dep failing Ruby 2.4 builds [#55](https://github.com/chef/mixlib-archive/pull/55) ([tas50](https://github.com/tas50))
- Add a note about ffi-libarchive to the readme [#58](https://github.com/chef/mixlib-archive/pull/58) ([tas50](https://github.com/tas50))
- Update Chefstyle to 1.6.2 [#57](https://github.com/chef/mixlib-archive/pull/57) ([tas50](https://github.com/tas50))

## [v1.0.7](https://github.com/chef/mixlib-archive/tree/v1.0.7) (2020-08-21)

#### Merged Pull Requests
- Optimize our requires [#53](https://github.com/chef/mixlib-archive/pull/53) ([tas50](https://github.com/tas50))

## [v1.0.6](https://github.com/chef/mixlib-archive/tree/v1.0.6) (2020-08-13)

#### Merged Pull Requests
- Optimize requires for non-omnibus installs [#52](https://github.com/chef/mixlib-archive/pull/52) ([tas50](https://github.com/tas50))

## [v1.0.5](https://github.com/chef/mixlib-archive/tree/v1.0.5) (2019-12-30)

#### Merged Pull Requests
- Remove Travis and update Github templates [#40](https://github.com/chef/mixlib-archive/pull/40) ([tas50](https://github.com/tas50))
- Chefstyle fixes + test on Windows in Buildkite [#43](https://github.com/chef/mixlib-archive/pull/43) ([tas50](https://github.com/tas50))
- Test on Ruby 2.7rc and other testing updates [#47](https://github.com/chef/mixlib-archive/pull/47) ([tas50](https://github.com/tas50))
- Substitute require for require_relative [#48](https://github.com/chef/mixlib-archive/pull/48) ([tas50](https://github.com/tas50))

## [v1.0.1](https://github.com/chef/mixlib-archive/tree/v1.0.1) (2019-01-16)

#### Merged Pull Requests
- Update expeditor config and order gemfile [#38](https://github.com/chef/mixlib-archive/pull/38) ([tas50](https://github.com/tas50))

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