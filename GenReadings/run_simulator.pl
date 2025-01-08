#!/usr/bin/perl

########################################################################
# 
# File   :  run_simulator.pl
# History:  Oct-2014 (mooreof@ie.ibm.com)
#
########################################################################
#
# Run IOW simulator at different event input rates and for different
# durations
# 
########################################################################

use strict;
use Getopt::Long;
#use Data::Dump qw(dump);
use POSIX qw(strftime);
use File::Copy "cp";
use DateTime;
use POSIX qw(strftime); 


our $simCommandDir = '/opt/IBM/water/apps/simulator/';
our $simCommandParent = 'run_simulator.sh';
our $simCommandChild = 'simulator.properties';
our $simInputDir = '/opt/IBM/water/apps/simulator/incoming/';
our $simSavedDir = '/opt/IBM/water/apps/simulator/saved/';
our $simConfig = '/opt/IBM/water/apps/simulator/simulator.properties';
our $templateCsv = '/opt/IBM/water/apps/simulator/event_template.csv';
our @simSpec = ();
# set some defaults
our $cmdSpec="";
our $thresholdExceedCount = 0;
our $timeIncrementInSecs = 10;
our $pauseTimeBetweenPhases = 120;
our $baseDate;
our $daysInPast = 180;
our $csvCount = 1;
our $recordSpec = '';
our @recordCounts = ();
our $recordCount = 0; 
our @eventRecords = ();
our $remEvents = 0;
our $templateLines = 0;
our $origTemplateLines = 0;
our $batchModeOn = 1; # batch=false/true in simulator.properties
our $batchMax = 500; # batch.max value in simulator.properties
our $repeatCount = 1; # Number of readings in a row to generate for each measurement id

# enum/constant may not be supported
our $ERROR_ = 0;
our $WARNING_ = 1;
our $INFO_ = 2;
our $VERBOSE_ = 3;
our @logLevels = ('ERROR','WARNING','INFO','VERBOSE');
our $logLevel = $VERBOSE_;

local $| = 1; # autoflush stdout

# print usage argument is -h
if ($#ARGV == 0 && $ARGV[0] eq '-h') {
	usage("");
	exit;
}

GetOptions("s=s" => \$cmdSpec, # specification for phases as comma-separated list of interval=duration pairs
		   "t=i" => \$thresholdExceedCount, # num events to generate before an event that exceeds a threshold value
		   "d=i" => \$daysInPast, # number of days in past from whence to start generating reading times
		   "i=i" => \$timeIncrementInSecs, # num seconds to increment date for each iteration of the base event list
		   "p=i" => \$pauseTimeBetweenPhases, # pause time between each phase defined in $cmdSpec
		   "r=i" => \$repeatCount, # Number of readings in a row to generate for each measurement id
		   "l=i" => \$logLevel) # level of logging
		    || usage("Invalid command line options");

if ($cmdSpec eq '') {
	usage("Missing required parameters");
	exit;
}


sub main
{
	my $now = strftime("%a %b %d %H:%M:%S %Y",localtime);
	my $phase = 0;
	my ($start_time,$end_time);

	$logLevel = $VERBOSE_ if ($logLevel < $ERROR_ || $logLevel > $VERBOSE_);
	print ">> LOGLEVEL=@{[$logLevels[$logLevel]]} <<\n";
	logf(">> START -> $now\n\n", $INFO_);

	mkdir($simSavedDir) if !(-d $simSavedDir);
	@simSpec = split(',',$cmdSpec);
	fail("Invalid command line specification: $cmdSpec\n") if (@simSpec < 1);
	foreach my $spec (@simSpec) {
		my ($rate,$dur) = split('=',$spec);
		fail("Invalid specification '$spec' (rate=duration)") if ($rate !~ /[0-9][.0-9]*/ or $dur !~ /[1-9][0-9]*/);
		logf("Rate per second: ${rate}, Duration: ${dur} secs\n",$VERBOSE_);
	}
	initEvents();
	$baseDate = DateTime->now;
	$baseDate->subtract('days'=>$daysInPast);
	
	foreach my $spec (@simSpec) {
		$phase++;
		$recordCount = calcPhaseRecordCount($spec);
		$csvCount = int($recordCount/$templateLines)+1;
		$remEvents = $recordCount % $templateLines;
		logf("\nStopping the simulator\n");
		stopSimulator();
		clearInputDir();
		my ($rate,$dur) = split('=',$spec);
		my $int = calcPhaseEventInterval($rate);
		logf("\nStarting the simulator with event rate=${rate} per second for a duration of ${dur} secs (phase ${phase}); batch.max=${batchMax}\n");
		startSimulator($int);
		for (my $i=1; $i<=$csvCount; $i++) {
			$start_time = time();
			genInputFile($i==$csvCount);
			$end_time = time();
			while ($end_time-$start_time < ($dur/$csvCount)) {
				pause(1);
				$end_time = time();
			}
			print " | ";
		}
		pause($pauseTimeBetweenPhases) unless ($phase==@simSpec);
	}
	#stopSimulator();
	$now = strftime("%a %b %d %H:%M:%S %Y",localtime);
	logf("\n\n>> END -> $now\n\n");
}

