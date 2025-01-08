#!/usr/bin/perl

########################################################################
# 
# File   :  generic_csv_writer.pl
# History:  Aug-2013 (mooreof@ie.ibm.com)
# Version:  v.4.1.2017.1
#
########################################################################
#
# Generates custom csv records that can be imported into a database table
# 
#########################################################################

use strict;
use Getopt::Long;
use POSIX qw(strftime); 
use Time::Piece;
use Time::Seconds;
use Cwd;
use Carp;
use File::Copy;

our @cfg = (); # array of parameters loaded from configuration file
our @col_spec = (); # column specification loaded from configuration file
our @required_params = qw(OPTIONS.filename OPTIONS.dest_folder OPTIONS.iterations OPTIONS.records_per_file OPTIONS.secs_between_iterations 
						  OPTIONS.datetime_format OPTIONS.date_format OPTIONS.time_format OPTIONS.quote_string_values OPTIONS.enum_separator
						  OPTIONS.float_format);
our @required_sec = qw(OPTIONS COLUMNS); # required sections in configuration file
our @errorstr = (); # array of error strings

# Map allowed column definition types to corresponding handler
our $add_col = {
		'SEQUENCE' => \&add_sequence_col,
		'INTEGER' => \&add_integer_col,
		'FLOAT' => \&add_float_col,
		'DATETIME' => \&add_datetime_col,
		'DATE' => \&add_date_col,
		'TIME' => \&add_time_col,
		'ENUM' => \&add_enum_col,
		'POINT' => \&add_point_col,
		'LINESTRING' => \&add_linestring_col,
		'MULTILINESTRING' => \&add_mlinestring_col,
		'POLYGON' => \&add_polygon_col,
		'STRNUM' => \&add_strnum_col,
		'STRSEQ' => \&add_strseq_col,
		'PERL' => \&add_perl_col,
		'STRING' => \&add_string_col
};

our $ini;
our $cmd = $0 . ' ' . join(' ',@ARGV); # filename + arguments

our $g_var = {
	'filename' => "ds_input.csv", # path + base file name of input csv file
	'dest_folder' => "", # destination folder, output csv file copied here
	'csv_delimiter' => ",", # delimiter between columns in csv file
	'iteration' => 0, # current iteration
	'iterations' => 1, # number of csv files to generate
	'records_per_file' => 100, # number of records per csv file
	'secs_between_iterations' => 10, # gap in seconds between each csv file generation
	'datetime_format' => "%Y-%m-%d %H:%M:%S.000", # output format for DATETIME type
    'date_format' => "%Y-%m-%d", # output format for DATE type
    'time_format' => "%H:%M:%S.000", # output format for TIME type
    'quote_string_values' => "", # add quotes around string values
    'enum_separator' => ",", # separator between enum values
	'float_format' => "%.6f", # display format for FLOAT type
	'row_count' => 0 # current row count
};
our $curr_filename; # current file name (will be different to 'filename' if %d or %t variables specified)
our $file_handle; # handle to current csv file

# enum/constant may not be supported
our $ERROR_ = 0;
our $WARNING_ = 1;
our $INFO_ = 2;
our $VERBOSE_ = 3;
our $DEBUG_ = 4;
our @logLevels = qw(ERROR WARNING INFO VERBOSE DEBUG);
our $logLevel = $VERBOSE_;

local $| = 1; # autoflush stdout

if ($#ARGV < 1 || $ARGV[0] eq '-h') {
	usage($cmd);
	exit;
}

GetOptions ("i=s" => \$ini,
            "l=n" => \$logLevel) || usage("Invalid command line options");

&read_config($ini);


#-----------------------------------------------------------------------
# read_config($cfg_file_name)
#-----------------------------------------------------------------------
# 
# Read configuration file and verify
#
#-----------------------------------------------------------------------
sub read_config
{
	my $cfg_file_name = shift;
	my $key = "";
	my $line;
	my $sec = "";
	my $value;
	
	fail("No configuration file specified") if (!defined($cfg_file_name) || $cfg_file_name eq '');
	open(CONFIG,'<',$cfg_file_name) || fatal("Can't open ini file \"$cfg_file_name\" (specify full path if file is not in current dir): $!\n");

	#KEY=VALUE
	while (defined($line = <CONFIG>)) {
		if ($line =~ m/^[;\/\s]/) {
			# ignore comment or blank line
		} elsif (substr($line,0,1) eq '[') {
			my $n = index($line,']');
			fatal("Section name missing ']': ${line}\n") if $n == -1;
			$sec = substr($line,1,$n-1);
		} elsif ($line =~ m/(.+?)=(.+?)[\r\n]/) { 
			$key = $1;
			$value = trim($2);
			push(@cfg,{'key'=>$sec.'.'.$key,'value'=>$value});
		} else {
			fatal("Cannot parse line in config file: ${line}\n");
		}
	}
	close(CONFIG);

	verify_required_config();
}


#-----------------------------------------------------------------------
# verify_required_config()
#-----------------------------------------------------------------------
# 
# Make sure all required sections and required parameters have been 
# specified in the configuration file
#
#-----------------------------------------------------------------------
sub verify_required_config
{
	my %config = map { $_->{'key'} => $_->{'value'} } @cfg; # convert config array to hash for easier checking
	my %p;
	my @arr;
	my $sec;
	my $n;

	foreach (keys %config) { $p{$_}++; }
	@arr = grep(!$p{$_}, @required_params);
	push(@errorstr, "Missing required options(s) in configuration file: (" . join(',',@arr) . "). Using default values.") if @arr;

	@arr = ();	
	foreach my $key (keys %config) {
		$n = index($key,'.');
		if ($n != -1) {
			$sec = substr($key,0,$n);
			$p{$sec}++;
		}
	}
	@arr = grep(!$p{$_}, @required_sec);
	fatal("Missing required section(s) in configuration file: (" . join(',',@arr) . ")\n") if @arr;
}


