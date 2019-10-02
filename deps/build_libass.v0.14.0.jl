using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libass"], :libass),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaIO/LibassBuilder/releases/download/v0.14.0-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/libass.v0.14.0.aarch64-linux-gnu.tar.gz", "fc156c9553ef25298f857127676f8f6f3cbaffdf3792608313e7b2e942c36b00"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/libass.v0.14.0.aarch64-linux-musl.tar.gz", "d86a9121b20f2213d8cc9ac1279635e9a3116362a0dead0fae77c435ba82d2c8"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/libass.v0.14.0.arm-linux-gnueabihf.tar.gz", "bccf0fa4c19e00eabfaf5d514655667223cd19f3a99fc6ebdc8cf2f81ac79646"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/libass.v0.14.0.arm-linux-musleabihf.tar.gz", "cfb8ffd5d9b838eee9479a1c4174ae1459627393e7803fca1c76f03d543db9f0"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/libass.v0.14.0.i686-linux-gnu.tar.gz", "c8ec7aeef3718a0ea4b117328252066893b0419c452ff7bb0179c34ad39b6be4"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/libass.v0.14.0.i686-linux-musl.tar.gz", "9d21b78921fd7a81b27804c8a1cbff9ca89ced91ce2f00221129d0e7b6d1a95b"),
    Windows(:i686) => ("$bin_prefix/libass.v0.14.0.i686-w64-mingw32.tar.gz", "9766ce60f5a208d2efe5060d134a7b4e1c80d7eb028c58c6f2aae023056f54f5"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/libass.v0.14.0.powerpc64le-linux-gnu.tar.gz", "245b7f668058b7530157e0ff99992438163d6ea66fabdda56969ae091fb15b6a"),
    MacOS(:x86_64) => ("$bin_prefix/libass.v0.14.0.x86_64-apple-darwin14.tar.gz", "b95921a223b6c7a3d9b907e3a21a16b429b68822814c2474a3ab049113457aeb"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/libass.v0.14.0.x86_64-linux-gnu.tar.gz", "27367b8dd53aaa5865c53e23bf45bab06988b28705fcb7cfd349884e5497753e"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/libass.v0.14.0.x86_64-linux-musl.tar.gz", "063b027bd26e03ba3dba3b4cd4120d2d2da47fe5bcef0f683f5d48cfcf4d6c4f"),
    FreeBSD(:x86_64) => ("$bin_prefix/libass.v0.14.0.x86_64-unknown-freebsd11.1.tar.gz", "bd6f4750e0db054a7047a314e88df0b1dbc5b06ddecba7d6467fff25ec45f1d8"),
    Windows(:x86_64) => ("$bin_prefix/libass.v0.14.0.x86_64-w64-mingw32.tar.gz", "f82ad3419afc488f0b2210d990810af1b6cb458edc0456788d2bff9f81659987"),
)

# Install unsatisfied or updated dependencies:
unsatisfied = any(!satisfied(p; verbose=verbose) for p in products)
dl_info = choose_download(download_info, platform_key_abi())
if dl_info === nothing && unsatisfied
    # If we don't have a compatible .tar.gz to download, complain.
    # Alternatively, you could attempt to install from a separate provider,
    # build from source or something even more ambitious here.
    error("Your platform (\"$(Sys.MACHINE)\", parsed as \"$(triplet(platform_key_abi()))\") is not supported by this package!")
end

# If we have a download, and we are unsatisfied (or the version we're
# trying to install is not itself installed) then load it up!
if unsatisfied || !isinstalled(dl_info...; prefix=prefix)
    # Download and install binaries
    install(dl_info...; prefix=prefix, force=true, verbose=verbose)
end

# Write out a deps.jl file that will contain mappings for our products
write_deps_file(joinpath(@__DIR__, "deps.jl"), products, verbose=verbose)