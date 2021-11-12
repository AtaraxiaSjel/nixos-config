{ stdenv, lib, runtimeShell
, name ? "android-emulator", sdk ? null, deviceType ? ""
, platformVersion ? "30", systemImageType ? "default", abiVersion ? "x86_64"
, enableGPU ? false, extraAVDFiles ? []
, app ? null, package ? null, activity ? null
, avdHomeDir ? null
}:

stdenv.mkDerivation {
  inherit name;

  buildCommand = ''
    mkdir -p $out/bin

    cat > $out/bin/${name}-run << "EOF"
    #!${runtimeShell} -e

    # We need a TMPDIR
    if [ "$TMPDIR" = "" ]
    then
        export TMPDIR=/tmp
    fi

    ${if avdHomeDir == null then ''
      # Store the virtual devices somewhere else, instead of polluting a user's HOME directory
      export ANDROID_SDK_HOME=$(mktemp -d $TMPDIR/nix-android-vm-XXXX)
    '' else ''
      mkdir -p "${avdHomeDir}"
      export ANDROID_SDK_HOME="${avdHomeDir}"
    ''}

    # We need to specify the location of the Android SDK root folder
    export ANDROID_SDK_ROOT=${sdk}

    # We have to look for a free TCP port

    echo "Looking for a free TCP port in range 5554-5584" >&2

    for i in $(seq 5554 2 5584)
    do
        if [ -z "$(${sdk}/platform-tools/adb devices | grep emulator-$i)" ]
        then
            port=$i
            break
        fi
    done

    if [ -z "$port" ]
    then
        echo "Unfortunately, the emulator port space is exhausted!" >&2
        exit 1
    else
        echo "We have a free TCP port: $port" >&2
    fi

    export ANDROID_SERIAL="emulator-$port"

    # Create a virtual android device for testing if it does not exist
    # ${sdk}/cmdline-tools/latest/bin/avdmanager list target

    if [ "$(${sdk}/cmdline-tools/latest/bin/avdmanager list avd | grep 'Name: ${name}')" = "" ]
    then
        # Create a virtual android device
        yes "" | ${sdk}/cmdline-tools/latest/bin/avdmanager create avd -n "${name}" -k "system-images;android-${platformVersion};${systemImageType};${abiVersion}" -d "${deviceType}" $NIX_ANDROID_AVD_FLAGS

        # fix wrong sdk path
        sed -i "s|image.sysdir.1.\+|image.sysdir.1=${sdk}/system-images/android-${platformVersion}/${systemImageType}/${abiVersion}|" "$ANDROID_SDK_HOME/.android/avd/${name}.avd/config.ini"

        ${lib.optionalString enableGPU ''
          # Enable GPU acceleration
          echo "hw.gpu.enabled=yes" >> "$ANDROID_SDK_HOME/.android/avd/${name}.avd/config.ini"
        ''}

        ${lib.concatMapStrings (extraAVDFile: ''
          ln -sf ${extraAVDFile} "$ANDROID_SDK_HOME/.android/avd/${name}.avd"
        '') extraAVDFiles}
    fi

    # Launch the emulator
    ${sdk}/emulator/emulator -avd "${name}" -no-boot-anim -port $port $NIX_ANDROID_EMULATOR_FLAGS &

    # Wait until the device has completely booted
    echo "Waiting until the emulator has booted the device and the package manager is ready..." >&2

    ${sdk}/platform-tools/adb -s emulator-$port wait-for-device

    echo "Device state has been reached" >&2

    while [ -z "$(${sdk}/platform-tools/adb -s emulator-$port shell getprop dev.bootcomplete | grep 1)" ]
    do
        sleep 5
    done

    echo "dev.bootcomplete property is 1" >&2

    #while [ -z "$(${sdk}/platform-tools/adb -s emulator-$port shell getprop sys.boot_completed | grep 1)" ]
    #do
        #sleep 5
    #done

    #echo "sys.boot_completed property is 1" >&2

    echo "ready" >&2

    ${lib.optionalString (app != null) ''
      # Install the App through the debugger, if it has not been installed yet

      if [ -z "${package}" ] || [ "$(${sdk}/platform-tools/adb -s emulator-$port shell pm list packages | grep package:${package})" = "" ]
      then
          if [ -d "${app}" ]
          then
              appPath="$(echo ${app}/*.apk)"
          else
              appPath="${app}"
          fi

          ${sdk}/platform-tools/adb -s emulator-$port install "$appPath"
      fi

      # Start the application
      ${lib.optionalString (package != null && activity != null) ''
          ${sdk}/platform-tools/adb -s emulator-$port shell am start -a android.intent.action.MAIN -n ${package}/${activity}
      ''}
    ''}
    EOF
    chmod +x $out/bin/${name}-run
  '';
}
