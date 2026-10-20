module Mixlib
  class Archive
    # Filesystem-aware path confinement shared by the extractors. Lexical
    # checks alone cannot see symlinks that already exist on disk.
    module Confinement
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
        real = File.realpath(existing)
        real == real_root || real.start_with?(real_root.end_with?(File::SEPARATOR) ? real_root : real_root + File::SEPARATOR)
      rescue SystemCallError
        false
      end
    end
  end
end
