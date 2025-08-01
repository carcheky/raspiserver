#!/bin/sh
# For on-board BT, configure the BDADDR if necessary and route SCO packets
# to the HCI interface (enables HFP/HSP)

set -e

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <bluetooth hci device>"
    exit 0
fi

dev=$1

# Need to bring hci up before looking at MAC as it can be all zeros during init
/bin/hciconfig $dev up
if ! /bin/hciconfig $dev | grep -q "Bus: UART"; then
    echo Not a UART-attached BT Modem
    exit 0
fi

if ( /usr/bin/hcitool -i $dev dev | grep -q -E '\s43:4[35]:|AA:AA:AA:AA:AA:AA' ); then
    SERIAL=`cat /proc/device-tree/serial-number | cut -c9-`
    B1=`echo $SERIAL | cut -c3-4`
    B2=`echo $SERIAL | cut -c5-6`
    B3=`echo $SERIAL | cut -c7-8`
    BDADDR=`printf '0x%02x 0x%02x 0x%02x 0xeb 0x27 0xb8' $((0x$B3 ^ 0xaa)) $((0x$B2 ^ 0xaa)) $((0x$B1 ^ 0xaa))`

    /usr/bin/hcitool -i $dev cmd 0x3f 0x001 $BDADDR
    /bin/hciconfig $dev reset
else
    echo Raspberry Pi BDADDR already set
fi

# Route SCO packets to the HCI interface (enables HFP/HSP)
/usr/bin/hcitool -i $dev cmd 0x3f 0x1c 0x01 0x02 0x00 0x01 0x01 > /dev/null

# Force reinitialisation to allow extra features such as Secure Simple Pairing
# to be enabled, for currently unknown reasons. This requires bluetoothd to be
# running, which it isn't yet. Use this kludge of forking off another shell
# with a delay, pending a complete understanding of the issues.
(sleep 5; /usr/bin/bluetoothctl power off; /usr/bin/bluetoothctl power on) &