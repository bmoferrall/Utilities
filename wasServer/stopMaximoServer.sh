#/bin/sh

usage() {
   local msg=$1
   
   echo ">>>> ${msg} <<<<<<"
   echo "------------------------------------------------------------------------------------"
   echo "Usage:   ./stopMaximoServer.sh -p wasadmin_password -h"
   echo "   Required:"
   echo "      -p: password for wasadmin"
   echo "   Optional:"
   echo "   "
   echo "      -h: usage"
   echo "   "
   echo "Example: ./stopMaximoServer.sh -p P33kachu!"
   echo "------------------------------------------------------------------------------------"
   exit 1
}

source "./serverProperties.sh"
password=
scriptLocation="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while getopts p:h option
do
   case $option in
	p) password="${OPTARG}"
	;;
	h) usage "USAGE"
	;;
	*) usage "Unrecognised Option ${option}"
	;;
   esac
done

if [ -z "$password" ] 
then
   usage "Missing required parameter(s)"
fi

/opt/IBM/WebSphere/AppServer/profiles/$profile/bin/wsadmin.sh -user wasadmin -password ${password} -lang jython -f ${scriptLocation}/wasMaximoCommand.py -a stop -s ${server} -n ${node} -l ${cell}
