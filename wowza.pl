#!/usr/bin/perl

#Woza Media server statistics script
#Tadas Ustinavicius 2014.05.21

use XML::Simple;
use LWP;
use warnings;
use strict;


my $host="";
my $user="";
my $password="";
my $command="";
my $argument_nr=1;
 
foreach my $ar(@ARGV) {
    
    #rint $ar;
    if ( $ar eq "-h" ) {
        $host=$ARGV[$argument_nr];
    }
    if ( $ar eq "-u" ) {
        $user=$ARGV[$argument_nr];
    }
    if ( $ar eq "-p" ) {
        $password=$ARGV[$argument_nr];
    }
    if ( $ar eq "-c" ) {
        $command=$ARGV[$argument_nr];
    }
    ++$argument_nr;
}
if ($host eq "" or $user eq "" or $password eq "" or $command eq ""){
    print "Missing command line parameters\n";
    exit;
}

my $ua = LWP::UserAgent->new;
$ua->credentials( "$host:8086","Wowza Media Systems", $user=>$password );
my $response = $ua->get("http://$host:8086/connectioncounts/");
my $xml_string= $response->decoded_content;
my $simple = XML::Simple->new();
my $data   = $simple->XMLin($xml_string);
sub validate{
    my ($bps)= @_;

    if ($bps =~ /E/){
	my @values = split('E', $bps);
	$bps=$values[0]*(10**$values[1]);
    }
    my $result = sprintf("%.2f", $bps);
    return $bps;
}
my $result="";
if ($command eq "outbps"){
    $result=validate($data->{'MessagesOutBytesRate'});
}
if ($command eq "inbps"){
    $result=validate($data->{'MessagesInBytesRate'});
}
if ($command eq "conn"){
    $result=$data->{'VHost'}->{'ConnectionsCurrent'};
}
print $result;

