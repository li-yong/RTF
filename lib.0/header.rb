load "utf.rb"
load "tc.rb"
load "misc.rb"

tcname = File.basename(__FILE__)
extname= File.extname(__FILE__)
tcname = tcname.sub(extname,"")