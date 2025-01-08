#!/bin/bash

# Configuration for WAS
profile=ctgAppSrv01
server=MXServer
node=ctgNode01
cell=ctgCell01
app=MAXIMO
ear=/opt/IBM/SMP/maximo/deployment/default/maximo.ear

function cleanPropertyValue() {
	local property=$1

	# Remove leading property whitespace
	property=$(echo "${property}" | sed 's/^[:=][[:space:]]*//')
	# Remove trailing property whitespace
	property=$(echo "${property}" | sed 's/[[:space:]]*$//')
	# Remove "Windows" CR character (if any) from property.
	property=$(echo "${property}" | sed 's|\r$||')
	
	echo -n "$property"
}

profile=$(cleanPropertyValue $profile)
server=$(cleanPropertyValue $server)
node=$(cleanPropertyValue $node)
cell=$(cleanPropertyValue $cell)
app=$(cleanPropertyValue $app)
ear=$(cleanPropertyValue $ear)
