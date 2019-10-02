using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libvorbis"], :libvorbis),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaIO/LibVorbisBuilder/releases/download/v1.3.6-2"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/libvorbis.v1.3.6.aarch64-linux-gnu.tar.gz", "4d2c1a354a167fc40494a96f14bba82848d11825570398ea3a38bb479e9bf3d4"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/libvorbis.v1.3.6.aarch64-linux-musl.tar.gz", "a1236d67f468133aa225a50b3dcb3a07131a6eedb9a609ee7d1908bd598c4362"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/libvorbis.v1.3.6.arm-linux-gnueabihf.tar.gz", "1d8a7ff8e4e412db41da7dc5c6328b57cba7126734eb3b1bcfc0894ef984dbd8"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/libvorbis.v1.3.6.arm-linux-musleabihf.tar.gz", "fc97dd2e1d5fa5d92302df7d9f16b17c4e370abcc6a41aa1ffad6bac5f364744"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/libvorbis.v1.3.6.i686-linux-gnu.tar.gz", "afcd2073ff753b70845f1bfc3f6254132386f1d89af6a263681cca38c6dbb75d"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/libvorbis.v1.3.6.i686-linux-musl.tar.gz", "8c94d5c7aab7993f305a6198d987ffcaf794cc5f52840e22619e0b49f2bb0e1c"),
    Windows(:i686) => ("$bin_prefix/libvorbis.v1.3.6.i686-w64-mingw32.tar.gz", "8fc2d89f5bcb65e0e2de500a655fb77c848e721c4d79a9ae4671a524e32cad21"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/libvorbis.v1.3.6.powerpc64le-linux-gnu.tar.gz", "f0ebb4954b9912d17ba5eaf5804e40100d832435345e7313a00b6e6434b92386"),
    MacOS(:x86_64) => ("$bin_prefix/libvorbis.v1.3.6.x86_64-apple-darwin14.tar.gz", "d063512641302f7f1706e2e16492ae934928627935832be7e11e093253f862de"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/libvorbis.v1.3.6.x86_64-linux-gnu.tar.gz", "c6c13c9c3e2c782e0d9b1aeefe34bd116b84aa3eb0df86252ac54c67a3a94b6c"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/libvorbis.v1.3.6.x86_64-linux-musl.tar.gz", "9bc0d1601e00b046a093d94b91a39f9d4c70a7d9a7b329a4572e7ad1ec1ca5d2"),
    FreeBSD(:x86_64) => ("$bin_prefix/libvorbis.v1.3.6.x86_64-unknown-freebsd11.1.tar.gz", "0330e5fa998eb1fb8ebaa0043ec8a0f496a97a6a655590be50f56f03baae3582"),
    Windows(:x86_64) => ("$bin_prefix/libvorbis.v1.3.6.x86_64-w64-mingw32.tar.gz", "ccd6b148bb19ba73aa1008115c10494a961963a0a41ec353ebc9099ff5e58ac3"),
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
