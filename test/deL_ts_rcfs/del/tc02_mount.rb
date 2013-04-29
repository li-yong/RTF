$LOAD_PATH << ENV["UTFROOT"]+"/lib/"
load "header.rb"

rst=TC.run(__FILE__)
 
  
  ENV["tcRunStatus"]=tcOverallStat
  ENV["consoleOutput"]=tcOverallOutput


if ENV["tcRunStatus"]
  consoleOutPut= ENV["consoleOutput"]
  fsid=consoleOutPut.scan(/fsid = \d*/)[0].to_s.split[-1]
  fid1=consoleOutPut.scan(/fid1 = \d*/)[0].to_s.split[-1]
  fid2=consoleOutPut.scan(/fid2 = \d*/)[0].to_s.split[-1]
  

  UTF.updateGlobalFile("FHFSID",fsid)
  UTF.updateGlobalFile("FHFID1",fid1)
  UTF.updateGlobalFile("FHFID2",fid2)

  
  LOG.msg("veryverbose","tc2 passed, fsid #{fsid}, fid1 #{fid1},fid2 #{fid2}")
    
end


grepConsoleSave2GlobalFile("FHFSID",/fsid = \d*/)
grepConsoleSave2GlobalFile("FHFID1",/fid1 = \d*/)
grepConsoleSave2GlobalFile("FHFID2",/fid2 = \d*/)