#-----------------------------------------------------------------------
# main([)
#-----------------------------------------------------------------------
# 
# Main routine
#
#-----------------------------------------------------------------------
sub main
{
	my $now = strftime("%a %b %d %H:%M:%S %Y",localtime); 

	$logLevel = $VERBOSE_ if ($logLevel < $ERROR_ || $logLevel > $DEBUG_);
	print ">> LOGLEVEL=@{[$logLevels[$logLevel]]}\n";
	logf(">> START -> $now\n\n", $INFO_);

	init();
	
	for ($g_var->{'iteration'}=1; $g_var->{'iteration'}<=$g_var->{'iterations'}; $g_var->{'iteration'}++) {
		logf("ITERATION: " . $g_var->{'iteration'} . " (" . strftime("%H:%M:%S",localtime) . ")\n", $INFO_);
		my ($start_time,$end_time);
		$start_time = time();
		open_output_file();
		write_records();
		close_output_file();
		copy_csv_to_destination();
		$end_time = time();
		logf("TIME: @{[$end_time-$start_time]} seconds\n",$DEBUG_);
		last if $g_var->{'iteration'}==$g_var->{'iterations'};
		while ($end_time-$start_time < $g_var->{'secs_between_iterations'}) {
			pause(1);
			$end_time = time();
		}
		print "\n\n";
	}
	
	$now = strftime("%a %b %d %H:%M:%S %Y",localtime);
	logf("\n>> END -> $now\n\n", $INFO_);
	
	# dump any non-fatal errors
	logf("\n\nErrors occurred:\n\n" . join("\n",@errorstr) . "\n", $ERROR_) if (@errorstr);
}


#-----------------------------------------------------------------------
# init()
#-----------------------------------------------------------------------
# 
# Initialise global variables using values from configuration file
#
#-----------------------------------------------------------------------
sub init
{
	my $key = "";
	my $value;
	my $str = "";
	
	for (my $i=0; $i<@cfg; $i++) {
		if (index($cfg[$i]->{'key'},'COLUMNS.') != -1) {
			my $colname = substr($cfg[$i]->{'key'},8);
			$value = $cfg[$i]->{'value'};
			my ($datatype,$param) = (split(/;/,$value))[0,1];
			if (defined($param) && !defined($add_col->{$datatype})) {
				push(@errorstr,"Undefined datatype \"$datatype\" in configuration");
			} else {
				$datatype = "STRING" if !defined($param);
				push(@col_spec,&{$add_col->{$datatype}}($colname,$value));
			}
		} elsif (index($cfg[$i]->{'key'},'OPTIONS.') != -1) {
			my $option = substr($cfg[$i]->{'key'},8);
			$value = $cfg[$i]->{'value'};
			if (!defined($g_var->{$option})) {
				push(@errorstr,"Invalid option ${option} in [OPTIONS] section");
			} else {
				$value = ($value == 1 ? "\"" : "") if ($option eq 'quote_string_values');
				$g_var->{$option} = $value;
			}
		} else {
			push(@errorstr,"Invalid key in configuration file: " . $cfg[$i]->{'key'});
		}
	}
}


#-----------------------------------------------------------------------
# write_records()
#-----------------------------------------------------------------------
# 
# Write all records to current file
#
#-----------------------------------------------------------------------
sub write_records
{
	write_header_record();
	for (my $i=1; $i<=$g_var->{'records_per_file'}; $i++) {
		$g_var->{'row_count'}++;
		write_record($i);
	}
}

#-----------------------------------------------------------------------
# write_header_record()
#-----------------------------------------------------------------------
# 
# Write header record (column names) to current file
#
#-----------------------------------------------------------------------
sub write_header_record
{
	my $num_cols = @col_spec;
	my $line="";
	
	for (my $i=0; $i<$num_cols; $i++) {
		$line .= $col_spec[$i]->{'name'};
		$line .= $g_var->{'csv_delimiter'} if $i < $num_cols-1;
	}
	print $file_handle "${line}\n";
}

#-----------------------------------------------------------------------
# write_record()
#-----------------------------------------------------------------------
# 
# Write record to current file
#
#-----------------------------------------------------------------------
sub write_record
{
	my $row_num = shift;
	my $num_cols = @col_spec;
	my $line="";
	my $value="";
	
	for (my $i=0; $i<$num_cols; $i++) {
		$value = &{$col_spec[$i]->{'get_next'}}($col_spec[$i]);
		$line .= $value;
		$line .= $g_var->{'csv_delimiter'} if $i < $num_cols-1;
	}
	print $file_handle "${line}\n";
}


#-----------------------------------------------------------------------
# get_current_value($colnum)
#-----------------------------------------------------------------------
# 
# Return the current value for the specified column
# $colnum=column number
#
#-----------------------------------------------------------------------
sub get_current_value
{
	my $colnum = shift;
	if (!defined($colnum) || $colnum < 1 || $colnum > @col_spec) {
		push(@errorstr, "Warning: Invalid column number ${colnum}. Resetting to a value of 1");
		$colnum = 1;
	}
	return $col_spec[$colnum-1]->{'current_value'};
}

#-----------------------------------------------------------------------
# get_column_type($colnum)
#-----------------------------------------------------------------------
# 
# Return the data type for the specified column
# $colnum=column number
#
#-----------------------------------------------------------------------
sub get_column_type
{
	my $colnum = shift;
	if (!defined($colnum) || $colnum < 1 || $colnum > @col_spec) {
		push(@errorstr, "Warning: Invalid column number ${colnum}. Resetting to a value of 1");
		$colnum = 1;
	}
	return $col_spec[$colnum-1]->{'type'};
}


