#!/usr/bin/perl
#
# Demo program for using the Uptime API from perl
#
# This demo program connects to an Uptime server and uses the API to retrieve json formatted data
# As with all things perl, there are probably many ways to do this
#
# This particular approach relies on the perl LWP::UserAgent module to make the actual HTTP calls to the up.time API.
# It then uses the JSON::XS module to decode the JSON response into a perl friendly scalar.
# It then provides a couple examples of howto pull out particular fields from that decoded JSON Response. 

use strict;
use warnings;
use JSON::XS;
use LWP::Simple;
use LWP::UserAgent;
use Smart::Comments;
use DateTime::Format::ISO8601;






#API Location & Credential Details - update these to match your environment.

my $uptime_hostname = "localhost";
my $uptime_api_port = 9997;
my $uptime_username = "admin";
my $uptime_password = "uptime";



#This is the element_id that will be used for the single element calls below.
#update as needed.
my $element_id = 1;




STDOUT->autoflush(1);

# counter for Embedded Array in the json
my $eaCount;

# create a UserAgent object
my $ua = LWP::UserAgent->new(ssl_opts=>{verify_hostname=>0});
my $uptimeReq = HTTP::Request->new(get => 'https://' . $uptime_hostname  . ':' . $uptime_api_port . '/api/v1/elements');
   $uptimeReq->authorization_basic($uptime_username,$uptime_password);

# get the uptime API json formatted info
my $rawUptimeAPI =  $ua->simple_request($uptimeReq)->content;
print "\n".$rawUptimeAPI."\n";

# decode the json to a perl scalar
my $decUptimeAPI = decode_json($rawUptimeAPI);

# The 'smart' comment below will print out the Uptime API json as decoded...
### $decUptimeAPI

# do some simple prints to demonstrate how to access the json fields
print "\n";
print "element 1  is: ".$decUptimeAPI->[0]{'monitors'}[0]->{'name'}."\n";
print "element 2  is: ".$decUptimeAPI->[0]{'monitors'}[1]->{'name'}."\n";
print "name 1     is: ".$decUptimeAPI->[0]{'name'}."\n";
print "name 2     is: ".$decUptimeAPI->[1]{'name'}."\n";
print "typeOs     is: ".$decUptimeAPI->[0]{'typeOs'}."\n";

# the decode_json for booleans looks weird, is weird, and requires a de-reference
if (${$decUptimeAPI->[0]{'monitors'}[0]->{'isMonitored'}}) {
   print "isTRUE\n";
}else{
   print "isFALSE\n";
}

# loop through the returned elements and an embedded array as an example
foreach my $element (@$decUptimeAPI) {
   print "\nServer $element->{'name'}  is running $element->{'typeOs'}\n";
   $eaCount = 0;
   while (defined($element->{'monitors'}[$eaCount]->{'name'})) {
     print "   Next monitor is: $element->{'monitors'}[$eaCount]->{'name'}\n";
     $eaCount++;
   }
}
print "\n";


# This section will get a single element from the API, 
print" now get a single element...\n";
$uptimeReq = HTTP::Request->new(get => 'https://' . $uptime_hostname  . ':' . $uptime_api_port . '/api/v1/elements/' . $element_id . '/status');
   $uptimeReq->authorization_basic($uptime_username,$uptime_password);

my $rawUptimeSTAT = $ua->simple_request($uptimeReq)->content;
my $decUptimeSTAT = decode_json($rawUptimeSTAT);

my $eStatus;
# loop through the returned element info 
   print "\nServer $decUptimeSTAT->{'name'} status is $decUptimeSTAT->{'status'}\n";
   $eaCount = 0;
   while (defined($decUptimeSTAT->{'monitorStatus'}[$eaCount]->{'name'})) {
     $eStatus = $decUptimeSTAT->{'monitorStatus'}[$eaCount]->{'status'};
     print "   Next monitor is: $decUptimeSTAT->{'monitorStatus'}[$eaCount]->{'name'} has a status of $eStatus\n";
     $eaCount++;
   }


print"\nnow get the view it is a member of...\n";
$uptimeReq = HTTP::Request->new(get => 'https://' . $uptime_hostname  . ':' . $uptime_api_port . '/api/v1/elements/' . $element_id);
   $uptimeReq->authorization_basic($uptime_username,$uptime_password);

 $rawUptimeSTAT = $ua->simple_request($uptimeReq)->content;
 $decUptimeSTAT = decode_json($rawUptimeSTAT);


if (exists $decUptimeSTAT->{'tags'}[0]) {

 print "Server $decUptimeSTAT->{'name'} is part of view  $decUptimeSTAT->{'tags'}[0]->{'name'}\n"; 

}
else
{
  print "Server $decUptimeSTAT->{'name'} is not a member of any views\n";
}

 