sub clearInputDir
{
	logf("Clearing csv files in input dir...\n");
	system("rm -f ${simInputDir}*.csv > /dev/null");
}

# Initialize event record array from event template file
# Format of template file:
# measurementid,normal_range_start-normal_range_end,action_range_start-action_range_end
# 39##TBLFLOAT_RT##Val,0-10,100-150
sub initEvents
{
	my ($line,@origlines,@lines,$recordsLen,$contents);

	# initiliase batch.max from simulator.properties
	open (CFG, '<', $simConfig) || fail("Cannot open configuration file '${simConfig}': $!\n");
	my $contents = join("",<CFG>);
	close (CFG);
	$batchModeOn = 0 if ($contents =~ m/batch=false/i);
	if ($batchModeOn == 0) {
		logf("'batch' parameter is set to false in ${simConfig}\n",$VERBOSE_);
		$batchMax = 1;
	} elsif ($contents =~ m/batch\.max=([0-9]+)/i) {
		$batchMax = $1;
	} else {
		logf("Cannot initialise the value of batch.max from ${simConfig}. Defaulting to 500\n",$WARNING_);
	}

	open(TMPFILE,'<',$templateCsv) || fail("Cannot open csv template file ${templateCsv}\n");
	@origlines = <TMPFILE>;
	close(TMPFILE);
	for (my $i=0; $i<@origlines; $i++) {
		for (my $j=0; $j<$repeatCount; $j++) {
			push(@lines,$origlines[$i]);
		}
	}
	$templateLines = $origTemplateLines = @lines;
	$recordsLen = ($templateLines >= $batchMax ? $templateLines : $batchMax);
	
	while (@eventRecords < $recordsLen) {
		foreach $line (@lines) {
			my @tokens = split(',',$line);
			if (@tokens != 3) {
				logf("Error parsing line: $line...skipping\n",$ERROR_);
			} else {
				my %eventRecord;
				$eventRecord{'id'} = $tokens[0];	
				($eventRecord{'normStart'},$eventRecord{'normEnd'}) = split('-',$tokens[1]);
				($eventRecord{'actionStart'},$eventRecord{'actionEnd'}) = split('-',$tokens[2]);
				push(@eventRecords,\%eventRecord);
			}
		}
	}
	$templateLines = @eventRecords;
	print "Length of template file: " . $templateLines . "\n";
}

# Generate csv file for simulator and copy to simulator input directory
sub genInputFile
{
	my $lastIteration = shift;
	my $eventBuffer="";
	my @savedEventRecords = ();
	my $eventCount = 0;
	my %eventRecord;
	my $measvalue;
	my $eventDate;
	my $eventFileName;
	my $incrementCounter = $origTemplateLines; # Increment all records in the template file in sync
	
	return if $lastIteration && $remEvents == 0;
	@savedEventRecords = @eventRecords;
	
	splice(@eventRecords,$remEvents) if $lastIteration;
	foreach (@eventRecords) {
		%eventRecord = %$_;
		$eventDate = getEventDateTime($baseDate,($incrementCounter==$origTemplateLines ? $timeIncrementInSecs : ($repeatCount>1 ? 1 : 0)));
		$eventCount++;
		$eventBuffer .= $eventRecord{'id'} . ',';
		if ($thresholdExceedCount > 0 && ($eventCount % $thresholdExceedCount == 0)) {
			$measvalue = $eventRecord{'actionStart'} + rand($eventRecord{'actionEnd'} - $eventRecord{'actionStart'}); # generate event that exceeds the threshold
		} else {
			$measvalue = $eventRecord{'normStart'} + rand($eventRecord{'normEnd'} - $eventRecord{'normStart'}); 
		}
		$eventBuffer .= sprintf("%.6f",$measvalue) . "," . $eventDate . "\n";
		$incrementCounter = $origTemplateLines if (--$incrementCounter == 0);
	}
	$eventFileName = getEventFileName($baseDate);
	open (CSV,'>',"${simSavedDir}${eventFileName}") || fail("Cannot open \"${simSavedDir}${eventFileName}\" for writing: $!\n");
	print CSV $eventBuffer;
	close(CSV);	
	cp("${simSavedDir}${eventFileName}", $simInputDir);
	@eventRecords = @savedEventRecords;
}

