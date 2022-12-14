{ ... }: {}
# grub2 = prev.grub2.overrideAttrs (oa: {
#   version = "2.06.r291";
#   src = prev.fetchgit {
#     url = "https://git.savannah.gnu.org/git/grub.git";
#     rev = "e43f3d93b28cce852c110c7a8e40d8311bcd8bb1";
#     hash = "sha256-8M0WqeDE4Hrwq/zlygfbAWUt7vdDeqfJLX1ADzQGM3I=";
#   };
#   patches = [
#     ./packages/grub/fix-bash-completion.patch
#     ./packages/grub/add-hidden-menu-entries.patch
#     ./packages/grub/license.patch
#     ./packages/grub/5000-grub-2.06-luks2-argon2-v4.patch
#     ./packages/grub/9500-grub-AUR-improved-luks2.patch
#   ];

#   # GRUB_AUTOGEN="1";

#   nativeBuildInputs = with prev; [ bison flex python3 pkg-config gettext freetype autoconf automake ];
#   # nativeBuildInputs = oa.nativeBuildInputs ++ [
#     # prev.autoconf prev.automake
#   #   prev.autogen
#   #   # prev.libargon2
#   # ];

#   # buildInputs = oa.buildInputs ++ [ prev.libargon2 ];
#   # CPPFLAGS="-O2";
#   # NIX_CFLAGS_COMPILE = "-Wno-error -O2";

#   # configureFlags = [
#   #   "GRUB_ENABLE_CRYPTODISK=y"
#   #   "TARGET_CFLAGS=-O2"
#   #   "--disable-werror"
#   #   "CFLAGS=\"\${CFLAGS/-fno-plt}\""
#   #   "CPPFLAGS=\"-O2\""
#   #   "--disable-silent-rules"
#   #   "--disable-werror"
#   # ] ++ oa.configureFlags;
#   # NIX_CFLAGS_COMPILE = "-O2";
#   # CFLAGS="-fno-plt";
#   # configureFlags = oa.configureFlags ++ [
#   #   # "--enable-boot-time"
#   #   # "--enable-cache-stats"
#   #   # "--enable-device-mapper"
#   #   # "--enable-grub-mkfont"
#   #   # "--enable-grub-mount"
#   #   # "--enable-mm-debug"
#   #   "--disable-silent-rules"
#   #   "--disable-werror"
#   #   # "CPPFLAGS=\"$CPPFLAGS -O2\""
#   # ];
#   preConfigure = with prev; ''
#     for i in "tests/util/"*.in
#     do
#       sed -i "$i" -e's|/bin/bash|${stdenv.shell}|g'
#     done
#     # Apparently, the QEMU executable is no longer called
#     # `qemu-system-i386', even on i386.
#     #
#     # In addition, use `-nodefaults' to avoid errors like:
#     #
#     #  chardev: opening backend "stdio" failed
#     #  qemu: could not open serial device 'stdio': Invalid argument
#     #
#     # See <http://www.mail-archive.com/qemu-devel@nongnu.org/msg22775.html>.
#     sed -i "tests/util/grub-shell.in" \
#         -e's/qemu-system-i386/qemu-system-x86_64 -nodefaults/g'
#     unset CPP # setting CPP intereferes with dependency calculation

#     patchShebangs .

#     ./bootstrap --no-git --gnulib-srcdir=${gnulib} # my changes

#     substituteInPlace ./configure --replace '/usr/share/fonts/unifont' '${unifont}/share/fonts'

#     sed -i 's/idx_t/grub_size_t/g' ./grub-core/disk/luks2.c # my changes
#   '';
#   # preConfigure = oa.preConfigure + ''
#   #   echo "I'm here!"
#   #   ./bootstrap --no-git --gnulib-srcdir=${prev.gnulib}
#   # '';
#   # postPatch = let
#   #   bash-patch = ./packages/grub/fix-bash-completion.patch;
#   #   menu-patch = ./packages/grub/add-hidden-menu-entries.patch;
#   #   # alloc-patch = ./packages/grub/4500-grub-2.06-runtime-memregion-alloc.patch;
#   #   luks-argon2-patch = ./packages/grub/5000-grub-2.06-luks2-argon2-v4.patch;
#   #   luks2-patch = ./packages/grub/9500-grub-AUR-improved-luks2.patch;
#   #   argon1-patch = ./packages/grub/argon_1.patch;
#   #   argon2-patch = ./packages/grub/argon_2.patch;
#   #   argon3-patch = ./packages/grub/argon_3.patch;
#   #   argon4-patch = ./packages/grub/argon_4.patch;
#   #   argon5-patch = ./packages/grub/argon_5.patch;
#   # in ''
#   #   patch -Np1 -i "${bash-patch}"
#   #   patch -Np1 -i "${menu-patch}"
#   #   # patch -Np1 -i "${argon1-patch}"
#   #   # patch -Np1 -i "${argon2-patch}"
#   #   # patch -Np1 -i "${argon3-patch}"
#   #   # patch -Np1 -i "${argon4-patch}"
#   #   # patch -Np1 -i "${argon5-patch}"
#   #   patch -Np1 -i "${luks-argon2-patch}"
#   #   patch -Np1 -i "${luks2-patch}"
#   #   # ls -lah ./
#   #   # ls -lah ./grub-core
#   #   # echo "CFLAGS"
#   #   # echo $CFLAGS
#   #   # sed -i 's#rm -f kernel_syms.input#cat kernel_syms.input; rm -f kernel_syms.input#' ./grub-core/Makefile.am
#   #   # sed -i 's#cat $<#cat $<\n\tcat $<#' ./grub-core/Makefile.am
#   #   # exit 1
#   # '' + oa.postPatch;
# });