#!/usr/bin/perl
# mooreof@ie.ibm.com, September 2017

use strict;

use Getopt::Long;
use POSIX qw(strftime); 
use Time::Piece;
use Time::Seconds;

our $xmlType = "alert";
our $numberOfRecords = 100;
our $startRecord = 1;
our $tenant = "VDS_LILLE";
our $daysInPast = 25;
our $incrementInSeconds = 180;
our $outputFileNameSuffix = "1";
our $update = 0;
our $operation = "INSERT";
our $DATE_FORMAT = "%Y-%m-%d %H:%M:%S.000";

if ($ARGV[0] eq '-h') {
	usage("");
	exit;
}

GetOptions("x=s" => \$xmlType, 
		   "n=i" => \$numberOfRecords, 
		   "s=i" => \$startRecord, 
		   "t=s" => \$tenant,
		   "d=i" => \$daysInPast,
		   "i=i" => \$incrementInSeconds,
		   "u" => \$update,
		   "o=s" => \$outputFileNameSuffix)
		    || usage("Invalid command line options");


sub generateWOWXml
{
	$operation = ($update == 1) ? "UPDATE" : "INSERT";
	
	if ($xmlType eq 'alert') {
		generateWOWAlertsXml();
	} elsif ($xmlType eq 'wo') {
		generateWOWWorkOrdersXml();
	} elsif ($xmlType eq 'so') {
		generateWOWServiceOrdersXml();
	} else {
		printf "Unrecognised XML type: ${xmlType}\n"
	}
}

#-----------------------------------------------------
#  Work Orders
#-----------------------------------------------------
sub generateWOWWorkOrdersXml
{
	my $xml = getWoXmlHead() . getWoXmlBody() . getWoXmlTail();
	my $outputFileName = writeOutWoXml($xml);

	print "Done generating ${numberOfRecords} Work orders. Output: ${outputFileName}\n";
}

sub getWoXmlHead
{
	my $xml = <<XMLEND;
<?xml version="1.0" encoding="UTF-8"?>            
<wo:operations rootTenant="${tenant}" timeout="60000" timeoutTypeId="TEST" xmlns:wo="http://vds.com/workOrdersType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://vds.com/workOrdersType">            
	<wo:request type="${operation}">   
XMLEND

	return $xml;
}

sub getWoXmlBody
{
	my $i;
	my $baseDate = localtime();
	my $lastUpdateDateFormatted;
	my $woCreationDateFormatted;
	my $woTargetStartDateFormatted;
	my $woTargetEndDateFormatted;
	my $woActualStartDateFormatted;
	my $woActualEndDateFormatted;
	my $workOrderID;
	my $woDomain;
    my @woDomainTypes = qw(STREETWORK WATERSHUTOFF PLANT NETWORK);
	my $woStatus;
    my @woStatuses = qw(PLAN COMP REQUESTED PENDING REJECTED);
	my $woNetwork;
    my @woNetworks = qw(WATER DISTRICTHEAT);
	my $woLocation;
	my $xml = "";
	
	printf "Generating ${numberOfRecords} Work orders...\n";
	
	$baseDate -= ONE_DAY*${daysInPast};

	for ($i = 0; $i < $numberOfRecords; $i++) {
		$workOrderID = getWorkOrderID($i);
		$lastUpdateDateFormatted = getCurrentTimeFormatted();
		$woCreationDateFormatted = addDaysToBaseDateAndFormat($baseDate,0);
		$woTargetStartDateFormatted = addDaysToBaseDateAndFormat($baseDate,1);
		$woTargetEndDateFormatted = addDaysToBaseDateAndFormat($baseDate,14);
		$woActualStartDateFormatted = addDaysToBaseDateAndFormat($baseDate,2);
		$woActualEndDateFormatted = addDaysToBaseDateAndFormat($baseDate,10);
		$woDomain = getNextValueFromArray($i,@woDomainTypes);
		$woStatus = getRandomValueFromArray(@woStatuses);
		$woNetwork = getRandomValueFromArray(@woNetworks);
		$woLocation = getRandomPointLocation();

$xml.=<<XMLEND;
		<wo:workorder>            
			<wo:WOEXTID>${workOrderID}</wo:WOEXTID>
			<wo:TENANT_ID>${tenant}</wo:TENANT_ID>
			<wo:MODEL_ID>${tenant}</wo:MODEL_ID>
			<wo:SUBJECT>Manoeuvrer Vanne - ${workOrderID}</wo:SUBJECT>
			<wo:DESCRIPTION>Fuite cana</wo:DESCRIPTION>
			<wo:DOMAIN>${woDomain}</wo:DOMAIN>
			<wo:CATEGORY>RI</wo:CATEGORY>
			<wo:WORKORDERTYPE>Manoeuvrer Vanne</wo:WORKORDERTYPE>
			<wo:WORKTYPE>EAU-Vanne</wo:WORKTYPE>   
			<wo:SUBTYPE>Manoeuvrer Vanne</wo:SUBTYPE>
			<wo:FAILURE></wo:FAILURE>
			<wo:PRIORITY>N</wo:PRIORITY>
			<wo:STATUS>${woStatus}</wo:STATUS>
			<wo:JOBPLAN></wo:JOBPLAN>
			<wo:CREATIONDATE>${woCreationDateFormatted}</wo:CREATIONDATE>
			<wo:CREATIONTYPE>SYSTEM</wo:CREATIONTYPE>
			<wo:CREATEDBY>user\@ie.ibm.com</wo:CREATEDBY>
			<wo:TARGETSTARTDATE>${woTargetStartDateFormatted}</wo:TARGETSTARTDATE>
			<wo:TARGETENDDATE>${woTargetEndDateFormatted}</wo:TARGETENDDATE>
			<wo:ACTSTARTDATE>${woActualStartDateFormatted}</wo:ACTSTARTDATE>
			<wo:ACTENDDATE>${woActualEndDateFormatted}</wo:ACTENDDATE>
			<wo:LASTUPDATEDTS>${lastUpdateDateFormatted}</wo:LASTUPDATEDTS>
			<wo:ZONE>test</wo:ZONE>
			<wo:LOCATION>${woLocation}</wo:LOCATION>
			<wo:URL>http://w3.ibm.com</wo:URL>
			<wo:UPDATEDBY>user\@ie.ibm.com</wo:UPDATEDBY>
			<wo:LEAD></wo:LEAD>
			<wo:NETWORK>${woNetwork}</wo:NETWORK>
			<wo:ADDRESS></wo:ADDRESS>    
			<wo:PERFORMEDBY>user\@ie.ibm.com</wo:PERFORMEDBY>
			<wo:LOCOWNERID>admin\@ie.ibm.com</wo:LOCOWNERID>
			<wo:LOCOWNERDETAILS>Administrator</wo:LOCOWNERDETAILS>
			<wo:LOCCONTACTID>John Smith</wo:LOCCONTACTID>      
			<wo:LOCCONTACTDETAILS></wo:LOCCONTACTDETAILS>
			<wo:REPORT>Syste effectuée ras</wo:REPORT>
			<wo:SITE_ID>SWG</wo:SITE_ID>
		</wo:workorder>
XMLEND
		$baseDate += $incrementInSeconds;
	}
	return $xml;
}

