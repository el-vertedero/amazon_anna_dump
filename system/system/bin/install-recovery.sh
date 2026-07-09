#!/system/bin/sh
if ! applypatch -c EMMC:/dev/block/platform/mstar_mci.0/by-name/recovery:20299776:1a5bbfcad3cb966fec97ed9d4b97fac574dc687b; then
  applypatch  EMMC:/dev/block/platform/mstar_mci.0/by-name/boot:13647872:390d7d721eab18bcfb4bd5770d2e80333e32f4e3 EMMC:/dev/block/platform/mstar_mci.0/by-name/recovery ff45e8ffd8b745ef153740c2911755e39e2d18b7 20297728 390d7d721eab18bcfb4bd5770d2e80333e32f4e3:/system/recovery-from-boot.p && installed=1 && log -t recovery "Installing new recovery image: succeeded" || log -t recovery "Installing new recovery image: failed"
  [ -n "$installed" ] && dd if=/system/recovery-sig of=/dev/block/platform/mstar_mci.0/by-name/recovery bs=1 seek=20297728 && sync && log -t recovery "Install new recovery signature: succeeded" || log -t recovery "Installing new recovery signature: failed"
else
  log -t recovery "Recovery image already installed"
fi
