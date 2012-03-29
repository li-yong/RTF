module UTF
  require 'csv'
  require 'log'
  require 'tc'
  require 'rexml/document'
  require 'misc'
  include REXML

def UTF.parseRunXML(xml)
  
xmlfile = File.new(xml)
xmldoc = Document.new(xmlfile)

root = xmldoc.root
#puts "Test Run description : " + root.attributes["description"]
rtnHash={}
xmldoc.root.elements.each{|e| 
tsuite= e.attribute("name").to_s
tcases= e.get_text("testcases").to_s.split(",")

rtnHash[tsuite]=tcases

}
#p rtnHash
return rtnHash
end #def UTF


def UTF.file2Arry(file)  
tsarr=Array.new

fh=File.open(file)
fh.each{|line|
  
#puts line
 
  rst=line.sub(/\n/,"")
  
  if !rst.empty?    
     tsarr << rst
  end
  
  }

return tsarr
end  #def UTF.file2Arry(file)  



def UTF.arr2Hash(arr,splitC)  

 rtnHash=Hash.new
 speChar="thisISSpecialChar"
  arr.each{|record|
    record=record.sub(splitC,speChar) #replce 1st splitc
    tmpArr=record.split(speChar)
    key=tmpArr[0]
    value=tmpArr[1]
    rtnHash[key]=value
    }
  

  
  return rtnHash
  
end #def UTF.arr2Hash(arr)



def UTF.showExample()
  output="
 example:

 Show Test Suite:
   ./run.rb -s
 
 Show Test Case:
    ./run.rb -c
    
 Run Testcase tc_001
    ./run.rb -t tc_001
    
 Run Testcase tc_001 with verbose output
    ./run.rb -t tc_001 -v verbose

 enable pCAP on Sade when run tc_001, pCAP will save under log folder.
    ./run.rb -t tc_001 -p
    
 run TestSuite 'ts_rcfs' and testcase 'tc_001'
    ./run.rb -g ts_rcfs -t tc_001
  
 "
  
  output ="puts example"
  
 puts output
  
  
  
end #UTF.showExample()


def UTF.cmdlocal(cmd)
  cmdChomp=cmd.chomp();
  LOG.msg("verbose","\t#{cmdChomp}","green", "print")
  file="/tmp/testout.del"
  `#{cmd} > #{file} 2>&1; echo $?  >> #{file} `
    
 fileNum=File.read(file).count("\n")
 fileNumOut=(fileNum.to_i - 1).to_s
 output=`head -#{fileNumOut} #{file}`
 cmdStat=`tail -1 #{file}`
 
 cmdStat ? LOG.msg("verbose","\t[Done]") : LOG.warn("verbose","\t[fail]")
  
  
  
   
  return [output,cmdStat]
end #def UTF.cmdlocal(cmd)


def UTF.rsh2sade(ip,cmd)
  cmd2p="rsh #{ip} \'#{cmd}\'"
  cmd=cmd.gsub(";",'\;'); 
  file="/tmp/testout.del"
  LOG.msg("verbose","\t#{cmd2p}","green", "print")

 # `rsh  #{ip} \'#{cmd};echo $?\'  > #{file} 2>&1`
  `rsh  #{ip} \'#{cmd}\'  > #{file} 2>&1`
  `rsh  #{ip} \'echo $?\'  >> #{file} 2>&1`
   #`echo 0 >> #{file}` #sade not support two cmd in one line.
  fileNum=File.read(file).count("\n")
   fileNumOut=(fileNum.to_i - 1).to_s
  output=`head -#{fileNumOut} #{file}`
  cmdStat=`tail -1 #{file}`
  
  rshCmdexitCode=cmdStat
 
  LOG.msg("veryverbose","\n\t===cmd output start===")
  File.readlines("/tmp/testout.del").each{|line| line.chomp!; LOG.msg("veryverbose","\t #{line}","white") }
  LOG.msg("veryverbose","\n\t===cmd output end===")
  

  return [output,rshCmdexitCode] 
