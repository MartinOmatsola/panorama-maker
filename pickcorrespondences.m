function pickcorrespondences(directoryname, correspfile)

    files = strcat(directoryname, '/*.jpg');
    d=dir(files);
    numfiles = length(d);
    %stores selected points
    pts = [];
    for k = 1 : numfiles;
        img = imread(strcat(directoryname ,strcat('/', d(k).name)));
        subplot(1,numfiles,k), image(img), axis on, title(strcat('Image', int2str(k)));
    end
    
    %pick exactly 8 points for each correspondence
    %so we need (numfiles+2) * 4 points in total
    pts = ginput(4 * (numfiles + 2));
   
    save(correspfile, 'pts', '-ascii');

    
    
    
