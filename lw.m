function bbox = lw(srcimagefile, canvassize, warppedimagefile, pickpts, pickedptsfile)
    
    %stores points
    pts = [];
    
    if (pickpts == 0)
        pts = load(pickedptsfile, '-ascii');
    else
        p(1,1) = 255;
        I_warp = zeros(canvassize(4) - canvassize(3), canvassize(2) - canvassize(1),3);
        image(p), axis(canvassize);
        pts = ginput(4);
        save(pickedptsfile, 'pts', '-ascii');
    end;
    
    %get extrema
    b1 = max(pts);
    b2 = min(pts);
    
    bbox(1) = b2(1,1);
    bbox(2) = b1(1,1);
    bbox(3) = b2(1,2);
    bbox(4) = b1(1,2);
    
    if (pickpts == 0)
        I_warp = zeros(round(bbox(4)), round(bbox(2)),3);
    end;
    %construct homogenous points
    pts(1,3) = 1;
    pts(2,3) = 1;
    pts(3,3) = 1;
    pts(4,3) = 1;
    pts = pts';
    
    I = imread(srcimagefile);
    [m,n,o] = size(I);
    
    %get reference points ie corners of the image
    refpts = zeros(4,3);
    
    %bottom-left x,y
    refpts(1,1) = 1;
    refpts(1,2) = m;
    refpts(1,3) = 1;
    %bottom-right
    refpts(2,1) = n;
    refpts(2,2) = m;
    refpts(2,3) = 1;
    %top-right
    refpts(3,1) = n;
    refpts(3,2) = 1;
    refpts(3,3) = 1;
    %top-left
    refpts(4,1) = 1;
    refpts(4,2) = 1;
    refpts(4,3) = 1;
    
    refpts = refpts';
    %get homography
    H = homography(pts, refpts);
  
    H_inv = inv(H);
    %perform transformation
    [y x o] = size(I_warp);
    
    for i = 1 : y;
        for j = 1 : x;
            q = [j i 1]';
            p = round(H_inv * q);
            p = p';
            %make sure we are not outside image
            if (p(1) > 0 && p(1) <= n && p(2) > 0 && p(2) <= m)
                %color(p) = color(q)
                I_warp(i,j,1) = I(p(2), p(1),1);
                I_warp(i,j,2) = I(p(2), p(1),2);
                I_warp(i,j,3) = I(p(2), p(1),3);
            else
                I_warp(i,j,1) = 255;
                I_warp(i,j,2) = 255;
                I_warp(i,j,3) = 255;
            end;
        end;
    end;
    I_warp = I_warp/255;
    figure(2), image(I_warp), axis off, title('Warped Image');
    imwrite(I_warp, warppedimagefile, 'JPEG');
