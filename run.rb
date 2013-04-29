#! /usr/local/bin/ruby
utfroot=File.dirname(File.expand_path(__FILE__))



ENV["UTFROOT"]=utfroot
ENV["UTFGLOBALFILE"]=utfroot+"/test/_global.conf"
ENV["LOGFILE"]=utfroot+"/log/test.log"
$LOAD_PATH << ENV["UTFROOT"]+"/lib"

require 'optparse'
load "log.rb"
load "utf.rb"

#--------- Start of parse option
options = {}

optparse = OptionParser.new do|opts|

   opts.on( '-h', '--help', 'Display this screen' ) {  puts opts; UTF.showExample(); exit }
   
   options[:testGroup] = []
   opts.on( '-s', '--testsuite ts1,ts2,ts3', Array, "run tests suite"  ){|tg|  options[:testGroup] = tg }
    
   options[:testCase] = []
   opts.on( '-t', '--testcase tc1,tc2,tc3', Array, "run test cases"  ){|t|  options[:testCase] = t }  
  
   options[:runConf] = []
   opts.on( '-f', '--runconf ', "run xml configuration file"  ){|f|  options[:runConf] = f }
  
   options[:verbose] = :basic
   opts.on( '-v', '--verbose OPT [basic, verbose, veryverbose]', [:basic, :verbose, :veryverbose],'verbose output Level' ) {|v|    options[:verbose] = v  }
#   opts.on( '-v', '--verbose', 'verbose display' ) { options[:verbose] = verbose  }

#   opts.on( '-z', '--veryverbose', 'very verbose display' ) { options[:verbose] = veryverbose  }
   
 
 
 
   options[:pcapenable] = false
   opts.on( '-p', '--pcap', 'enable pacp' ) { options[:pcapenable] = true  }
    
   options[:listSuite] = false
   opts.on( '-g', '--listSuite', "List TestSuite" ) { options[:listSuite] = true }
   
   options[:listCase] = false
   opts.on( '-c', '--listCase', "List TestCase" ) { options[:listCase] = true }  
 
end

begin
 optparse.parse!
rescue
  LOG.colorPuts("command syntax not correct, see usage")
  system(" #{__FILE__} -h")
  exit
end

#p options


if !(options[:runConf].empty?) and  !(options[:testGroup].empty?)
     LOG.warn("basic", "runConf and testGroup can NOT show at same time")
     exit
end

if !(options[:runConf].empty?) and  !(options[:testCase].empty?)
     LOG.warn("basic", "runConf and testCase can NOT show at same time")
     exit
end  

if !(options[:testCase].empty?) and  options[:testGroup].empty? and (options[:runConf].empty?)
     LOG.warn("basic", "need specify testGroup or using runConf")
     exit
end

tGLength=options[:testGroup].length
if !(options[:testCase].empty?) and  tGLength > 1
     LOG.warn("basic", "You specified #{tGLength} test group with testCae. \nOnly 1 testGroup in CLI supported when run testCase, \n   using -f runConf or testGroup only to run whole testSuite")
     exit
end








(UTF.listTestSuite();exit)  if options[:listSuite] 
(testsuite=UTF.getTestSuite() ; testsuite.each{|ts| UTF.listTestCase(ts) }; exit ) if options[:listCase] 


options[:pcapenable] ?  ENV["pcapenable"]="yes" : ENV["pcapenable"]="no"
 
 
case options[:verbose].to_s
 
when "basic"
   ENV["LOGLEVEL"]="basic"
when "verbose"
   ENV["LOGLEVEL"]="verbose"
when "veryverbose"
   ENV["LOGLEVEL"]="veryverbose"
else
   ENV["LOGLEVEL"]="basic"
end

(system(" #{__FILE__} -h") ;exit) if (options[:testGroup].empty? \
                             and options[:testCase].empty? and !options[:listSuite] \
                             and options[:runConf].empty? \
                             and !options[:listCase] )




testSCStatus=true
options[:testGroup].each{|tg|
  s= UTF.checkTestSuiteExist(tg)
 testSCStatus= (testSCStatus and s)
} #

exit if !testSCStatus



tcrunArr=[]
tcrunHash={}

if options[:runConf].empty?

   if options[:testCase].empty?  #if no testcase gave in cli, puts all testsuite.
    options[:testGroup].each{|tg|
       tcrunHash[tg] = UTF.getTestCase(tg)
        }
   else
     options[:testCase].each{|tc|   tcrunArr<<tc}
     tcrunHash[options[:testGroup][0]] = tcrunArr  # #cmd line only accept 1 test suite with test case
   end
end



if !(options[:runConf].empty?)
 tcrunHash=UTF.parseRunXML(options[:runConf])
end

    



testSCStatus=true
tcrunHash.each{|tsname,tcarr|
  s= UTF.checkTestSuiteExist(tsname)
 testSCStatus= (testSCStatus and s)
 tcarr.each{|tcname|  s=UTF.checkTestCaseExist(tsname,tcname)
    testSCStatus=(testSCStatus and s)
    }
} #

exit if !testSCStatus

tcrunHash.each{|key,value|
  print "Will Run Suite: " ; LOG.msg("basic", "#{key}")
  value.each{|tcname|  puts "\t#{tcname}" }
} #

#p tcrunHash
#exit

tcrunHash.each{|keyTS,valueTC|
   tcrunHash[keyTS].uniq.each{ |tc|
#begin
   testscript="#{ENV["UTFROOT"]}/test/#{keyTS}/#{tc}"
  
  if File.exist?(testscript) 
     #p "run #{testscript}"
     #system("ruby #{testscript}")
     TC.run(testscript)
  else
     LOG.warn("basic", "#{tc}, no such file #{testscript} ")
  end
#rescue 
#   puts "error run #{tc}"
#end

}#tcarr.uniq.each{ |tc|
   
} #tcrunHash.each{|key,value}

   


exit
 
#--------- End of parse option

