#! @shell@

console=tty1

fail() {
    if [ -n "$panicOnFail" ]; then exit 1; fi

    @preFailCommands@

    # If starting stage 1 failed, allow the user to repair the problem
    # in an interactive shell.
    cat <<EOF

Error: [1;31m ${1} [0m

An error occurred in stage 1 of the boot process. Press one of the following
keys:

  i) to launch an interactive shell
  r) to reboot immediately
  *) to ignore the error and continue
EOF

    if [ -n "@predefinedFailAction@" ]; then
      echo "Failure action is predefined, using '@predefinedFailAction@'"
      reply="@predefinedFailAction@"
    else
      read reply
    fi

    if [ "$reply" = i ]; then
        echo "Starting interactive shell..."
        setsid @shell@ -c "@shell@ < /dev/$console >/dev/$console 2>/dev/$console" || fail "Can't spawn shell"
    elif [ "$reply" = r ]; then
        echo "Rebooting..."
        reboot -f
    else
        echo "Continuing..."
    fi
}

trap 'fail' 0

echo
echo "[1;32m<<< vpsAdminOS Stage 1 >>>[0m"
echo

export LD_LIBRARY_PATH=@extraUtils@/lib
export PATH=@extraUtils@/bin/
mkdir -p /proc /sys /dev /etc/udev /tmp /run/ /lib/ /mnt/ /var/log /bin

mount -t devtmpfs devtmpfs /dev/
mkdir /dev/pts
mount -t devpts devpts /dev/pts

mount -t proc proc /proc
mount -t sysfs sysfs /sys

# Copy the secrets to their needed location
if [ -d "@extraUtils@/secrets" ]; then
    for secret in $(cd "@extraUtils@/secrets"; find . -type f); do
        mkdir -p $(dirname "/$secret")
        ln -s "@extraUtils@/secrets/$secret" "$secret"
    done
fi

ln -sv @shell@ /bin/sh
ln -sv @shell@ /bin/ash
ln -s @modules@/lib/modules /lib/modules

echo @extraUtils@/bin/modprobe > /proc/sys/kernel/modprobe
for x in @modprobeList@; do
  modprobe $x
done

root=/root.squashfs
live=yes
for o in $(cat /proc/cmdline); do
  case $o in
    console=*)
      set -- $(IFS==; echo $o)
      params=$2
      set -- $(IFS=,; echo $params)
      console=$1
      ;;
    systemConfig=*)
      set -- $(IFS==; echo $o)
      sysconfig=$2
      ;;
    root=*)
      # Use root device specified on the kernel command line
      # Recognise LABEL= and UUID= to support UNetbootin.
      set -- $(IFS==; echo $o)
      if [ $2 = "LABEL" ]; then
          root="/dev/disk/by-label/$3"
      elif [ $2 = "UUID" ]; then
          root="/dev/disk/by-uuid/$3"
      else
          root=$2
      fi
      ;;
    netroot=*)
      set -- $(IFS==; echo $o)
      mkdir -pv /var/run /var/db
      sleep 5
      dhcpcd eth0 -c ${dhcpHook}
      tftp -g -r "$3" "$2"
      root=/root.squashfs
      ;;
    nolive)
      live=no
      ;;
  esac
done


echo "running udev..."
mkdir -p /etc/udev
ln -sfn @udevRules@ /etc/udev/rules.d
ln -sfn @udevHwdb@ /etc/udev/hwdb.bin
udevd --daemon --resolve-names=never
udevadm trigger --action=add
udevadm settle --timeout=30 || fail "udevadm settle timed-out"

@preLVMCommands@
@postDeviceCommands@

udevadm control --exit

if [ "$live" == "yes" ] ; then
  mount -t tmpfs root /mnt/ -o size=6G || fail "Can't mount root tmpfs"
  chmod 755 /mnt/
  mkdir -p /mnt/nix/store/

  # make the store writeable
  mkdir -p /.ro-store /mnt/nix/.overlay-store /mnt/nix/store
  mount $root /.ro-store -t squashfs || fail "Can't mount root from $root"
  mount tmpfs -t tmpfs /mnt/nix/.overlay-store -o size=@storeOverlaySize@
  mkdir -pv /mnt/nix/.overlay-store/work /mnt/nix/.overlay-store/rw
  modprobe overlay
  mount -t overlay overlay -o lowerdir=/.ro-store,upperdir=/mnt/nix/.overlay-store/rw,workdir=/mnt/nix/.overlay-store/work /mnt/nix/store

  if [ -d /mnt/nix/store/secrets ] ; then
    chmod 0500 /mnt/nix/store/secrets
  fi

else
  if [ -b "$root" ] ; then
    mount "$root" /mnt || fail "Can't mount rootfs from $root"
  else
    exec 3< @fsInfo@
    while read -u 3 mountPoint; do
      read -u 3 device
      read -u 3 fsType
      read -u 3 options

      echo "mounting $device on $mountPoint..."
      echo "$device /mnt$mountPoint $fsType $options" >> /etc/fstab
      mkdir -p "/mnt$mountPoint"
      mount "/mnt$mountPoint"
    done
    exec 3>&-

    if [ ! -x "/mnt/$sysconfig/init" ]; then
      echo "$root does not exist, unable to mount rootfs"
      @shell@
    fi
  fi
fi

@postMountCommands@

exec env -i $(type -P switch_root) /mnt/ $sysconfig/init
exec ${shell}
