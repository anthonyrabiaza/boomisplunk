#!/bin/bash

## Anthony Rabiaza (anthony.rabiaza@gmail.com)
## 2021-09-30

#########   ENVS   #########

export boomiMoleculeDir=/mnt/nfs/centos_molecule/Boomi_AtomSphere/Molecule/Molecule_centos_linux_cluster/bin/views
export networkInterface=ens33
export splunkInputsConf=/opt/splunkforwarder/etc/system/local/inputs.conf

######### END ENVS #########

#########   FUNC   #########

function getProperty {

    PROP_KEY=$1
    PROP_VALUE=`cat $2 | grep "$PROP_KEY" | cut -d'=' -f2`
    echo $PROP_VALUE
}

function updateSplunkInputs {

    echo "Updating Splunk inputs ($2)..."

    if [ "$1" = "true" ]; then
        echo "Enabling the disabled inputs..."
        export initialValue=1
        export targetValue=0
    else
        echo "Disabling the enabled inputs..."
        export initialValue=0
        export targetValue=1
    fi

    export lineToUpdate="disabled = ${initialValue}"
    echo "Looking for $lineToUpdate"
    export lineNumber=$(awk "/$lineToUpdate/{print NR}" $2)
    echo "Line number is $lineNumber"

    numba='^[0-9]+$'
    if [[ $lineNumber =~ $numba ]] ; then
        sed -i "${lineNumber}s/${initialValue}/${targetValue}/" $2
        echo "Value updated"
    else
        echo "Value not found"
    fi

    echo "Done"
}

######### END FUNC #########

#Checking Splunk configuration
if [ -f "$splunkInputsConf" ]; then
    echo "$splunkInputsConf exists. Continuing ..."
else
    echo "$splunkInputsConf doesn't exists!"
    exit -1
fi

#Getting ip4 address
export localIp4=$(/sbin/ip -o -4 addr list ${networkInterface} | awk '{print $4}' | cut -d/ -f1)

#Replacing dot with _
export boomiNodeId="${localIp4//./_}"

#In case of multiple address, taking only the first one
export boomiNodeId=$(echo $boomiNodeId | head -n1 | awk '{print $1;}')

export boomiHead=$(getProperty 'view.head' $boomiMoleculeDir/node.$boomiNodeId.dat)

echo "Current Boomi Node is $boomiNodeId"
echo "Current Head  Node is $boomiHead"

if [ "$boomiNodeId" = "$boomiHead" ]; then
    export boomiHeadNode=true
else
    export boomiHeadNode=false
fi

if [ -f "$boomiNodeId.prop" ]; then
    export boomiLastHeadStatus=$(getProperty 'lastHeadStatus' $boomiNodeId.prop)
else
    export boomiLastHeadStatus='unknown'
fi

echo "Last    Head  Node is $boomiLastHeadStatus"

#########   LOGIC   #########

if [ "$boomiHeadNode" = "$boomiLastHeadStatus" ]; then
    echo "The current status is the same as before, no change"
else
    echo "The current status is different as before, applying change..."
    updateSplunkInputs $boomiHeadNode $splunkInputsConf
    echo "Restarting Splunk Forwarder..."
    systemctl restart SplunkForwarder
fi

echo "lastHeadStatus=$boomiHeadNode" > $boomiNodeId.prop
echo "date=`date`" >> $boomiNodeId.prop

######### END LOGIC #########