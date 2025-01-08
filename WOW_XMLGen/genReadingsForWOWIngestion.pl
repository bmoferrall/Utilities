#!/usr/bin/perl
# mooreof@ie.ibm.com, September 2017

use strict;

use Getopt::Long;
use Time::Piece;
use Time::Seconds;
use POSIX qw(strftime); 

our $inputFile = undef;
our $iterations = 1;
our $daysInPast = 50;
our $incrementInSeconds = 900;
our $tenant = "VDS_LILLE";
our $totalEntries = 0;
our $suffix = "1";

if (@ARGV < 2 || $ARGV[0] eq '-h') {
	usage("") if $ARGV[0] eq '-h';
	usage("Missing parameters") if $ARGV[0] ne '-h';
	exit;
}

GetOptions("f=s" => \$inputFile, 
		   "n=i" => \$iterations, 
		   "d=i" => \$daysInPast, 
		   "i=i" => \$incrementInSeconds,
		   "t=s" => \$tenant,
		   "s=s" => \$suffix)
		    || usage("Invalid command line options");

usage("Missing required argument: input file (-f)") unless defined($inputFile);

sub generateWOWReadingXML
{
	my $xml = getXmlHead() . getXmlBody() . getXmlTail();
	my $outputFileName = writeOutXml($xml);

	printSuccessMessage($outputFileName);
}

sub getXmlHead
{
	my $xml=<<XMLEND;
<?xml version="1.0" encoding="UTF-8"?>

<readings:readings xmlns:readings="http://vds.com/readingsTypes">
XMLEND

	return $xml;
}

sub getXmlBody
{
	my $i = 0;
	my $baseDate = subtractUnitsFromCurrentTime('days',$daysInPast);
	my $iteration = 0;
	my @entries = ();
	my $xml = "";

	$totalEntries = loadEntriesFromTemplate(\@entries);

	for ($iteration = 0; $iteration < $iterations; $iteration++) {
		printf "Iteration: @{[${iteration}+1]}\n";
		
		for ($i = 0; $i<$totalEntries; $i++) {
			$xml .= getReadingSetXml($baseDate,$entries[$i]);
    	}
		$baseDate = addUnitsToTime($baseDate,'seconds',$incrementInSeconds);
	}

	return $xml;
}


# Format for input file:
# Asset Type ID, External Asset ID, Measurement Type ID, Range Start, Range End, Integer(0|1)
# Examples:
# Esri_wHydrant,607456,ENABLED,0,2,1
# Esri_wMain, 607456, PRESSURE, -10.5, 50, 0
sub loadEntriesFromTemplate
{
	my $refEntries = shift;
	my $i = 0;
	my $inputBuffer = "";
	#             asset type            asset id               meas type               
	my $pattern = "([0-9a-zA-Z\-\.\_]+),[ ]*([0-9a-zA-Z\-\.]+),[ ]*([A-Za-z0-9\.\-\_]+)," . 
	#             start value       end value        convert to int
	              "[ ]*([0-9\.\-]+),[ ]*([0-9\.\-]+),[ ]*([01])";
	my $numEntries = 0;
	
	open(INPUT,'<',$inputFile) || die "Cannot open " . $inputFile;
	$inputBuffer = join("",<INPUT>);
	close(INPUT);

	while ($inputBuffer =~ m!$pattern!g) {
		@{$refEntries}[$i] = {
			"assetType"  => $1,
			"assetId" => $2,
			"measType"  => $3,
			"rangeStart"  => $4,
			"rangeEnd"  => $5,
			"convertToInt" => $6
		};
		$i++;
	}
	$numEntries = scalar(@{$refEntries});
	print "${numEntries} entries loaded from ${inputFile}\n";
	
	return $numEntries;
}

sub getReadingSetXml
{
	my $baseDate = shift;
	my $refEntry = shift;
	my $timestamp = formatDate($baseDate);
	my $assetType = getAssetTypeFromEntry($refEntry);
	my $assetId = getAssetIdFromEntry($refEntry);
	my $measType = getMeasurementTypeFromEntry($refEntry);
	my $value = generateRandomValueForEntry($refEntry);
	
	my $xmlEntry = <<XMLEND;
  <readings:readingSet timestamp="${timestamp}">
    <readings:workEquipment extId="${assetId}" extType="${assetType}" modelRef="${tenant}" tenantId="${tenant}"/>
    <readings:readingValues>
      <readings:readingValue type="${measType}" value="${value}"/>
    </readings:readingValues>
  </readings:readingSet>
XMLEND

	return $xmlEntry;
}

sub getXmlTail
{
	my $xml = <<XMLEND;
</readings:readings>
XMLEND

	return $xml;
}

sub formatDate
{
	my $date = shift;
	
	return $date->strftime("%Y-%m-%d %H:%M:%S.00");
}

