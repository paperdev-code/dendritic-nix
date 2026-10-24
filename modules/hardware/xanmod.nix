{
  modules.xanmod.nixos = { pkgs, ... }: {
    boot = {
      kernelPackages = pkgs.linuxKernel.packages.linux_xanmod_latest;
      kernelParams = [ "preempt=full" ];
    };
  };
}
