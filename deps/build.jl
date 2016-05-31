using BinDeps
using Compat

@BinDeps.setup

libasl = library_dependency("libasl", aliases=["libasl.2", "libasl.2.1.1"])
libmp = library_dependency("libmp", aliases=["libmp.2", "libmp.2.1.1"])

# Hopeless.
# @osx_only begin
#   using Homebrew
#   provides(Homebrew.HB, "homebrew/science/asl", [libasl, libmp], os = :Darwin)
#   push!(Libdl.DL_LOAD_PATH, joinpath(Homebrew.prefix("asl"), "lib"))
# end

# Uncomment when there is a deb for the ASL.
# provides(AptGet, "libasl-dev", [libasl, libmp], os = :Linux)

# Outdated!
@windows_only begin
  using WinRPM
  provides(WinRPM.RPM, "ampl-mp", [libasl, libmp], os = :Windows)
end

provides(Sources,
         URI("https://github.com/JuliaOptimizers/mp/archive/2.1.1.tar.gz"),
         [libasl, libmp],
         SHA="114e8d94715cc22a4c8c05d61865a30f27bc3b16aeac76befdfa1f325d8df3c2",
         unpacked_dir="mp-2.1.1")

depsdir = BinDeps.depsdir(libasl)
prefix = joinpath(depsdir, "usr")
srcdir = joinpath(depsdir, "src", "mp-2.1.1")

provides(SimpleBuild,
         (@build_steps begin
            GetSources(libasl)
            (@build_steps begin
               ChangeDirectory(srcdir)
               (@build_steps begin
                  `cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_RPATH=$prefix/lib -DBUILD_SHARED_LIBS=True`
                  `make all`
                  `make test`
                  `make install`
                end)
             end)
          end), [libasl, libmp], os = :Unix)

@BinDeps.install @compat Dict(:libasl => :libasl)
