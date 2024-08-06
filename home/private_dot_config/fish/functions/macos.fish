function macos --description "Describe system"

    ###############
    # Hardware
    ###############

    set --local MODEL_NAME (system_profiler SPHardwareDataType | grep "Model Name" | cut -d ':' -f 2 | xargs)
    set --local MODEL_IDENTIFIER (system_profiler SPHardwareDataType | grep "Model Identifier" | cut -d ':' -f 2 | xargs)
    set --local CHIP (system_profiler SPHardwareDataType | grep "Chip" | cut -d ':' -f 2 | xargs)
    set --local MEMORY (system_profiler SPHardwareDataType | grep "Memory" | cut -d ':' -f 2 | xargs)
    set --local COMPUTER_SERIAL_NUMBER (system_profiler SPHardwareDataType | awk '/Serial Number/ { print $4 }')
    set --local DISK_CAPACITY $(system_profiler SPStorageDataType | awk '/Capacity/ { if (NR<14) print $2 }')
    set --local DISK_FREE $(system_profiler SPStorageDataType | awk '/Free/ { if (NR<14) print $2 }')

    ###############
    # O/S
    ###############

    set --local PRODUCT_NAME (sw_vers -productName)
    set --local PRODUCT_VERSION (sw_vers -productVersion)
    set --local BUILD_VERSION (sw_vers -buildVersion)

    ###############
    # SYSTEM
    ###############
    set --local HOSTNAME (hostname)

    ###############
    # OUTPUT
    ###############

    echo "Model: $MODEL_NAME ($MODEL_IDENTIFIER)"
    echo "Chip: $CHIP"
    echo "Serial Number: $COMPUTER_SERIAL_NUMBER"
    echo "Memory: $MEMORY"
    echo "Disk Space: $DISK_FREE/$DISK_CAPACITY GB"

    echo "Operating System: $PRODUCT_NAME $PRODUCT_VERSION $BUILD_VERSION"
    echo "Hostname: $HOSTNAME"

end
