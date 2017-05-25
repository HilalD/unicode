function [Odata smpr]=sentence_read(db,index)    
       %returns the wave data of a sentence
       file_name = [[db.path,'/',db.enteries(index).usage,'/',db.enteries(index).dialect...
    ,'/',db.enteries(index).sex,db.enteries(index).speaker,'/',db.enteries(index).sentence] ,'.WAV'];
       [Odata smpr]= readsph(file_name);                     
end