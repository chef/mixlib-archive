module Mixlib
  class Archive
    # Filesystem-aware safety checks shared by the extractors. Lexical checks
    # alone cannot see symlinks that already exist on disk (or that an earlier
    # archive entry created), so everything here is resolved against the real
    # filesystem.
    module Confinement
      MAX_SYMLINK_HOPS = 40
      # setuid, setgid. The sticky bit is harmless and is preserved.
      SPECIAL_MODE_BITS = 0o6000

      # True if +path+ (which may not exist yet) physically resolves inside
      # +real_root+. Resolves the deepest existing ancestor, following symlinks;
      # a dangling symlink anywhere in that chain is treated as unsafe since
      # creating directories through it would land at an unchecked location.
      def confined?(path, real_root)
        existing = path
        until File.exist?(existing) || File.symlink?(existing)
          parent = File.dirname(existing)
          return false if parent == existing

          existing = parent
        end
        inside_root?(File.realpath(existing), real_root)
      rescue SystemCallError
        false
      end

      # True if a symlink located at +link_path+ with the (possibly relative)
      # target +linkname+ would resolve inside +real_root+. Unlike a lexical
      # File.expand_path, ".." that follows a symlink component is resolved
      # against where that symlink really points.
      def symlink_target_confined?(link_path, linkname, real_root)
        target = absolute_path?(linkname) ? linkname : File.join(File.dirname(link_path), linkname)
        inside_root?(resolve_path(target), real_root)
      rescue SystemCallError, ArgumentError
        false
      end

      # Removes symlinks created during extraction that, now that the whole
      # archive has been written, resolve outside +real_root+. This catches
      # links whose meaning changed because of a later entry.
      def prune_escaping_symlinks(links, real_root)
        links.each do |link|
          next unless File.symlink?(link)
          next if symlink_target_confined?(link, File.readlink(link), real_root)

          File.unlink(link)
          reject_entry "removed symlink #{link}: target resolves outside the destination"
        end
      end

      # Strips setuid/setgid from an archive-provided mode so that extracting
      # (usually as root) cannot plant privileged binaries.
      def safe_mode(mode)
        mode & ~SPECIAL_MODE_BITS
      end

      # Security refusals are logged at error level so they are visible with the
      # default log level; a silently dropped entry is hard to diagnose.
      def reject_entry(message)
        Mixlib::Archive::Log.error message
      end

      private

      def inside_root?(path, real_root)
        path == real_root || path.start_with?(real_root.end_with?(File::SEPARATOR) ? real_root : real_root + File::SEPARATOR)
      end

      def absolute_path?(path)
        path.match?(%r{\A(?:[A-Za-z]:)?[/\\]})
      end

      def split_root(path)
        rest = path.sub(%r{\A(?:[A-Za-z]:)?[/\\]*}, "")
        [path[0, path.length - rest.length], rest]
      end

      def path_parts(rest)
        rest.split(File::ALT_SEPARATOR ? %r{[/\\]+} : %r{/+})
      end

      # Resolves +path+ to a physical location without requiring it to exist,
      # following any symlinks found on the way and applying ".." after them.
      def resolve_path(path)
        root, rest = split_root(path)
        current = root
        parts = path_parts(rest)
        hops = 0

        until parts.empty?
          part = parts.shift
          case part
          when "", "."
            next
          when ".."
            current = File.dirname(current) unless current == root
          else
            candidate = File.join(current, part)
            if File.symlink?(candidate)
              hops += 1
              raise ArgumentError, "too many symlinks" if hops > MAX_SYMLINK_HOPS

              target = File.readlink(candidate)
              if absolute_path?(target)
                root, rest = split_root(target)
                current = root
                parts = path_parts(rest) + parts
              else
                parts = path_parts(target) + parts
              end
            else
              current = candidate
            end
          end
        end
        current
      end
    end
  end
end