end #def UTF.rsh2sade(ip,cmd)



def UTF.ssh2sade(ip,cmd)
  cmd2p="ssh #{ip} \'#{cmd}\'"
  cmd=cmd.gsub(";",'\;'); 
  file="/tmp/testout.del"
  LOG.msg("verbose","\t#{cmd2p}","green", "print")

  `ssh  #{ip} \'#{cmd};echo $?\'  > #{file} 2>&1`
  #`ssh  #{ip} \'#{cmd}\'  > #{file} 2>&1`
  #`ssh  #{ip} \'echo $?\'  >> #{file} 2>&1`
   #`echo 0 >> #{file}` #sade not support two cmd in one line.
  fileNum=File.read(file).count("\n")
   fileNumOut=(fileNum.to_i - 1).to_s
  output=`head -#{fileNumOut} #{file}`
  cmdStat=`tail -1 #{file}`
  
  sshCmdexitCode=cmdStat
  #puts "cmdStat is #{cmdStat}"
 
  LOG.msg("veryverbose","\n\t===cmd output start===")
  File.readlines("/tmp/testout.del").each{|line| line.chomp!; LOG.msg("veryverbose","\t #{line}","white") }
  LOG.msg("veryverbose","\n\t===cmd output end===")
  

  return [output,sshCmdexitCode] 
end #def UTF.ssh2sade(ip,cmd)






def UTF.csv2Arr(csvfile,headerArr)
#return COMBINATION ARRAY of COLUMNs in 'headerArr' of 'csvfile' )  
  

 c=CSV.open(csvfile)
 cHeader=c.readline
 c.close


csvHeaderIndexArr=[]
colHash={}
headerArr.uniq.each{|headername|  csvHeaderIndexArr << cHeader.index(headername) }
headerArr.uniq.each{|headername|  colHash["#{headername}"]=[] }


 CSV.foreach(csvfile) { |row|
    # p csvHeaderIndexArr; exit
    csvHeaderIndexArr.each{|cvsHeaderInx|
      if !row[cvsHeaderInx].nil?
        colHash["#{cHeader[cvsHeaderInx]}"]<< row[cvsHeaderInx]
      end      
    }
    
  }



resultArr=[]
headerArr.each{|x| resultArr<<colHash[x].dup; }

resultArr.each{|arr| arr.shift}

rtnarr=self.eachArr(resultArr)
  
return rtnarr

  
end #def UTF.csv2Arr(csvfile)



 

def UTF.combin2Arr(arr1,arr2,separater)
  rtnarr=[]
  arr1.each{|a1|
                  arr2.each{|a2|  rtnarr << "#{a1}#{separater}#{a2}"}
                  }
  return rtnarr
  
end #def UTF.combin2Arr(arr1,arr2,separater)
  
  
  
 

def UTF.eachArr(arr)
  l=arr.length
  arrtmp=arr[0]
  (0..(l-1)).each{|x|
    #p arr[x+1]
    if !arr[x+1].nil?
      arrtmp=self.combin2Arr(arrtmp,arr[x+1],"_rtfSeparater_")
#     arrtmp=self.combin2Arr(arrtmp,arr[x+1],",")
    end
    } 
  return arrtmp
