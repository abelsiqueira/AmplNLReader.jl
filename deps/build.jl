using BinDeps
using Compat

@BinDeps.setup

libasl = library_dependency("libasl", aliases=["libasl.3", "libasl.3.1.0"])

# @static if is_apple()
#   using Homebrew
#   provides(Homebrew.HB, "ampl-mp", libasl, os = :Darwin)
# end

# Uncomment when there is a deb for the ASL.
# provides(AptGet, "libasl-dev", libasl, os = :Linux)

provides(Sources,
         URI("https://github.com/ampl/mp/archive/3.1.0.tar.gz"),
         libasl,
         SHA="587c1a88f4c8f57bef95b58a8586956145417c8039f59b1758365ccc5a309ae9",
         unpacked_dir="mp-3.1.0")

depsdir = BinDeps.depsdir(libasl)
prefix = joinpath(depsdir, "usr")
srcdir = joinpath(depsdir, "src", "mp-3.1.0")
builddir = joinpath(srcdir, "build")

provides(SimpleBuild,
         (@build_steps begin
            GetSources(libasl)
            CreateDirectory(builddir)
            (@build_steps begin
              ChangeDirectory(builddir)
              (@build_steps begin
               `wget https://gist.githubusercontent.com/dpo/b18b25879201ed986086c7c359fdcf99/raw/60f9973f0c461bed17b63c677c557d1e8f71f1e4/a.rb`
                pipeline(`cat a.rb`, `patch --verbose -p1 -d ..`)
                `cmake -DCMAKE_INSTALL_PREFIX=$prefix -DCMAKE_INSTALL_RPATH=$prefix/lib -DBUILD_SHARED_LIBS=True ..`
                `make all`
                `make test`
                `make install`
              end)
            end)
          end), libasl, os = :Unix)

@BinDeps.install Dict(:libasl => :libasl)
