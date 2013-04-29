module Misc


  def Misc.datenow()
    
    year=DateTime.now.year.to_s
    mon=DateTime.now.month.to_s; mon="0"+mon if mon.length==1 
    day=DateTime.now.day.to_s;day="0"+day if day.length==1
    hour=DateTime.now.hour.to_s;hour="0"+hour if hour.length==1
    min=DateTime.now.min.to_s;min="0"+min if min.length==1
    sec=DateTime.now.sec.to_s;sec="0"+sec if sec.length==1 
    
    #puts year+"-"+mon+"-"+day+" "+hour+":"+min+":"+sec
    return year+"-"+mon+"-"+day+" "+hour+":"+min+":"+sec
  end #def Misc.datenow()


  def Misc.saveTxt2File(txt,filename)
    #path=Pathname.new(filename).split[0].to_s
   # basename=Pathname.new(filename).split[1].to_s # or File.basename(filename)    
    
    #filename=path+"/"+basename
    myfile=File.new(filename,"a+")
    myfile.puts(txt)
    myfile.close
  end #def Misc.saveTxt2File(txt,file)
  
  
  
  def Misc.removeLine(pattern,filename)
   cmdlnx = "sed -i \"#{pattern}\"  #{filename}"
  `#{cmdlnx}`

  end
  
  
end #module Misc