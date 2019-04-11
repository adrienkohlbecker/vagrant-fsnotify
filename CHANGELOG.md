0.4.0 - 2019-04-11
==================
- Update mtime as well as atime to trigger file events on the guest (#28)

0.3.0 - 2016-04-13
==================
- Fix for "No such file or directory" on Windows host (#11)

0.2.0 - 2015-07-14
==================
- *Breaking change:* Minimum required Vagrant version changed to 1.7.3+
- Fixed a dependency issue with celluloid (#10, @leafac)

0.1.1 - 2015-07-05 (yanked)
===========================
Note: This release was yanked due to a dependency issue, see #9
- Added command synopsis (#7, @leafac)
- Fix issue with vagrant runtime dependency on celluloid (#8, @leafac)

0.1.0 - 2015-07-05 (yanked)
===========================
Note: This release was yanked due to a dependency issue, see #9
- *Breaking change:* Added support for forwading file addition/removal (#6, @leafac)
- Depend on `vagrant` rather than `listen` for better compatibility with upstream (#5, @leafac)
- Added documentation (#3 & #4, @leafac)

0.0.6 - 2015-04-16
==================
- Fix multimachine use, allow specifying which machine to target (@elskwid)

0.0.5 - 2015-04-11
==================
- Fix `listen` dependency

0.0.4 - 2014-08-18
==================
- Uses access time modification, rather than modified time

0.0.3 - 2014-08-15
==================
- Allow guest path overriding


0.0.2 - 2014-08-15
==================
- Increase the delay between changes to 2 seconds