sub getWoXmlTail
{
	my $xml = <<XMLEND;
	</wo:request>            
</wo:operations>
XMLEND

	return $xml;
}

sub writeOutWoXml
{
	my $xml = shift;
	my $outputFileName = getWoOutputFileName();
	
	open(OUT,'>',${outputFileName}) || die "Couldn't open \"${outputFileName}\": $!";
	print OUT $xml;
	close OUT;
	
	return $outputFileName;
}

sub getWorkOrderID
{
	my $index = shift;
	return sprintf("%s_W%07d",$tenant,$index+$startRecord);
}

sub getWoOutputFileName
{
	return sprintf("%s_WO_%d-%d_%d-%d_%s.xml",$tenant,$daysInPast,$incrementInSeconds,
						$startRecord,$startRecord+$numberOfRecords,$outputFileNameSuffix);
}

#-----------------------------------------------------
#  Service Orders
#-----------------------------------------------------
sub generateWOWServiceOrdersXml
{
	print "Service order generation not implemented yet\n";
}

#-----------------------------------------------------
#  Alerts
#-----------------------------------------------------
sub generateWOWAlertsXml
{
	my $xml = getAlertXmlHead() . getAlertXmlBody() . getAlertXmlTail();
	my $outputFileName = writeOutAlertXml($xml);

	print "Done generating ${numberOfRecords} alerts. Output: ${outputFileName}\n";
}

sub getAlertXmlHead
{
	my $xml = <<XMLEND;
<?xml version="1.0" encoding="UTF-8"?>
<alert:operations rootTenant="${tenant}" timeout="60000" timeoutTypeId="alert test" xmlns:alert="http://vds.com/alertsType" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://vds.com/alertsType">

XMLEND

	return $xml;
}

