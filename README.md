vagrant-fsnotify
================

Forward filesystem change notifications to your [Vagrant][vagrant] VM.

Problem
-------

Some filesystems (e.g. ext4, HFS+) have a feature of event notification.
Interested applications can subscribe and are notified when filesystem events
happen (e.g. a file was created, modified or deleted).

Applications can make use of this system to provide features such as auto-reload
or live updates. For example, [Jekyll][jekyll] regenerates the static website
and [Guard][guard] triggers a test run or a build when source files are
modified.

Unfortunately, [Vagrant][vagrant] users have a hard time making use of these
features when the application is running inside a virtual machine. When the file
is modified on the host, the event is not propagated to the guest and the
auto-reload never happens.

There are several bug reports related to this issue:

- <https://www.virtualbox.org/ticket/10660>
- <https://github.com/guard/listen/issues/53>
- <https://github.com/guard/listen/issues/57>
- <https://github.com/guard/guard/issues/269>
- <https://github.com/mitchellh/vagrant/issues/707>

There are two generally accepted solutions. The first is fall back to long
polling, the other is to
[forward the events over TCP][forwarding-file-events-over-tcp]. The problem with
long polling is that it's painfully slow, especially in shared folders. The
problem with forwarding events is that it's not a general approach that works
for any application.

Solution
--------

`vagrant-fsnotify` proposes a different solution: run a process listening for
filesystem events on the host and, when a notification is received, access the
virtual machine guest and `touch` the file in there, causing an event to be
propagated on the guest filesystem.

This leverages the speed of using real filesystem events while still being
general enough to don't require any support from applications.

Caveats
-------

Only events of file modification are treated by `vagrant-fsnotify`. For most
applications this is enough, but if other events (e.g. file creation or
deletion) are necessary for your application, `vagrant-fsnotify` might not be
for you.

Installation
------------

`vagrant-fsnotify` is a [Vagrant][vagrant] plugin and can be installed by
running:

```console
$ vagrant plugin install vagrant-fsnotify
```

[Vagrant][vagrant] version 1.5 or greater is required.

Usage
-----

In `Vagrantfile` synced folder configuration, add the `fsnotify: true`
option. For example, in order to enable `vagrant-fsnotify` for the the default
`/vagrant` shared folder, add the following:

```ruby
config.vm.synced_folder ".", "/vagrant", fsnotify: true
```

When the guest virtual machine is up, run the following:

```console
$ vagrant fsnotify
```

This starts the long running process that captures filesystem events on the host
and forwards them to the guest virtual machine.


[vagrant]: https://www.vagrantup.com/
[jekyll]: http://jekyllrb.com/
[guard]: http://guardgem.org/
[forwarding-file-events-over-tcp]: https://github.com/guard/listen#forwarding-file-events-over-tcp
