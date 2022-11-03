clc; clear;
v = VideoReader("D:\TemDownload\10-16-57.avi");
frames = read(v, 1);
try 
    i = 1;
    while 1
        i = i + 1;
        next_frame = read(v, i);
        frames = cat(4, frames, next_frame);
    end
catch
    printf("Finished")
end

frames
    
       
