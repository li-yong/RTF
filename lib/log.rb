module LOG
 


def LOG.colorize(text, color_code)
  "\e[#{color_code}m#{text}\e[0m"
end

def LOG.red(text); colorize(text, 31); end
def LOG.green(text); colorize(text, 32); end
def LOG.white(text); colorize(text, 37); end
def LOG.yellow(text); colorize(text, 33); end
def LOG.default(text); colorize(text, 0); end




 


def LOG.warn(level,str,color="red",printOrPut="puts")
 log=level + ", WARN, " + Misc.datenow + ":"+ str
 Misc.saveTxt2File(log,ENV["LOGFILE"])
 
 case level
 when "veryverbose"
   if ENV["LOGLEVEL"]=="veryverbose" 
    cmd= "  #{printOrPut}    LOG.#{color}(str)  "      
    eval(cmd)
   end
   
 when "verbose"
  if ENV["LOGLEVEL"]=="verbose" or ENV["LOGLEVEL"]=="veryverbose"
    cmd= "  #{printOrPut}     LOG.#{color}(str)   "      
    eval(cmd)
  end
  
 when "basic" #basic always print
  #if ENV["LOGLEVEL"]=="basic" or  ENV["LOGLEVEL"]=="verbose" or ENV["LOGLEVEL"]=="veryverbose"
    cmd= "  #{printOrPut}    LOG.#{color}(str)    "      
    eval(cmd)
  #end
  
 else
   cmd= "  #{printOrPut}    LOG.#{color}(str)    "
   eval(cmd)
 end  # case level
  
end #def LOG.warn(level,str,color="red",printOrPut="puts")







def LOG.msg(level,str,color="green",printOrPut="puts")
 log=level + ", MSG, " + Misc.datenow + ":"+ str
 Misc.saveTxt2File(log,ENV["LOGFILE"])
 
 case level
 when "veryverbose"
   if ENV["LOGLEVEL"]=="veryverbose" 
    cmd= "  #{printOrPut}    LOG.#{color}(str)    "      
    eval(cmd)
   end
   
 when "verbose"
  if ENV["LOGLEVEL"]=="verbose" or ENV["LOGLEVEL"]=="veryverbose"
    cmd= "  #{printOrPut}     LOG.#{color}(str) "      
    eval(cmd)
  end
  
 when "basic"
#  if ENV["LOGLEVEL"]=="basic" or  ENV["LOGLEVEL"]=="verbose" or ENV["LOGLEVEL"]=="veryverbose"
    cmd= "  #{printOrPut}     LOG.#{color}(str)   "  
    eval(cmd)
#  end
  
 else
   cmd= "  puts   LOG.#{color}(str)    "
   eval(cmd)  
  
  
 end  # case level
  
end #def LOG.msg(level,str,color="green",printOrPut="puts")














def LOG.colorPuts(str,color="green",printOrPut="puts")  
   cmd= "  #{printOrPut}    LOG.#{color}(\"#{str}\")   "      
    eval(cmd)
end


end #end of the module