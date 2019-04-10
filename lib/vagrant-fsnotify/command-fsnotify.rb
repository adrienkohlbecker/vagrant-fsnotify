require 'listen'

module VagrantPlugins::Fsnotify
  class Command < Vagrant.plugin("2", :command)
    include Vagrant::Action::Builtin::MixinSyncedFolders

    def self.synopsis
      'forwards filesystem events to virtual machine'
    end

    def execute
      @logger = Log4r::Logger.new("vagrant::commands::fsnotify")

      params = OptionParser.new do |o|
        o.banner = "Usage: vagrant fsnotify [vm-name]"
        o.separator ""
      end

      argv = parse_options(params)
      return if !argv

      paths = {}
      ignores = []
      @changes = {}

      with_target_vms(argv) do |machine|
        if !machine.communicate.ready?
          machine.ui.error("Machine not ready, is it up?")
          return 1
        end

        synced_folders(machine).each do |type, folder|

          folder.each do |id, opts|

            if !(
                (opts[:fsnotify] == true) ||
                (
                  opts[:fsnotify].respond_to?(:include?) &&
                  (
                    opts[:fsnotify].include?(:modified) ||
                    opts[:fsnotify].include?(:added) ||
                    opts[:fsnotify].include?(:removed)
                  )
                )
              )
              next
            end

            # Folder info
            hostpath  = opts[:hostpath]
            hostpath  = File.expand_path(hostpath, machine.env.root_path)
            hostpath  = Vagrant::Util::Platform.fs_real_path(hostpath).to_s

            # Make sure the host path ends with a "/" to avoid creating
            # a nested directory...
            if !hostpath.end_with?("/")
              hostpath += "/"
            end

            machine.ui.info("fsnotify: Watching #{hostpath}")

            paths[hostpath] = {
              id: id,
              machine: machine,
              opts: opts
            }

            if opts[:exclude]
              Array(opts[:exclude]).each do |pattern|
                ignores << exclude_to_regexp(pattern.to_s)
              end
            end

          end

        end

      end

      if paths.empty?
        @env.ui.info(<<-MESSAGE)
Nothing to sync.

Note that the valid values for the `:fsnotify' configuration key on
`Vagrantfile' are either `true' (which forwards all kinds of filesystem events)
or an Array containing symbols among the following options: `:modified',
`:added' and `:removed' (in which case, only the specified filesystem events are
forwarded).

For example, to forward all filesystem events to the default `/vagrant' folder,
add the following to the `Vagrantfile':

  config.vm.synced_folder ".", "/vagrant", fsnotify: true

And to forward only added files events to the default `/vagrant' folder, add the
following to the `Vagrantfile':

  config.vm.synced_folder ".", "/vagrant", fsnotify: [:added]

Exiting...
MESSAGE
        return 1
      end

      @logger.info("Listening to paths: #{paths.keys.sort.inspect}")
      @logger.info("Listening via: #{Listen::Adapter.select.inspect}")
      @logger.info("Ignoring #{ignores.length} paths:")
      ignores.each do |ignore|
        @logger.info("  -- #{ignore.to_s}")
      end

      listener_callback = method(:callback).to_proc.curry[paths]
      listener = Listen.to(*paths.keys, ignore: ignores, &listener_callback)

      # Create the callback that lets us know when we've been interrupted
      queue    = Queue.new
      callback = lambda do
        # This needs to execute in another thread because Thread
        # synchronization can't happen in a trap context.
        Thread.new { queue << true }
      end

      # Run the listener in a busy block so that we can cleanly
      # exit once we receive an interrupt.
      Vagrant::Util::Busy.busy(callback) do
        listener.start
        queue.pop
        listener.stop if listener.state != :stopped
      end

      return 0
    end

    def callback(paths, modified, added, removed)

      @logger.info("File change callback called!")
      @logger.info("  - Modified: #{modified.inspect}")
      @logger.info("  - Added: #{added.inspect}")
      @logger.info("  - Removed: #{removed.inspect}")

      @changes.each do |rel_path, time|
        @changes.delete(rel_path) if time < Time.now.to_i - 2
      end

      tosync = {}
      todelete = []

      paths.each do |hostpath, folder|

        toanalyze = []
        if folder[:opts][:fsnotify] == true
          toanalyze += modified + added + removed
        else
          if folder[:opts][:fsnotify].include? :modified
            toanalyze += modified
          end
          if folder[:opts][:fsnotify].include? :added
            toanalyze += added
          end
          if folder[:opts][:fsnotify].include? :removed
            toanalyze += removed
          end
        end

        toanalyze.each do |file|

          if file.start_with?(hostpath)

            rel_path =  file.sub(hostpath, '')

            if @changes[rel_path] && @changes[rel_path] >= Time.now.to_i - 2
              @logger.info("#{rel_path} was changed less than two seconds ago, skipping")
              next
            end

            @changes[rel_path] = Time.now.to_i
            if modified.include? file
              folder[:machine].ui.info("fsnotify: Changed: #{rel_path}")
            elsif added.include? file
              folder[:machine].ui.info("fsnotify: Added: #{rel_path}")
            elsif removed.include? file
              folder[:machine].ui.info("fsnotify: Removed: #{rel_path}")
            end

            guestpath = folder[:opts][:override_guestpath] || folder[:opts][:guestpath]
            guestpath = File.join(guestpath, rel_path)

            tosync[folder[:machine]] = [] if !tosync.has_key?(folder[:machine])
            tosync[folder[:machine]] << guestpath

            if removed.include? file
              todelete << guestpath
            end
          end

        end

      end

      tosync.each do |machine, files|
        machine.communicate.execute("touch -am '#{files.join("' '")}'")
        remove_from_this_machine = files & todelete
        unless remove_from_this_machine.empty?
          machine.communicate.execute("rm -rf '#{remove_from_this_machine.join("' '")}'")
        end
      end

    rescue => e
      @logger.error("#{e}: #{e.message}")
    end

    def exclude_to_regexp(exclude)

      # This is REALLY ghetto, but its a start. We can improve and
      # keep unit tests passing in the future.
      exclude = exclude.gsub("**", "|||GLOBAL|||")
      exclude = exclude.gsub("*", "|||PATH|||")
      exclude = exclude.gsub("|||PATH|||", "[^/]*")
      exclude = exclude.gsub("|||GLOBAL|||", ".*")

      Regexp.new(exclude)

    end

  end
end
