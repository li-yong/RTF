$LOAD_PATH << "/root/TE/lib"

require 'optparse'
load "log.rb"
load "utf.rb"
load "tc.rb"

file="/root/TE/test/ts_rcfs/conf/tc01_null.csv"
p UTF.csv2Arr(file,["par1","par2","par3"])
