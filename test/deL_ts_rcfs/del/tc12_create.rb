$LOAD_PATH << ENV["UTFROOT"]+"/lib/"
load "header.rb"

rst=TC.run(__FILE__)
 



if rst["stat"]
  consoleOutPut=rst["output"]
   fid1=consoleOutPut.scan(/fid1 = \d*/)[0].to_s.split[-1]
 

  UTF.updateGlobalFile("FILEINODE",fid1)

  
  LOG.msg("veryverbose","tcname passed, FILEINODE #{fid1}")
    
end 
