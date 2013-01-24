#
#  For use with Phusion Passenger
#

require 'sinatra'
require './taginfo.rb'
 
set :run, false
set :environment, :production

today = Time.now.strftime('%Y-%m-%d')
log = File.new("/osm/taginfo/var/log/taginfo-#{ today }.log", "a+")
$stdout.reopen(log)
$stderr.reopen(log)

$queries_log = File.new("/osm/taginfo/var/log/queries-#{ today }.log", "a+")

run Taginfo