sub getAssetTypeFromEntry
{
	my $entry = shift;
	
	return $entry->{'assetType'};
}

sub getAssetIdFromEntry
{
	my $entry = shift;
	
	return $entry->{'assetId'};
}

sub getMeasurementTypeFromEntry
{
	my $entry = shift;
	
	return $entry->{'measType'};
}

sub generateRandomValueForEntry
{
	my $entry = shift;
	my $value = sprintf "%.2f" , $entry->{'rangeStart'} + 
										rand($entry->{'rangeEnd'} - $entry->{'rangeStart'});
	
	return $entry->{'convertToInt'} == 1 ? int($value) : $value;
}

sub getOutputFileName
{
	my $now = localtime()->strftime("%Y-%m-%d_%H-%M-%S");
	
	return sprintf("%s_readings_%s_i%d-d%d-s%d_%s.xml",
					$tenant,$now,$iterations,$daysInPast,$incrementInSeconds,$suffix);
}

sub writeOutXml
{
	my $xml = shift;
	my $outputFileName = getOutputFileName();
	
	open(OUT,'>',"${outputFileName}") || die "Couldn't open \"${outputFileName}\": $!";
	print OUT $xml;
	close OUT;
	
	return $outputFileName;
}

sub printSuccessMessage
{
	my $fileName = shift;
	my $numberOfGeneratedReadings = $iterations*$totalEntries;

	print "Done generating ${numberOfGeneratedReadings} readings from ${inputFile}. Output: ${fileName}\n";
}

sub subtractUnitsFromCurrentTime
{
	my $unit = shift;
	my $n = shift;
	my $time = localtime();
	
	return subtractUnitsFromTime($time,$unit,$n);
}


sub addUnitsToCurrentTime
{
	my $unit = shift;
	my $n = shift;
	my $time = localtime();
	
	return addUnitsToTime($time,$unit,$n);
}

sub subtractUnitsFromTime
{
	my $time = shift;
	my $unit = shift;
	my $n = shift;

	return $time - getDeltaInSeconds($unit,$n);
}

sub addUnitsToTime
{
	my $time = shift;
	my $unit = shift;
	my $n = shift;

	return $time + getDeltaInSeconds($unit,$n);
}

sub getDeltaInSeconds
{
	my $unit = shift;
	my $n = shift;
	my $delta = 0;

	if ($unit eq 'seconds') {
		$delta = $n;
	} elsif ($unit eq 'minutes') {
		$delta = ONE_MINUTE * $n;
	} elsif ($unit eq 'hours') {
		$delta = ONE_HOUR * $n;
	} elsif ($unit eq 'days') {
		$delta = ONE_DAY * $n;
	} elsif ($unit eq 'months') {
		$delta = ONE_MONTH * $n;
	} elsif ($unit eq 'years') {
		$delta = ONE_YEAR * $n;
	}

	return $delta;
}

sub usage
{
	my $msg = shift;
	
	print $msg if $msg;

	print "\n\n";
	print "Usage: [perl] genReadingsForWOWIngestion.pl [-h] | -f input_file [-n iterations -d days_in_past -i increment_in_seconds -t tenant -s suffix]";
	print "\n";
	print "Required parameters:\n";
	print "    -f: Input file, with format as follows (optional space after commas):\n";
	print "        Asset Type ID, External Asset ID, Measurement Type ID, Range Start, Range End, Integer(0|1)\n";
	print "        Examples:\n";
	print "        Esri_wHydrant,607456,ENABLED,0,2,1\n";
	print "        Esri_wMain, 607456, PRESSURE, -10.5, 50, 0\n";
	print "        \n";
	print "        The script will generate a reading value between Range Start and Range End, converting to Integer if the last value is 1\n";
	print "Optional parameters:\n";
	print "    -n: Number of iterations to generate readings for the input file (default 1)\n";
	print "    -d: Number of Days in Past. Generated reading time stamps will start from this point (default 50)\n";
	print "    -i: Increment in seconds. The timestamp for each block of readings is incremented by this amount (default 900)\n";
	print "    -t: Tenant (default VDS_LILLE)\n";
	print "    -s: Suffix to output file name (default '_1')\n";
	print " ----------------------------------------------------------------------------------------------------------------------------------\n";
	print "Example 1: ./genReadingsForWOWIngestion.pl -f Hydrants1.txt -n 5 -d 50 -i 3600 -t VDS_LYON -s 2\n";
	print "        Load template for readings from Hydrants1.txt, generate 5 times the number of entries in Hydrants1.txt\n";
	print "            starting with a timestamp 50 days ago and incrementing 1 hour for each block of entries in Hydrants1.txt\n";
}

generateWOWReadingXML();