#-----------------------------------------------------------------------
# get_property_value($colnum,$propertyname)
#-----------------------------------------------------------------------
# 
# Return the value of the specified property for the specified column
# $colnum=column number
# $propertyname=name of property
#
#-----------------------------------------------------------------------
sub get_property_value
{
	my $colnum = shift;
	my $propertyname = shift;
	if (!defined($colnum) || $colnum < 1 || $colnum > @col_spec) {
		push(@errorstr, "Warning: Invalid column number ${colnum}. Resetting to a value of 1");
		$colnum = 1;
	}
	push(@errorstr, "Property ${propertyname} is undefined for column number ${colnum}") if !defined($col_spec[$colnum-1]->{$propertyname});
	return $col_spec[$colnum-1]->{$propertyname};
}


#-----------------------------------------------------------------------
# add_sequence_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type SEQUENCE
# $colname=name of column
# $colspec=specification for column:
# COLNAME=SEQUENCE;SEQUENCE_START;INCREMENT;ZEROPAD;RESTART
#
#-----------------------------------------------------------------------
sub add_sequence_col
{
	my $colname = shift;
	my $colspec = shift;
	
	my ($type,$start_val,$increment,$zeropad,$restart) = split(/;/,$colspec);
	fatal("Invalid SEQUENCE specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($start_val) || !defined($increment));
	$zeropad = 0 if !defined($zeropad);
	$restart = 0 if !defined($restart);

	return { 'type' => 'SEQUENCE', 
			 'name' => $colname, 
			 'get_next' => \&get_sequence_col_value, 
			 'seq_start' => $start_val, 
			 'seq_value' => $start_val,
			 'current_value' => $start_val, 
			 'increment' => $increment, 
			 'zero_pad' => $zeropad, 
			 'restart' => $restart, 
			 'restart_i' => 0 };
}

sub get_sequence_col_value
{
	my $col_details = shift;
	my $cur_val;
	my $zeropad = $col_details->{'zero_pad'};
	
	if ($col_details->{'restart'} && ++$col_details->{'restart_i'} > $col_details->{'restart'}) {
		$col_details->{'restart_i'} = 1;
		$col_details->{'seq_value'} = $col_details->{'seq_start'}-1;
	}
	$cur_val = $col_details->{'seq_value'};
	$cur_val += $col_details->{'increment'} unless $g_var->{'row_count'} == 1;
	$col_details->{'seq_value'} = $cur_val; # store value without zero padding in 'seq_value'
	$col_details->{'current_value'} = sprintf("%0${zeropad}d",$cur_val); # Store zero-padded value in 'current_value'

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_integer_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type INTEGER
# $colname=name of column
# $colspec=specification for column:
# COLNAME=INTEGER;RANGE_START;RANGE_END (random integer between RANGE_START
# and RANGE_END)
#
#-----------------------------------------------------------------------
sub add_integer_col
{
	my $colname = shift;
	my $colspec = shift;
	
	my ($type,$range_start,$range_end) = split(/;/,$colspec);
	fatal("Invalid INTEGER specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($range_start) || !defined($range_end));

	return { 'type' => 'INTEGER', 
			 'name' => $colname, 
			 'get_next' => \&get_integer_col_value, 
			 'current_value' => 0, 
			 'range_start' => $range_start, 
			 'range_end' => $range_end };
}

sub get_integer_col_value
{
	my $col_details = shift;
	my $range = $col_details->{'range_end'} - $col_details->{'range_start'};
	$col_details->{'current_value'} = $col_details->{'range_start'} + int(rand($range));
	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_float_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type FLOAT
# $colname=name of column
# $colspec=specification for column:
# COLNAME=FLOAT;RANGE_START;RANGE_END (random float between RANGE_START
# and RANGE_END)
#
#-----------------------------------------------------------------------
sub add_float_col
{
	my $colname = shift;
	my $colspec = shift;
	
	#VOLUME=FLOAT;10.0;20.0
	my ($type,$range_start,$range_end) = split(/;/,$colspec);
	fatal("Invalid FLOAT specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($range_start) || !defined($range_end));

	return { 'type' => 'FLOAT', 
			 'name' => $colname, 
			 'get_next' => \&get_float_col_value, 
			 'current_value' => 0, 
			 'range_start' => $range_start, 
			 'range_end' => $range_end };
}

sub get_float_col_value
{
	my $col_details = shift;
	my $range = $col_details->{'range_end'} - $col_details->{'range_start'};

	$col_details->{'current_value'} = sprintf($g_var->{'float_format'},$col_details->{'range_start'} + rand($range));

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_datetime_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type DATETIME
# $colname=name of column
# $colspec=specification for column:
# COLNAME=DATETIME;START DATETIME;INCREMENT IN SECONDS
# START DATETIME format: mm/dd/yyyy HH:MM:SS
#
#-----------------------------------------------------------------------
sub add_datetime_col
{
	my $colname = shift;
	my $colspec = shift;
	my ($type,$start_date,$increment) = split(/;/,$colspec);

	fatal("Invalid DATETIME specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($start_date) || !defined($increment));
	my ($date,$time) = split(/\s+/,$start_date);
	my ($month,$day,$year) = split(/\//,$date);
	my ($hour,$min,$sec) = split(/:/,$time);
	fatal("Invalid DATETIME specification: ${colname}=${colspec}\n")
		if (!defined($month) || !defined($day) || !defined($year) || !defined($hour) || !defined($min) || !defined($sec));

	$start_date = Time::Piece->strptime($month.'-'.$day.'-'.$year.' '.$hour.':'.$min.':'.$sec,'%m-%d-%Y %H:%M:%S');

	return { 'type' => 'DATETIME', 
			 'name' => $colname, 
			 'get_next' => \&get_datetime_col_value, 
			 'base_date' => $start_date, 
			 'current_value' => $start_date, 
			 'increment' => $increment };
}

sub get_datetime_col_value
{
	my $col_details = shift;
	my $curr_date = $col_details->{'base_date'};
	
	$curr_date = addUnitsToTime($curr_date,'seconds',$col_details->{'increment'}) unless $g_var->{'row_count'} == 1;
	$col_details->{'base_date'} = $curr_date;
	$col_details->{'current_value'} = $curr_date->strftime($g_var->{'datetime_format'});

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_date_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type DATE
# $colname=name of column
# $colspec=specification for column:
# COLNAME=DATE;START DATE;INCREMENT IN DAYS
# START DATE format: mm/dd/yyyy
#
#-----------------------------------------------------------------------
sub add_date_col
{
	my $colname = shift;
	my $colspec = shift;
	my ($type,$start_date,$increment) = split(/;/,$colspec);

	fatal("Invalid DATE specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($start_date) || !defined($increment));
	my ($month,$day,$year) = split(/\//,$start_date);
	fatal("Invalid DATE specification: ${colname}=${colspec}\n") if (!defined($month) || !defined($day) || !defined($year));

	my $start_date = Time::Piece->strptime($month.'-'.$day.'-'.$year, '%m-%d-%Y');

	return { 'type' => 'DATE', 
			 'name' => $colname, 
			 'get_next' => \&get_date_col_value, 
			 'base_date' => $start_date, 
			 'current_value' => $start_date, 
			 'increment' => $increment };
}

sub get_date_col_value
{
	my $col_details = shift;
	my $curr_date = $col_details->{'base_date'};
	
	$curr_date = addUnitsToTime($curr_date,'days',$col_details->{'increment'}) unless $g_var->{'row_count'} == 1;
	$col_details->{'base_date'} = $curr_date;
	$col_details->{'current_value'} = $curr_date->strftime($g_var->{'date_format'});

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_time_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type TIME
# $colname=name of column
# $colspec=specification for column:
# COLNAME=TIME;START TIME;INCREMENT IN SECONDS
# START TIME format: HH:MM:SS
#
#-----------------------------------------------------------------------
sub add_time_col
{
	my $colname = shift;
	my $colspec = shift;	
	my ($type,$start_time,$increment) = split(/;/,$colspec);

	fatal("Invalid TIME specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($start_time) || !defined($increment));
	my ($hour,$min,$sec) = split(/:/,$start_time);
	fatal("Invalid TIME specification: ${colname}=${colspec}\n") if (!defined($hour) || !defined($min) || !defined($sec));

	$start_time = Time::Piece->strptime('1-1-2013 '.$hour.':'.$min.':'.$sec, '%m-%d-%Y %H:%M:%S');

	return { 'type' => 'TIME', 
			 'name' => $colname, 
			 'get_next' => \&get_time_col_value, 
			 'base_value' => $start_time, 
			 'current_value' => $start_time, 
			 'increment' => $increment };
}

sub get_time_col_value
{
	my $col_details = shift;
	my $curr_time = $col_details->{'base_value'};
	
	$curr_time = addUnitsToTime($curr_time,'seconds',$col_details->{'increment'}) unless $g_var->{'row_count'} == 1;
	$col_details->{'base_value'} = $curr_time;
	$col_details->{'current_value'} = $curr_time->strftime($g_var->{'time_format'});

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_enum_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type ENUM
# $colname=name of column
# $colspec=specification for column:
# COLNAME=ENUM;List of comma-separated values
#
#-----------------------------------------------------------------------
sub add_enum_col
{
	my $colname = shift;
	my $colspec = shift;
	my $enum_sep = $g_var->{'enum_separator'};
	my ($type,$values) = split(/;/,$colspec);

	fatal("Invalid ENUM specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($values));
	my @arr = split(/${enum_sep}/,$values);

	return { 'type' => 'ENUM', 
			 'name' => $colname, 
			 'get_next' => \&get_enum_col_value, 
			 'current_value' => $arr[0], 
			 'values' => \@arr };
}

sub get_enum_col_value
{
	my $col_details = shift;
	my $n = @{$col_details->{'values'}};
	my $rand = int(rand($n));

	$col_details->{'current_value'} = @{$col_details->{'values'}}[$rand];

	return $g_var->{'quote_string_values'} . $col_details->{'current_value'} . $g_var->{'quote_string_values'};
}

#-----------------------------------------------------------------------
# add_point_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type POINT
# $colname=name of column
# $colspec=specification for column:
# COLNAME=POINT;base latitude;delta latitude;base longitude;delta longitude
#
#-----------------------------------------------------------------------
sub add_point_col
{
	my $colname = shift;
	my $colspec = shift;
	
	#LOCATION=POINT;44;1;-93;1
	my ($type,$base_lat,$delta_lat,$base_long,$delta_long) = split(/;/,$colspec);
	fatal("Invalid POINT specification: ${colname}=${colspec}\n")
		if (!defined($type) || !defined($base_lat) || !defined($delta_lat) || !defined($base_long) || !defined($delta_long));

	return { 'type' => 'POINT', 
			 'name' => $colname, 
			 'get_next' => \&get_point_col_value, 
			 'current_value' => '',
			 'base_lat' => $base_lat, 
			 'delta_lat' => $delta_lat, 
			 'base_long' => $base_long, 
			 'delta_long' => $delta_long };
}

sub get_point_col_value
{
	my $col_details = shift;
	my $lat = $col_details->{'base_lat'} + rand($col_details->{'delta_lat'});
	my $long = $col_details->{'base_long'} + rand($col_details->{'delta_long'});

	$col_details->{'current_value'} = sprintf("POINT(%.6f %.6f)",$long,$lat);

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_linestring_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type LINESTRING...list of multiple points
# $colname=name of column
# $colspec=specification for column:
# COLNAME=LINESTRING;BASE LATITUDE,DELTA LATITUDE,BASE LONGITUDE,
#         DELTA LONGITUDE;LENGTH MIN,LENGTH MAX;NUMBER OF POINTS
#
#-----------------------------------------------------------------------
sub add_linestring_col
{
	my $colname = shift;
	my $colspec = shift;
	
	#LOCATION=LINESTRING;44,0.5,-93,0.5;0.0001;3
	my ($type,$base_point,$delta_length,$num_points) = split(/;/,$colspec);
	fatal("Invalid LINESTRING specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($base_point) || !defined($delta_length) || !defined($num_points));
	my ($lat,$delta_lat,$long,$delta_long) = split(/,/,$base_point);
	fatal("Invalid LINESTRING specification: ${colname}=${colspec}\n") if (!defined($lat) || !defined($delta_lat) || !defined($long) || !defined($delta_long));

	return { 'type' => 'LINESTRING', 
			 'name' => $colname, 
			 'get_next' => \&get_linestring_col_value, 
			 'current_value' => '',
			 'base_lat' => $lat, 
			 'delta_lat' => $delta_lat, 
			 'base_long' => $long, 
			 'delta_long' => $delta_long, 
			 'delta_length' => $delta_length, 
			 'num_points' => $num_points };
}


sub get_linestring_col_value
{
	my $col_details = shift;
	my $pairs = get_point_pairs($col_details,0);

	$col_details->{'current_value'} = sprintf("LINESTRING(%s)",$pairs);

	return "\"" . $col_details->{'current_value'} . "\"";
}


#-----------------------------------------------------------------------
# add_mlinestring_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type MULTILINESTRING...list of multiple points
# $colname=name of column
# $colspec=specification for column:
# COLNAME=MULTILINESTRING;;LAT1,LONG1,DELTA1;...
#
#-----------------------------------------------------------------------
sub add_mlinestring_col
{
	my $colname = shift;
	my $colspec = shift;
	
	#LOCATION=MULTILINESTRING;44,0.5,-93,0.5;0.0001;3
	my ($type,$base_point,$delta_length,$num_points) = split(/;/,$colspec);
	fatal("Invalid MULTILINESTRING specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($base_point) || !defined($delta_length) || !defined($num_points));
	my ($lat,$delta_lat,$long,$delta_long) = split(/,/,$base_point);
	fatal("Invalid MULTILINESTRING specification: ${colname}=${colspec}\n") if (!defined($lat) || !defined($delta_lat) || !defined($long) || !defined($delta_long));

	return { 'type' => 'MULTILINESTRING', 
			 'name' => $colname, 
			 'get_next' => \&get_mlinestring_col_value, 
			 'current_value' => '',
			 'base_lat' => $lat, 
			 'delta_lat' => $delta_lat, 
			 'base_long' => $long, 
			 'delta_long' => $delta_long, 
			 'delta_length' => $delta_length, 
			 'num_points' => $num_points };
}


sub get_mlinestring_col_value
{
	my $col_details = shift;
	my $pairs = get_point_pairs($col_details,0);

	$col_details->{'current_value'} = sprintf("MULTILINESTRING((%s))",$pairs);

	return "\"" . $col_details->{'current_value'} . "\"";
}

#-----------------------------------------------------------------------
# add_polygon_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type POLYGON...closed group of multiple points
# $colname=name of column
# $colspec=specification for column:
# COLNAME=POLYGON;;LAT1,LONG1,DELTA1;...
#
#-----------------------------------------------------------------------
sub add_polygon_col
{
	my $colname = shift;
	my $colspec = shift;
	#LOCATION=POLYGON;44,0.5,-93,0.5;0.0001;3
	my ($type,$base_point,$delta_length,$num_points) = split(/;/,$colspec);

	fatal("Invalid POLYGON specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($base_point) || !defined($delta_length) || !defined($num_points));
	fatal("Currently only three points are supported for polygons: ${colname}=${colspec}\n") if $num_points != 3;
	my ($lat,$delta_lat,$long,$delta_long) = split(/,/,$base_point);
	fatal("Invalid POLYGON specification: ${colname}=${colspec}\n") if (!defined($lat) || !defined($delta_lat) || !defined($long) || !defined($delta_long));

	return { 'type' => 'POLYGON', 
			 'name' => $colname, 
			 'get_next' => \&get_polygon_col_value, 
			 'current_value' => '',
			 'base_lat' => $lat, 
			 'delta_lat' => $delta_lat, 
			 'base_long' => $long, 
			 'delta_long' => $delta_long, 
			 'delta_length' => $delta_length, 
			 'num_points' => $num_points };
}


sub get_polygon_col_value
{
	my $col_details = shift;
	my $pairs = get_point_pairs($col_details,1);

	$col_details->{'current_value'} = sprintf("POLYGON((%s))",$pairs);

	return "\"" . $col_details->{'current_value'} . "\"";
}


#-----------------------------------------------------------------------
# get_point_pairs($point_details,$polygon)
#-----------------------------------------------------------------------
# 
# Return a list of comma-separated long/lat pairs 
# $points=string specification for points:
#  BASE LATITUDE,DELTA LATITUDE,BASE LONGITUDE,DELTA LONGITUDE;
#    DELTA_LENGTH;NUMBER OF POINTS
# $polygon=true if a polygon shape (first point is repeated)
#
#-----------------------------------------------------------------------
sub get_point_pairs
{
	my $col_details = shift;
	my $polygon = shift;
	my $num_points = $col_details->{'num_points'};
	my $base_lat = $col_details->{'base_lat'} + rand($col_details->{'delta_lat'});
	my $base_long = $col_details->{'base_long'} + rand($col_details->{'delta_long'});
	my $pairs = sprintf("%.6f %.6f, ", $base_long, $base_lat);
	my ($lat,$long);

	
	for (my $i=1; $i<$num_points; $i++) {
		$lat = $base_lat + rand($col_details->{'delta_length'});
		$long = $base_long + rand($col_details->{'delta_length'});
		$pairs .= sprintf("%.6f %.6f, ", $long, $lat);
	}
	$pairs .= sprintf("%.6f %.6f, ", $base_long, $base_lat) if $polygon;

	return substr($pairs,0,-2);
}

#-----------------------------------------------------------------------
# add_strnum_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type STRNUM. Consists of a combination of
# characters and 0 or more random numbers marked by %r
# $colname=name of column
# $colspec=specification for column:
# COLNAME=STRNUM;BASE_VALUE;RANGE_START;RANGE_END (random integer between
# RANGE_START and RANGE_END)
#
#-----------------------------------------------------------------------
sub add_strnum_col
{
	my $colname = shift;
	my $colspec = shift;
	
	my ($type,$base_value,$range_start,$range_end) = split(/;/,$colspec);
	fatal("Invalid INTEGER specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($base_value) || !defined($range_start) || !defined($range_end));

	return { 'type' => 'INTEGER', 
			 'name' => $colname, 
			 'get_next' => \&get_strnum_col_value, 
			 'base_value' => $base_value, 
			 'current_value' => $base_value,
			 'range_start' => $range_start, 
			 'range_end' => $range_end };
}

sub get_strnum_col_value
{
	my $col_details = shift;
	my $rand;
	my $value = $col_details->{'base_value'};
	my $range = $col_details->{'range_end'} - $col_details->{'range_start'};

	while ($value =~ m/%r/) { # replace each instance of %r with a random number in the specified range
		$rand = int(rand($range));
		$value =~ s/%r/${rand}/;
	}
	$col_details->{'current_value'} = $value;

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_strseq_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type STRSEQ. Consists of a combination of
# characters and 0 or more (zero-padded) sequence numbers marked by %s
# $colname=name of column
# $colspec=specification for column:
# COLNAME=STRSEQ;BASE_VALUE;START_VALUE;INCREMENT;ZEROPAD;RESTART
#
#-----------------------------------------------------------------------
sub add_strseq_col
{
	my $colname = shift;
	my $colspec = shift;
	my $zeropad;
	my ($type,$base_value,$start_value,$increment,$zeropad,$restart) = split(/;/,$colspec);

	fatal("Invalid STRSEQ specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($base_value) || !defined($start_value) || !defined($increment));
	$zeropad = 0 if !defined($zeropad);
	$restart = 0 if !defined($restart);

	return { 'type' => 'STRSEQ', 
			 'name' => $colname, 
			 'get_next' => \&get_strseq_col_value, 
			 'base_value' => $base_value, 
			 'seq_start' => $start_value,
			 'seq_value' => $start_value, 
			 'current_value' => $base_value, 
			 'increment' => $increment, 
			 'zero_pad' => $zeropad, 
			 'restart' => $restart, 
			 'restart_i' => 0  };
}

sub get_strseq_col_value
{
	my $col_details = shift;
	my $base_value = $col_details->{'base_value'};
	my $cur_seq_val;
	my $padded_val = "";
	my $zeropad = $col_details->{'zero_pad'};

	if ($col_details->{'restart'} && ++$col_details->{'restart_i'} > $col_details->{'restart'}) {
		$col_details->{'restart_i'} = 1;
		$col_details->{'seq_value'} = $col_details->{'seq_start'}-1;
	}
	$cur_seq_val = $col_details->{'seq_value'};
	$cur_seq_val += $col_details->{'increment'} unless $g_var->{'row_count'} == 1;
	$col_details->{'seq_value'} = $cur_seq_val;
	$padded_val = sprintf("%0${zeropad}d", $cur_seq_val);
	$base_value =~ s/%s/${padded_val}/g;
	$col_details->{'current_value'} = $base_value;

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_string_col($colname,$value)
#-----------------------------------------------------------------------
# 
# Add column specification of type STRING
# $colname=name of column
# $value=value for column name:
# COLNAME=VALUE
#
#-----------------------------------------------------------------------
sub add_string_col
{
	my $colname = shift;
	my $value = shift;

	fatal("Invalid STRING specification: ${colname}=${value}\n") if (!defined($value));

	return { 'type' => 'STRING', 
			 'name' => $colname, 
			 'get_next' => \&get_string_col_value, 
			 'current_value' => $value };
}

sub get_string_col_value
{
	my $col_details = shift;

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
# add_perl_col($colname,$colspec)
#-----------------------------------------------------------------------
# 
# Add column specification of type PERL
# $colname=name of column
# $colspec=specification for column:
# COLNAME=PERL;FUNCTION NAME;args(comma-separated)
#
#-----------------------------------------------------------------------
sub add_perl_col
{
	my $colname = shift;
	my $colspec = shift;
	my @args = ();
	my ($type,$func_name,$args) = split(/;/,$colspec);

	fatal("Invalid PERL specification: ${colname}=${colspec}\n") if (!defined($type) || !defined($func_name));
	@args = split(/,/,$args) if defined($args);
	
	return { 'type' => 'PERL', 
			 'name' => $colname, 
			 'get_next' => \&{$func_name}, 
			 'args' => \@args, 
			 'current_value' => 0 };
}


#-----------------------------------------------------------------------
#
# START CUSTOM PERL EXTENSIONS
#
# Default Arguments to all custom perl extensions:
# $coldetails=hash reference with the following minimum properties:
#	'type' => 'PERL'
#   'name' => Column name
#	'get_next' => reference to this function
#   'current_value' => current value
#   'args' => reference to array of parameters passed to the function
#
# Access global properties such as the current iteration, current row
# count, etc., using the g_var hash.
# e.g., $g_var->{'row_count'}, $g_var->{'iteration'}
#
#-----------------------------------------------------------------------

#-----------------------------------------------------------------------
#
# An example of a custom perl function that combines the current values
# of two columns
# Parameters expected: first and second column numbers
#
#-----------------------------------------------------------------------
sub get_permit_name
{
	my $col_details = shift;
	my @args = @{$col_details->{'args'}};
	my ($first_col,$second_col) = (1,2);

	$first_col = $args[0] if defined($args[0]);
	$second_col = $args[1] if defined($args[1]);
	# set value to current value of column x and current value of column y, save in 'current_value' property
	$col_details->{'current_value'} = get_current_value($second_col) . "_" . get_current_value($first_col);

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
#
# An example of a custom perl function that returns the current datetime
# minus x 'units of time' (seconds, minutes, hours, days, months, years)
#
#-----------------------------------------------------------------------
sub currentTime_minus_x
{
	my $col_details = shift;
	my ($count,$units) = @{$col_details->{'args'}};
	my $time = localtime();
	
	$time = subtractUnitsFromTime($time,$units,$count);
	$col_details->{'current_value'} = $time->strftime("%Y-%m-%d %H:%M:%S");

	return $col_details->{'current_value'};
}


#-----------------------------------------------------------------------
#
# An example of a custom perl function that returns the current datetime
#
#-----------------------------------------------------------------------
sub now 
{
	my $col_details = shift;
	my $now = localtime();

	$col_details->{'current_value'} = $now->strftime("%Y-%m-%d %H:%M:%S");

	return $col_details->{'current_value'};
}


#-----------------------------------------------------------------------
#
# An example of a custom perl function that generates a POINT that
# tracks from left to right within a bounding box
# The following parameters are expected:
# base_lat, delta_lat, base_long, delta_long, max_delta_lat, max_delta_lon
#
#-----------------------------------------------------------------------
our $event_loc = {
	'base_lat' => 44,
	'delta_lat' => 0.01,
	'base_lon' => -93,
	'delta_lon' => 0.01,
	'max_delta_lat' => 0.1,
	'max_delta_lon' => 0.1,
	'curr_lat' => 44,
	'curr_lon' => -93
};

sub set_event_loc
{
	my $col_details = shift;
	my @args = @{$col_details->{'args'}};
	
	if ($g_var->{'row_count'} == 1) { # Initialise if on the first record
		$event_loc->{'base_lat'} = $args[0] if defined($args[0]);
		$event_loc->{'delta_lat'} = $args[1] if defined($args[1]);
		$event_loc->{'base_lon'} = $args[2] if defined($args[2]);
		$event_loc->{'delta_lon'} = $args[3] if defined($args[3]);
		$event_loc->{'max_delta_lat'} = $args[4] if defined($args[4]);
		$event_loc->{'max_delta_lon'} = $args[5] if defined($args[5]);
		$event_loc->{'curr_lat'} = $event_loc->{'base_lat'};
		$event_loc->{'curr_lon'} = $event_loc->{'base_lon'};
	}

	$event_loc->{'curr_lon'} += $event_loc->{'delta_lon'} unless $g_var->{'row_count'} == 1;
	if ($event_loc->{'curr_lon'} - $event_loc->{'base_lon'} > $event_loc->{'max_delta_lon'}) {
		$event_loc->{'curr_lon'} = $event_loc->{'base_lon'};
		$event_loc->{'curr_lat'} += $event_loc->{'delta_lat'};
	}
	$col_details->{'current_value'} = sprintf("POINT(%.6f %.6f)",$event_loc->{'curr_lon'},$event_loc->{'curr_lat'});

	return $col_details->{'current_value'};
}

# Custom function to generate timestamps for traffic sensor data
# Arguments: days in past (used to initialise the base date)
#            sensor count (we use same timestamp for this number of records, then increment)
#            increment (seconds to increment base date for the 'sensor count' batch of sensors)
our $traffic_sensor_base_time = localtime();

sub traffic_sensor_time
{
	my $col_details = shift;
	my ($days_in_past,$sensor_count,$increment) = @{$col_details->{'args'}};
	my $time = localtime();
	
	if ($g_var->{'row_count'} == 1) { # Initialise if on the first record
		$traffic_sensor_base_time = subtractUnitsFromTime($traffic_sensor_base_time,'days',$days_in_past);
	}
	if ($g_var->{'row_count'} % $sensor_count == 0) {
		$traffic_sensor_base_time = addUnitsToTime($traffic_sensor_base_time,'seconds',$increment);
	}
	$col_details->{'current_value'} = $traffic_sensor_base_time->strftime("%Y-%m-%d %H:%M:%S");

	return $col_details->{'current_value'};
}

#-----------------------------------------------------------------------
#
# END CUSTOM PERL EXTENSIONS
#
#-----------------------------------------------------------------------

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
	my $delta;

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


#-----------------------------------------------------------------------
# open_output_file()
#-----------------------------------------------------------------------
# 
# Open output csv file for writing meter reading records, return handle
#
#-----------------------------------------------------------------------
sub open_output_file
{
	my $iteration = $g_var->{'iteration'};
	my $now = strftime("%d-%m-%YT%H.%M.%S",localtime); 

	$curr_filename = $g_var->{'filename'};
	$curr_filename =~ s/%d/${iteration}/g;
	$curr_filename =~ s/%t/${now}/g;
	logf("Opening \"${curr_filename}\" for writing\n",$VERBOSE_);
	open ($file_handle,'>',"${curr_filename}") || fail("Cannot open \"${curr_filename}\" for writing: $!");

	return $file_handle;
}


#-----------------------------------------------------------------------
# close_output_file()
#-----------------------------------------------------------------------
# 
# Close output file
#
#-----------------------------------------------------------------------
sub close_output_file
{
	logf("Closing \"${curr_filename}\"\n",$VERBOSE_);
	close($file_handle);
}

#-----------------------------------------------------------------------
# copy_csv_to_destination()
#-----------------------------------------------------------------------
# 
# Copy generated csv file to output folder, if one is defined
#
#-----------------------------------------------------------------------
sub copy_csv_to_destination
{
	File::Copy::cp($curr_filename,$g_var->{'dest_folder'}) if ($g_var->{'dest_folder'} ne '');
}

#-----------------------------------------------------------------------
# logf($msg,$level)
#-----------------------------------------------------------------------
# 
# Format message if $level is less than or equal to global log level
#
#-----------------------------------------------------------------------
sub logf
{
	my $msg = shift;
	my $level = shift;

	$level = $INFO_ unless defined($level);

	if ($level == $ERROR_) {
		print "**** ${msg}";
	} elsif ($level == $WARNING_) { 
		print "WARNING: ${msg}";
	} elsif ($level <= $logLevel) { 
		print $msg;
	}
}


#-----------------------------------------------------------------------
# fatal($msg)
#-----------------------------------------------------------------------
# 
# Print message and exit program
#
#-----------------------------------------------------------------------
sub fatal
{
	my $msg = shift;

	print "=======================================================================\n";
	print $msg;
	print "=======================================================================\n";

	exit(1);
}


#-----------------------------------------------------------------------
# pause($secs)
#-----------------------------------------------------------------------
# 
# Pause for specified seconds
#
#-----------------------------------------------------------------------
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

#-----------------------------------------------------------------------
# trim($str)
#-----------------------------------------------------------------------
# 
# Trim whitespace from either side of string argument
#
#-----------------------------------------------------------------------
sub trim
{
	my $str = shift;

	$str =~ s/^\s+//;
	$str =~ s/\s+$//;

	return $str;
}

#-----------------------------------------------------------------------
# usage([$msg])
#-----------------------------------------------------------------------
# 
# Usage statement
#
#-----------------------------------------------------------------------
sub usage
{
	my $msg = shift;
	
	print $msg . "\n\n" if $msg;

	print "\n\n";
	print "Usage: csv_record_writer.pl -h | [options] -i config\n";
	print "\n";
	print "Example: csv_record_writer.pl -i csv_record_writer.ini\n";
	print "Required parameters:\n";
	print "   -i:    config file with OPTIONS and COLUMNS (column definition) sections\n";
	print "Options:\n";
	print "   -l level: Level of logging (0=ERROR, 1=WARNING, 2=INFO, 3=VERBOSE, 4=DEBUG)\n"; 
    print "\n\nSample configuration file:\n\n";
    print "[OPTIONS]\n";
    print "\n";
    print "filename=ds_input.csv\n";
    print "dest_folder=/opt/IBM/ioc/csv\n";
    print "iterations=10\n";
    print "records_per_file=1000\n";
    print "secs_between_iterations=10\n";
    print "datetime_format=%Y-%m-%d %H:%M:%S.000\n";
    print "date_format=%Y-%m-%d\n";
    print "time_format=%H:%M:%S.000\n";
    print "quote_string_values=0\n";
    print "enum_separator=,\n";
    print "\n";
    print "[COLUMNS]\n";
    print "\n";
    print "INDEXNUM=SEQUENCE;1;1;0\n";
    print "STARTDATETIME=DATETIME;03/22/2013 00:00:00;900\n";
    print "ENDDATETIME=DATETIME;03/22/2013 02:00:00;900\n";
    print "LOCATION=POINT;-92;1;44;1\n";
    print "NAME=STRING;Hurricane Approaching,Flood Warning,Heavy Weather,Large Wildfire moving Rapidly West,Chemical Spill Near Residential Area,Major Water Leak\n";
    print "LASTUPDATEDATETIME=DATETIME;03/22/2013 04:00:00;900\n";
    print "TIMEZONEOFFSET=0\n";
    print "PERMITID=INTEGER;1000;10000\n";
    print "READING=FLOAT;0;50\n";
    print "EVENTDATE=DATE;03/22/2013;1\n";
    print "EVENTTIME=TIME;00:00:00;1\n";
    print "ASSET=STRNUM;XXX%rYYY%rZZZ;1;100\n";
    print "ASSET2=STRSEQ;LOC%s;1;1;6\n";
    print "LOCATION2=POLYGON;44,1,-93,1;0.1;3\n";
    print "LOCATION3=MULTILINESTRING;44,1,-93,1;0.1;5\n";
	print "PERMITNAME=PERL;get_permit_name\n";
    print "\n";
 
	exit;
}

&main();
