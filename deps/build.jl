using BinaryProvider # requires BinaryProvider 0.3.0 or later

# Parse some basic command-line arguments
const verbose = "--verbose" in ARGS
const prefix = Prefix(get([a for a in ARGS if a != "--verbose"], 1, joinpath(@__DIR__, "usr")))
products = [
    LibraryProduct(prefix, ["libcspice"], :libcspice),
]

# Download binaries from hosted location
bin_prefix = "https://github.com/JuliaAstro/SPICEBuilder/releases/download/N0066"

# Listing of files generated by BinaryBuilder:
download_info = Dict(
    Linux(:aarch64, libc=:glibc) => ("$bin_prefix/cspice.v66.0.0.aarch64-linux-gnu.tar.gz", "21c8ec7b0d0134bd81d45ae629c6c5e5b64c6d2a423c97406231ce06967896c3"),
    Linux(:aarch64, libc=:musl) => ("$bin_prefix/cspice.v66.0.0.aarch64-linux-musl.tar.gz", "0bd8a5ca5d1ae3ea6a1c4dfe44c6b09c541eaf173486134b9f0d46545a1e842a"),
    Linux(:armv7l, libc=:glibc, call_abi=:eabihf) => ("$bin_prefix/cspice.v66.0.0.arm-linux-gnueabihf.tar.gz", "9f807dd60f6a892e34cf783a2c505dd846ea2ec0f8033eb574cb013f189867db"),
    Linux(:armv7l, libc=:musl, call_abi=:eabihf) => ("$bin_prefix/cspice.v66.0.0.arm-linux-musleabihf.tar.gz", "3955edfa2a450c955e457ea312b0bb34e95016d9b02995cbf6b4530437f2eabc"),
    Linux(:i686, libc=:glibc) => ("$bin_prefix/cspice.v66.0.0.i686-linux-gnu.tar.gz", "5893e51965835dc9ea62a80a1c5071583f87d62c4b247dc2555b4039b235f42b"),
    Linux(:i686, libc=:musl) => ("$bin_prefix/cspice.v66.0.0.i686-linux-musl.tar.gz", "9a9981b82aa2541cc9c5cf9029d463adbf2a5888b25716cb84930a4f094a3279"),
    Windows(:i686) => ("$bin_prefix/cspice.v66.0.0.i686-w64-mingw32.tar.gz", "11e45734a309354397b64527e3a714be4e54e0d7dfde63057938e7e8a44c8ee0"),
    Linux(:powerpc64le, libc=:glibc) => ("$bin_prefix/cspice.v66.0.0.powerpc64le-linux-gnu.tar.gz", "9e44bde5d21801af85190bb5cdcc82609c5c8d3b5ba7454d64ef23d5ba414765"),
    MacOS(:x86_64) => ("$bin_prefix/cspice.v66.0.0.x86_64-apple-darwin14.tar.gz", "d40db59bf5ec152d24faa9e5502115af7f95103d1836e6f4f04d2c30e9feb958"),
    Linux(:x86_64, libc=:glibc) => ("$bin_prefix/cspice.v66.0.0.x86_64-linux-gnu.tar.gz", "448fa9b48c5354f9caa587ccbf3243d1f7f34546a60deb447c17c2bb9ea28f05"),
    Linux(:x86_64, libc=:musl) => ("$bin_prefix/cspice.v66.0.0.x86_64-linux-musl.tar.gz", "6a0ae7ef4b11a72d7422bac797928a76e3dfc825290a23073db0322638f338b4"),
    FreeBSD(:x86_64) => ("$bin_prefix/cspice.v66.0.0.x86_64-unknown-freebsd11.1.tar.gz", "6f571a8a6c462a844de4fed08d9f9e8cb32535f8e2a7cea9bf8c3178a559b2be"),
    Windows(:x86_64) => ("$bin_prefix/cspice.v66.0.0.x86_64-w64-mingw32.tar.gz", "96cd289a3d9f60835d775a92e22335c078087722ebcf8c69174f971366bbfcf9"),
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