# Calculate the number of records required to satisfy the requested event rate and phase duration
sub calcPhaseRecordCount
{
	my $simulatorSpec = shift;
	my ($eventRatePerSecond,$durationInSecs) = split('=',$simulatorSpec);
	my $recordsRequiredForPhase = $eventRatePerSecond * $durationInSecs;
	
	logf("Number of records to satisfy the requested rate ${eventRatePerSecond} and duration ${durationInSecs} for this phase: ${recordsRequiredForPhase}\n",$VERBOSE_);
	return ($recordsRequiredForPhase < 1 ? 0 : $recordsRequiredForPhase);
}

# Calculate the value for 'send.interval' to achieve the requested event rate
sub calcPhaseEventInterval
{
	my $eventRatePerSecond = shift;
	my $milliSecondsPerBatch;
	
	$batchMax = $eventRatePerSecond if ($eventRatePerSecond > $batchMax);
	$milliSecondsPerBatch = int(($batchMax*1000)/$eventRatePerSecond); # e.g., 100 events per second, batchMax=500 => 1 batch every 5000 ms
	
	if ($milliSecondsPerBatch < 50) {
		logf("A higher value for batch.max (currently ${batchMax}) would be recommended to achieve the requested event rate ${eventRatePerSecond}\n",$WARNING_);
	}
	logf("Value for send.interval to achieve requested event rate ${eventRatePerSecond} with batch.max=${batchMax}: ${milliSecondsPerBatch}\n", $VERBOSE_);
	return $milliSecondsPerBatch;
}

sub stopSimulator
{
	my $pid=`ps -ef | grep ${simCommandParent} | grep -v grep | awk '{ print \$2 }' | head -n 1`;  
	$pid = trim($pid);
	if ($pid =~ /[0-9]+/) {
		logf("Killing simulator process ${pid}: ${simCommandParent}\n",$VERBOSE_);
		`kill -9 ${pid}`;
	}

	$pid=`ps -ef | grep ${simCommandChild} | grep -v grep | awk '{ print \$2 }' | head -n 1`;  
	$pid = trim($pid);
	if ($pid =~ /[0-9]+/) {
		logf("Killing simulator process ${pid}: ${simCommandChild}\n",$VERBOSE_);
		`kill -9 ${pid}`;
	}
}


sub startSimulator
{
	my $interval = shift;

	open (CFG, '<', $simConfig) || fail("Cannot open configuration file '${simConfig}': $!\n");
	my $contents = join("",<CFG>);
	close (CFG);
	$contents =~ s/send\.interval=([0-9]+)/send\.interval=${interval}/i;
	$contents =~ s/scan\.interval=([0-9]+)/scan\.interval=${interval}/i;
	$contents =~ s/batch\.max=([0-9]+)/batch\.max=${batchMax}/i;
	open (CFG, '>', $simConfig) || fail("Cannot open configuration file '${simConfig}': $!\n");
	print CFG $contents;
	close(CFG);
	chdir($simCommandDir);
	system("./${simCommandParent} > simulator.log &");
}


sub logf
{
	my $msg = shift;
	my $level = shift;

	$level = $INFO_ unless defined($level);

	if ($level == $ERROR_) {
		print "**ERROR** ${msg}";
	} elsif ($level == $WARNING_) { 
		print "WARNING: ${msg}";
	} elsif ($level <= $logLevel) { 
		print $msg;
	}
}


