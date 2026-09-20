{
  cmake,
  clangStdenv,
  fetchgit,
  lib,
  makeWrapper,
  vulkan-headers,
  vulkan-loader,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "lsfg-vk";
  version = "2.0.0";

  src = fetchgit {
    url = "https://git.lsfg-vk.dev/lsfg-vk.git";
    hash = "sha256-VcVBgPonHaTuVYKgdJ6+YM6+Q4slXWKVnUh3egw31b8=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
  ];

  buildInputs = [
    vulkan-headers
  ];

  cmakeFlags = [
    (lib.cmakeFeature "LSFGVK_MANAGED" "ON")
    (lib.cmakeFeature "LSFGVK_LAYER_LIBRARY_PATH" "${placeholder "out"}/lib/liblsfg-vk-layer.so")
  ];

  postFixup = ''
    wrapProgram $out/bin/lsfg-vk-cli \
      --prefix LD_LIBRARY_PATH : "${vulkan-loader}/lib"
  '';

  meta = {
    description = "Vulkan layer for frame generation (Requires owning Lossless Scaling)";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
})
