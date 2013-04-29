module TC
  require "utf"
  require "log"
  load "parseconf.rb"


  def TC.cleanCron()    
     tmpFile=`mktemp`
     UTF.cmdlocal("crontab -l | grep -v sendmail.rb > #{tmpFile}")
     UTF.cmdlocal("crontab #{tmpFile}")
  end

  
  def TC.run(tcfile)
    
    tcname=TC.getTCName(tcfile)
    
    tsname= File.expand_path(tcfile).split("/")[-2]
    tsdatepool=File.dirname(File.expand_path(tcfile))+"/conf/datapool/"
    
    LOG.msg("veryverbose", "ENV[LOGLEVEL]:#{ENV["LOGLEVEL"]} , ENV[UTFROOT]: #{ENV["UTFROOT"]}")
    
    LOG.msg("verbose","\n\n=== #{tcname}  start===","green","puts")
     
    #puts hashCase
    self.loadGlobal()
    
    
    mailsrv=ENV["MAILSRV"]


     self.cleanCron()

   # tcid=tcname.split("_")[0]
    confile=tcfile #"#{ENV["UTFROOT"]}/test/#{tsname}/conf/#{tcname}.conf"
    tcStepArr = Parseconf.parseConf(confile)
    #p tcStepArr ; exit
    tcOverallStat=true
    tcOverallOutput=""

    tcStepArr.each{ |tcCMD|
      tmpHash=UTF.runOneLineCMD(tcCMD)
  
      thisStepStat=tmpHash["stat"]
      thisStepOutput=tmpHash["output"]
      tcOverallOutput=tcOverallOutput+thisStepOutput
      ENV["consoleOutput"]=tcOverallOutput
  
      tcOverallStat=(tcOverallStat and thisStepStat)
   
      } #tcStepArr.each{ |tcCMD|
 
 
 
  if tcOverallStat
    LOG.msg("basic","=== #{tcname} , PASSED ===","green","puts")
  else
    LOG.warn("basic","=== #{tcname} , FAILED ===","red","puts")
  end
  
  rtnHash={}
  rtnHash["stat"]=tcOverallStat
  rtnHash["output"]=tcOverallOutput
  
  tcOverallStat ?  ENV["tcRunStatus"]="true" : ENV["tcRunStatus"]="false"  
  

  
  return rtnHash

  end #  def TC.run
  
  
  
  def TC.loadSuite(suitename)
     file="#{ENV["UTFROOT"]}/test/ts_rcfs/conf/#{suitename}.conf"
     hashSuite=Hash.new
    hashSuite=UTF.arr2Hash(UTF.file2Arry(file),"=")
     #puts hashSuite
    return hashSuite
    
  end #TC.loadSuite(suitename)
  
  
  
  def TC.loadTC(tcname)
    file="#{ENV["UTFROOT"]}/conf/#{tcname}.conf"
    hashCase=Hash.new
    hashCase=UTF.arr2Hash(UTF.file2Arry(file),"=")
    
    hashCase.each_key{|key|
       
      #hashCase[key]=eval(key.to_s.upcase) if hashCase[key]=="<DEFAULT>"
      hashCase[key]=eval(hashCase[key].to_s.upcase) if (hashCase[key] =~ /[a-z]/).nil?

      
      }
    
    return hashCase
    
  end #def TC.loadTC(tcname)
  
 
 
  
  
      def TC.loadGlobal()
      file="#{ENV["UTFROOT"]}/test/_global.conf"
      
      confNoCommentFile=UTF.removeFileComments(file,"globalConf.csv.del")

      #file="/root/utfme/testcase/conf/_global.conf"
      hashCase=Hash.new
      hashCase=UTF.arr2Hash(UTF.file2Arry(confNoCommentFile),"=")
      File.delete(confNoCommentFile)
      
      
      hashCase.each_key{|key|
        if !key.nil?
        
       # s=key.upcase+"=\""+hashCase[key]+"\"" 
       # eval(s)
        ENV[key]=hashCase[key]
        end
   
      }      
      
      end  # def TC.loadGlobal()
      
      

      def TC.checkresult(consoleOutPut,lastCmdStat)
        #check each step's result, print pass or fail
        #p consoleOutPut
        if !(consoleOutPut.downcase.index(/succeed|success|kw2/i).nil?) and lastCmdStat==0
  
         LOG.msg("verbose","\t[ passed ]") #pass of one step within one case
         LOG.msg("veryverbose","\tReason:"+UTF.grepLines(consoleOutPut,"RCFS_TEST|successed"),"white")
          return true
        elsif !(consoleOutPut.downcase.index(/fail|cannot/i).nil?)
         LOG.warn("verbose","\t[ failed ]")
         LOG.warn("verbose","\tReason: "+UTF.grepLines(consoleOutPut,"RCFS_TEST|cannot|failed"))
          return false
        else
          LOG.msg("verbose","\t[ passX ]") #local cmd without output
          return true
        end
        
      end #def TC.checkresult()
      
      def TC.getTCName(tcrubyfile)
        tcname = File.basename(tcrubyfile)
       extname= File.extname(tcrubyfile)
       tcname = tcname.sub(extname,"")
       
       return tcname
      end # def TC.getTCName(tcrubyfile)
  
end  #module TC