sub fail
{
	my $msg = shift;

	print "=======================================================================\n";
	print $msg;
	print "=======================================================================\n";
	exit(1);
}


sub pause
{
	my $secs = shift;
	my $nl = shift;
	
	for (my $i=0; $i < $secs; $i++) { 
		print ".";
		sleep(1); 
	}
	print "\n" if $nl;
}


# return date time in format: 2012-05-31T00:11:01.234+00:00
sub getEventDateTime
{
	my ($baseDate,$incrementInSecs) = @_;
	
	$baseDate->add('seconds'=>$incrementInSecs);
	return $baseDate->strftime("%Y-%m-%dT%H:%M:%S.00+00:00");
}

sub getEventFileName
{
	my $baseDate = shift;
	
	return $baseDate->strftime("events_%Y-%m-%dT%H-%M-%S");
}


# Left pad single digits with 0
sub zeroPad
{
	my $i = shift;
	return ($i<10 ? "0".$i : $i);
}


sub trim
{
	my $str = shift;
	$str =~ s/^\s+//;
	$str =~ s/\s+$//;
	return $str;
}

sub usage
{
	my $msg = shift;
	
	print $msg if $msg;

	print "\n\n";
	print "Usage: [perl] run_simulator.pl [-h] | -s 'rate1=duration1,rate2=duration2,...' -t threshold_count -i time_increment -d days_in_past -r repeat_count";
	print "\n";
	print "Required parameters:\n";
	print "    -s: comma-separated list of phases as rate=duration pairs, where\n";
	print "        rate is the number of events per second and duration is the time in seconds for the simulator to run at this event rate;\n";
	print "        the requested rate will take the value of batch.max in simulator.properties into account; for example, if the requested rate is 10 per\n";
	print "        second, batch=true and batch.max = 500, the value of send.interval will be set by the script to 50 seconds to achieve the desired event rate;\n";
	print "        use a fraction for the rate parameter if you need a value that is higher than one per second. For example, 0.1 would result in 1 event every\n";
	print "        10 seconds; if your requested rate is low (< 10 per second) it is recommended that you set the value of 'batch' in simulator.properties to false\n";
	print "        to ensure a consistent event flow rate\n";
	print "Optional parameters:\n";
	print "    -t: number of sub-threshold events to generate before generating an event that exceeds the threshold value (0 for none)\n";
	print "    -d: number of days in past from whence to start generating reading times (defaults to 180 days)\n";
	print "    -i: number of seconds to increment the date time for an event after each iteration of the base template events (default 10)\n";
	print "    -p: pause time in seconds between each phase (default 120 seconds)\n";
	print "    -r: number of readings in a row to generate for each measurement id (default 1)\n";
	print "    -l: logging level (0=ERROR,1=WARNING,2=INFO,3=VERBOSE)\n";
	print "    -h: print usage statement\n";
	print " ----------------------------------------------------------------------------------------------------------------------------------\n";
	print "Example 1: ./run_simulator.pl -s 100=1200 -t 1000 -i 10 -d 180\n";
	print "        assuming batch.max in simulator.properties is set to 500, this combination of parameters will generate the following load:\n";
	print "        one load phase is defined, lasting 20 minutes; a requested rate of 100 per second will result in send.interval being set to 5000 ms;\n";
	print "        120,000 records will be input over the 20 minute period, broken down into smaller CSV files and spread evenly over the phase duration;\n";
	print "        a measurement value exceeding the threshold is generated once every 1000 records (-t 1000);\n";
    print "        the first timestamp is generated 180 days in the past (-d 180); each timestamp generated is incremented by 10 seconds (-i 10);\n";
	print "Example 2: ./run_simulator.pl -s 250=1200 -t 1000 -i 10 -d 180\n";
	print "        Assuming batch.max=500, the script will configure send.interval=2000 ms and 300,000 CSV records will be generated in total;\n";
	print "Example 3: ./run_simulator.pl -s 100=1200,250=1200 -t 1000 -i 10 -d 180 -p 60\n";
	print "        This will run the sample loads from Examples 1 and 2 above consecutively, with 60 seconds between each phase.\n";
	print "Example 4: ./run_simulator.pl -s 0.2=60 -t 0 -i 10 -d 180\n";
	print "        Assuming batch.max=1, the script will configure send.interval=5000 ms and 12 CSV records will be generated in total;\n";
}

main();

1;
