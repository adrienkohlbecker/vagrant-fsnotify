require 'listen'

module VagrantPlugins::Fsnotify
  class Command < Vagrant.plugin("2", :command)
    include Vagrant::Action::Builtin::MixinSyncedFolders

    def execute
      @logger = Log4r::Logger.new("vagrant::commands::rsync-auto")

      params = OptionParser.new do |o|
        o.banner = "Usage: vagrant fsnotify [vm-name]"
        o.separator ""
      end

      argv = parse_options(params)
      return if !argv

      paths = {}
      @changes = {}

      with_target_vms do |machine|
        if !machine.communicate.ready?
          machine.ui.error("Machine not ready, is it up?")
          return 1
        end

        synced_folders(machine).each do |type, folder|

          folder.each do |id, opts|

            next if not opts[:fsnotify]

            # Folder info
            hostpath  = opts[:hostpath]
            hostpath  = File.expand_path(hostpath, machine.env.root_path)
            hostpath  = Vagrant::Util::Platform.fs_real_path(hostpath).to_s

            if Vagrant::Util::Platform.windows?
              # rsync for Windows expects cygwin style paths, always.
              hostpath = Vagrant::Util::Platform.cygwin_path(hostpath)
            end

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

          end

        end

      end

      if paths.empty?
        return 0
      end

      @logger.info("Listening via: #{Listen::Adapter.select.inspect}")
      listener_callback = method(:callback).to_proc.curry[paths]
      listener = Listen.to(*paths.keys, &listener_callback)

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
        listener.stop if listener.listen?
      end

      return 0
    end

    def callback(paths, modified, added, removed)

      @logger.info("File change callback called!")
      @logger.info("  - Modified: #{modified.inspect}")
      @logger.info("  - Added: #{added.inspect}")
      @logger.info("  - Removed: #{removed.inspect}")

      @changes.each do |rel_path, time|
        @changes.delete(rel_path) if time < Time.now.to_i - 1
      end

      paths.each do |hostpath, folder|

        modified.each do |file|

          if file.start_with?(hostpath)

            rel_path =  file.sub(hostpath, '')

            if @changes[rel_path] && @changes[rel_path] > Time.now.to_i - 1
              @logger.info("#{rel_path} was changed less than a second ago, skipping")
              next
            end

            @changes[rel_path] = Time.now.to_i
            folder[:machine].ui.info("fsnotify: Changed: #{rel_path}")

            guestpath = File.join(folder[:opts][:guestpath], rel_path)
            folder[:machine].communicate.execute("touch #{guestpath}")

          end

        end

      end

    rescue => e
      @logger.error("#{e}: #{e.message}")
    end
  end
end
