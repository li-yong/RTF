module Parseconf
#load "utf.rb"
#load "tc.rb"
#load "misc.rb"
#load "log.rb"


#ENV["UTFROOT"]="."
#TC.loadGlobal()

 
 


def Parseconf.complieCmd(hashCase)
 cmd = ""
  hashCase.each{|key,value|
    if !key.nil?
      if !value.nil?
        cmd=cmd+" "+key+"="+value
      else
        cmd=cmd+" "+key
      end
      
    end
      
    }
  
   return cmd 
end



def Parseconf.findGlobalEnv(vlaue)

                if !ENV[vlaue].nil?
                 return  ENV[vlaue]
                else
                  LOG.warn("veryverbose","[#{vlaue}] not defined in _global.conf,consider revise test case conf file.")
                  return false
                end
end


def Parseconf.handleOneLineCMD(cmd)
  #input oneline, translate UPCASE with _global.conf then return translated content.
     arrnew=cmd.split(" ")
     
     singleParArr=[]
     hashParArr=[]
     #combine all single paramet to one arr
     arrnew.each{|rec|
       if rec.include?("=")
         hashParArr << rec
       else
         singleParArr << rec
       end
         } #arrnew.each{|rec|

     
     
    hashCase= UTF.arr2Hash(hashParArr,"=")
    

    
    hashCase.each_key{|key|
        if !key.nil? and !hashCase[key].nil? 
              if  (hashCase[key] =~ /[a-z]/).nil?   # = UPCASE
                 if !(hashCase[key] =~ /[A-Z]/).nil? # check if only number case                 
                    envValue=self.findGlobalEnv(hashCase[key])
                 else
                    envValue=hashCase[key] # in the case if only number
                 end #if !(hashCase[key] =~ /[A-Z]/).nil? 
              if  envValue == false
                 LOG.warn("verbose","#{key}=#{hashCase[key]} not defined in _global.conf,consider revise test case conf file.")
              else
                 hashCase[key]=envValue
              end #if  envValue == false
 
                 
              end # if  (hashCase[key] =~ /[a-z]/).nil? 
           
        end# if !key.nil? and !hashCase[key].nil? 
    } # hashCase.each_key{|key|
    
    
    rtnArr=[singleParArr,hashCase]; 
    return rtnArr

end


def Parseconf.translateOneCMD(cmd)
#substitude variable with _global file defined.
  
hash={}
  varArr=cmd.scan(/#\{(.*?)}/)  #cmd  "abc\#{abc}efg/bcs\#{fff}", varArr=[["abc"], ["fff"]]
  varArr.each{|x| hash[x[0]]=self.envaluateSingleVar(x[0]) }

  hash.each{|key,value| cmd=cmd.gsub("#\{#{key}\}",value) }

  return cmd

  
  
=begin when delete, make sure delete used functions to keep code clean
    tmp= self.handleOneLineCMD(cmd)
    arrSingle=tmp[0]
    hashCase=tmp[1]   
    cmdSingle=""
     arrSingle.each{|x| cmdSingle=cmdSingle+" "+self.envaluateSingleVar(x)}
     cmdHash=self.complieCmd(hashCase)
     onecmd=cmdSingle+" "+cmdHash
     return onecmd
=end     
end #def Parseconf.translateOneCMD(cmd)

def Parseconf.parseConf(confile)
   tcConfArr= UTF.parseTCConf(confile)
  #p tcConfArr; exit
  
    rtnarr=[]   
   (1..(tcConfArr.length-1)).each{|i|
      emailTo=tcConfArr[i][0]  
      subject=tcConfArr[i][1]  
      contentFile=tcConfArr[i][2]    
      cronString=tcConfArr[i][3]  
      

     rtnarr << [emailTo,subject,contentFile,cronString]
 
  
   }
   

 # p rtnarr; exit
   return rtnarr

#return arr is everyline of conf 
#[["local_dd", false, " mkdir -p CVSDD_par1/CVSDD_par2/CVSDD_par3 "], ["local", false, " mkdir -p testdir5 "]]

      
end #def Parseconf.parseConf(confile)      
 

def Parseconf.envaluateSingleVar(var)

if  (var =~ /[a-z]/).nil?   # ONLY UPCASE+number
                 if !(var =~ /[A-Z]/).nil? #   if not only number                 
                    rtn=self.findGlobalEnv(var)
                 else
                    rtn=var # in the case if only number
                 end #if !(hashCase[key] =~ /[A-Z]/).nil? 
              if  rtn == false
                 rtn=var
                 LOG.warn("verbose","#{var} not defined in _global.conf,consider revise test case conf file.")
              end #if  envValue == false
else
  rtn=var                 
end # if  (var =~ /[a-z]/).nil


return rtn

end #def ParseConf.envSingleVar(var)




end #module ParseConf
 
 
