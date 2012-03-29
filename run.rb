#! /usr/local/bin/ruby
utfroot=File.dirname(File.expand_path(__FILE__))



ENV["UTFROOT"]=utfroot
ENV["UTFGLOBALFILE"]=utfroot+"/conf/_global.conf"
ENV["LOGFILE"]=utfroot+"/log/test.log"
$LOAD_PATH << ENV["UTFROOT"]+"/lib"

load "log.rb"
load "utf.rb"

ENV["LOGLEVEL"]="verbose"
#ENV["LOGLEVEL"]="basic"
 
testscript="#{utfroot}/conf/conf1.csv"
  
 
TC.run(testscript)
exit