end #UTF.eachArr(arr)


      def  UTF.updateGlobalFile(keywords,value)
	filename=ENV["UTFGLOBALFILE"]
	Misc.removeLine("/#{keywords}=/d",filename)
	Misc.saveTxt2File("#{keywords}=#{value}",filename)
	return true
      end
      
      
     def UTF.grepLines(consoleOutPut,keywords)
        
        rtn=consoleOutPut.scan(/[#{keywords}].*\n/i)
        return rtn.to_s        
     end #def UTF.grepLines(consoleOutput,keywords)
      
      
      

 
def UTF.parseTCConf(tcconfFile)
      
 ###input: test case's csv format configuration file
 ###output: [["Object", "Action", "Data"], ["ANIP", "rsh", "rcfstest null srv=SNIP"]]

 confNoCommentFile=self.removeFileComments(tcconfFile,"tcconf.csv.del")

 csvfile=confNoCommentFile
 require 'csv'
 rtnarr=[]
 c=CSV.open(csvfile,"rb")
 CSV.foreach(csvfile) { |row|   rtnarr<<row  }
 
 File.delete(confNoCommentFile)

 return rtnarr

end #def UTF.parseTCConf(tcconfFile)
       
       
def UTF.removeFileComments(inputF,outputF)
  noCommentFile = File.new(outputF, "w+")
  
 File.open(inputF).each {|line|
    if (line =~ /^\s*#/).nil? and  !(line =~ /^\s*$/) #the line NOT start with # and  NOT blank line            
      noCommentFile.puts(line)
     # puts "puts line #{line}"
    end   
      }
 noCommentFile.close
 return File.expand_path(outputF)
end #def UTF.removeFileComments(inputF,outputF)

 
def  UTF.runOneLineCMD(tcCMD)
 
  emailTo=tcCMD[0]
  subject=tcCMD[1]
  contentFile=tcCMD[2]
  cronTime=tcCMD[3]

  tmpFile=`mktemp`


  #save current crontab to file
  self.cmdlocal("crontab -l > #{tmpFile}")

  #append new cron task
  cronCmd= "#{cronTime} sendmail.rb #{emailTo} \"#{subject}\" < #{contentFile} "
  self.cmdlocal("echo \'#{cronCmd}\'  >> #{tmpFile}")
  
  #load cron
  consoleOutPut,cmdExitCode=self.cmdlocal("crontab #{tmpFile}")   

  self.cmdlocal("rm -f #{tmpFile}")
  
  rtnHash={}
  rtnHash["output"]=consoleOutPut
  
 #  assert="cmdExitCode=0" 
 #  assertType="assertCmdECEq"
  # assertData=assert.gsub(/\s/,"").split("=")[1]


#print assertData 
     #    cmdExitCode=cmdExitCode.gsub(/[\n]*$/, "")
         cmdExitCode ? rtnHash["stat"]=true  :  rtnHash["stat"]=false  
        # rtnHash["stat"] ? LOG.msg("verbose","\t[Done]") : LOG.warn("verbose","\t[fail]")


  return rtnHash
     
end # def  UTF.runOneLineCMD(tcCMD)   
  


def UTF.startPcap(sadeip,sadeNic,sadePcapDir,pcapName)
   cmdStartPcap="netcap action=start device=#{sadeNic}  filename=/#{sadePcapDir}/#{pcapName}"
   output,exitcode=self.rsh2sade(sadeip,cmdStartPcap)
   return TC.checkresult(output,$?)
end #def UTF.startPcap(sadeip,tcname)


def UTF.stopPcap(sadeip,sadeNic)
   cmdStartPcap="netcap action=stop device=#{sadeNic} "
   output,exitcode=self.rsh2sade(sadeip,cmdStartPcap)
   return TC.checkresult(output,$?)
end #def UTF.stopPcap(sadeip,tcname)


def UTF.mountSade(sadeip,sadeExp,localMntP)
  cmdMntDart="mount -t nfs #{sadeip}:/#{sadeExp}  #{localMntP}"
     output = self.cmdlocal(cmdMntDart)
    return TC.checkresult(output,$?)
end #UTF.mountSade(sadeExp,localMntP)


def UTF.umountSade(localMntP)
   cmdUMntDart="umount   #{localMntP}"
   output = self.cmdlocal(cmdUMntDart)
   return TC.checkresult(output,$?)
end #UTF.mountSade(sadeExp,localMntP)



def UTF.cpFile(srcF,dstF)
   cmdCP="cp #{srcF} #{dstF} "
   output = self.cmdlocal(cmdCP)
   return TC.checkresult(output,$?)
end #UTF.mountSade(sadeExp,localMntP)




def UTF.getTestSuite()
 cmd = "cd #{ENV["UTFROOT"]}/test; ls -d ts_*/  "
 cmdOutput= UTF.cmdlocal(cmd)[0].gsub("/","")
 cmdStat=false
 cmdStat=true if (cmdOutput =~ /no such file/i).nil?
  rtnArr=[] 
  if cmdStat
    rtnArr=(cmdOutput.split)
  end 
 return rtnArr  
end #UTF.getTestSuite()


def UTF.listTestSuite()
 tsArr=self.getTestSuite  
 LOG.msg("basic","\navailble testsuite:")
 if !tsArr.empty?
   tsArr.each{|tsuit| print "\t"; puts tsuit }
 else
   puts "\tno testsuite found"
 end 
end #UTF.listTestSuite()




def UTF.getTestCase(testsuite)
 cmd="cd #{ENV["UTFROOT"]}/test/#{testsuite}; ls tc*_*  "
 cmdOutput= self.cmdlocal(cmd)[0]
 cmdStat=false
 cmdStat=true if (cmdOutput =~ /no such file/i).nil?
  rtnArr=[]
  if cmdStat
  (cmdOutput.split).each{|tcfile| rtnArr << tcfile}    
  end
  return rtnArr    
end #UTF.getTestCase(testsuite)




def UTF.listTestCase(testsuite)
  LOG.msg("basic", "\ntestcase in testsuite \'#{testsuite}\':")
  rtnArr=self.getTestCase(testsuite)
  if !rtnArr.empty?
    rtnArr.each{|tcname| print "\t"; puts tcname  }
  else
    puts "\tno testcase in testSuite #{testsuite}"
  end
end #  UTF.listTestCase(testsuite)



def UTF.checkTestSuiteExist(testsuite)
  file="#{ENV["UTFROOT"]}/test/#{testsuite}"
  if !(File.exist?(file))
    LOG.warn("basic", "testSuite #{testsuite} not exist.")
    self.listTestSuite()
    rtn=false
  elsif !(File.directory?(file))
    LOG.warn("basic", "testSuite #{testsuite} not a directory")
    rtn=false
  else
    rtn=true
  end
  
  return rtn
  
end #def UTF.checkTestSuiteExist(testsuite)


def UTF.checkTestCaseExist(testsuite,testcase)
  file="#{ENV["UTFROOT"]}/test/#{testsuite}/#{testcase}"
  
  if !(File.exist?(file) )
    LOG.warn("basic","testcase #{file} not exist")
    self.listTestCase(testsuite)
    rtn= false
  elsif File.directory?(file)
    LOG.warn("basic","testcase #{file} is not a file. (directory)")
    rtn=false
  else
    rtn=true
  end
  
  return rtn
end #def UTF.checkTestCaseExist(testsuite,testcase)



def UTF.grepConsoleSave2GlobalFile(nameINGlobalFile,regExpressSearchConsole)
  value=ENV["consoleOutput"].scan(regExpressSearchConsole)[0].to_s.split[-1]
  if self.updateGlobalFile(nameINGlobalFile,value)  
    LOG.msg("verbose","\tsaved #{nameINGlobalFile}=#{value} to _global.conf","green","print")
    return "saved  var to global file successed"
  else
    return "saved  var to global file failed"
  end
end #def UTF.grepConsoleSave2GlobalFile(nameINGlobalFile,regExpressSearchConsole)


def UTF.replaceUnit(cmd,newArr)
 arr=cmd.scan(/CVSDD_\w*/)
 arr.each_index{|idx| cmd=cmd.sub(arr[idx],newArr[idx]);   }
 return cmd
end #def UTF.replaceUnit(cmd,newArr)




end #module UTF