sub getAlertXmlBody
{
	my $i;
	my $baseDate = localtime();
	my $lastUpdateDateFormatted;
	my $eventStartDateFormatted;
	my $eventEndDateFormatted;
	my $eventID;
	my $eventType;
    my @eventTypes = qw(MOBILO LEAK CTRLVALVEKO PERMANENTLEAKAGE INTRUSION LEAKGUT);
	my $eventStatus;
    my @eventStatuses = qw(SUSPECTED TREATABLE TOBETREATED CLOSED);
	my $eventLocation;
	my $xml = "";

	printf "Generating ${numberOfRecords} alerts...\n";

	$baseDate -= ONE_DAY*${daysInPast};

	for ($i = 0; $i < $numberOfRecords; $i++) {
		$eventID = getAlertID($i);
		$eventStartDateFormatted = addDaysToBaseDateAndFormat($baseDate,0);
		$eventEndDateFormatted = addDaysToBaseDateAndFormat($baseDate,3);
		$lastUpdateDateFormatted = getCurrentTimeFormatted();
		$eventType = getNextValueFromArray($i,@eventTypes);
		$eventStatus = getRandomValueFromArray(@eventStatuses);
		$eventLocation = getRandomPointLocation();
		
$xml.=<<XMLEND;
	<alert:record>
		<alert:TENANT_ID>${tenant}</alert:TENANT_ID>
		<alert:EXTEVENTID>${eventID}</alert:EXTEVENTID>
		<alert:STARTTS>${eventStartDateFormatted}</alert:STARTTS>
		<alert:ENDTS>${eventEndDateFormatted}</alert:ENDTS>
		<alert:LASTUPDATEDTS>${lastUpdateDateFormatted}</alert:LASTUPDATEDTS>
		<alert:SUBJECT>Alert</alert:SUBJECT>
		<alert:CATEGORY>MISC</alert:CATEGORY>        
		<alert:EVENTYPE>${eventType}</alert:EVENTYPE>
		<alert:EVENTSUBTYPE>SUB-EVENT-EXAMPLE 10000</alert:EVENTSUBTYPE>
		<alert:CREATIONTYPE>SYSTEM</alert:CREATIONTYPE>
		<alert:LOCATION>${eventLocation}</alert:LOCATION>
		<alert:NETWORK>WATER</alert:NETWORK>
		<alert:STATUS>${eventStatus}</alert:STATUS>
		<alert:DOMAIN>ALERT</alert:DOMAIN>
	</alert:record>
XMLEND
		$baseDate += $incrementInSeconds;
	}
	
	return $xml;
}

sub getAlertXmlTail
{
	my $xml = <<XMLEND;
</alert:operations>
XMLEND

	return $xml;
}

sub writeOutAlertXml
{
	my $xml = shift;
	my $outputFileName = getAlertOutputFileName();
	
	open(OUT,'>',${outputFileName}) || die "Couldn't open \"${outputFileName}\": $!";
	print OUT $xml;
	close OUT;
	
	return $outputFileName;
}

sub getAlertID
{
	my $index = shift;
	return sprintf("%s_A%07d",$tenant,$index+$startRecord);
}

sub getAlertOutputFileName
{
	return sprintf("%s_Alerts_%d-%d_%d-%d_%s.xml",$tenant,$daysInPast,$incrementInSeconds,
						$startRecord,$startRecord+$numberOfRecords,$outputFileNameSuffix);
}

#-----------------------------------------------------
#  Generic methods
#-----------------------------------------------------
sub addDaysToBaseDateAndFormat
{
	my $baseDate = shift;
	my $daysToAdd = shift;
	my $newDate = Time::Piece->new($baseDate);
		
	$newDate += ONE_DAY * $daysToAdd;
	return $newDate->strftime($DATE_FORMAT);
}

sub getCurrentTimeFormatted
{
	return localtime()->strftime($DATE_FORMAT);
}

sub getRandomPointLocation
{
	my ($baseLat,$baseLon) =(41.6,-86.6); # South Bend, Indiana area
	my ($deltaLat,$deltaLon) =(0.25,1);
	my ($lat,$lon) = ($baseLat+rand($deltaLat),$baseLon+rand($deltaLon));

	return sprintf("POINT(%.5f %.5f)",$lon,$lat);
}


# Iterate through a list so we can generate the same records again to simulate updates
# To guarantee new records use the input parameter '-s start_record',
# 		where start_record is the current largest ID + 1
sub getNextValueFromArray
{
	my $i = shift;
	my @params = @_;
	my $numParams = scalar(@params);
	
	return $params[$i%$numParams];
}


sub getRandomValueFromArray
{
	my @params = @_;
	my $numParams = scalar(@params);
	
	return $params[int(rand($numParams))];
}

sub usage
{
	my $msg = shift;
	
	print $msg if $msg;

	print "\n\n";
	print "Usage: [perl] genXmlForWOWIngestion.pl [-h] | [-x (alert|wo|so) -n number_of_records \n";
	print "              -s start_record -t tenant -d days_in_past -i increment_in_seconds -u -o suffix]";
	print "\n";
	print "Required parameters:\n";
	print "Optional parameters:\n";
	print "    -x: type of xml to output, alert=alerts, wo=work orders, so=service orders (default 'alert')\n";
	print "    -n: number of records (default 100)\n";
	print "    -s: start record number or start record ID (default 1)\n";
	print "    -t: Tenant (default VDS_LILLE)\n";
	print "    -d: Days in past from which to start generating timestamps (default 25)\n";
	print "    -i: Number of seconds to increment timestamps for each alert (default 180)\n";
	print "    -u: Update instead of insert\n";
	print "    -o: Suffix to append to the base output file name (default '_1')\n";
	print " ----------------------------------------------------------------------------------------------------------------------------------\n";
	print "Example 1: ./genXmlForWOWIngestion.pl -x wo -n 10000 -s 100 -t VDS_LYON\n";
	print "        Generate 10,000 Workorder XMLs for tenant VDS_LYON, starting with ID 100\n";
}

generateWOWXml();
