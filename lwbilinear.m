function bbox = lwbilinear(srcimagefile, canvassize, warppedimagefile, pickpts, pickedptsfile)
    
    %stores points
    pts = [];
    
    if (pickpts == 0)
        pts = load(pickedptsfile, '-ascii');
    else
        blank(1,1) = 255;
        I_warp = zeros(canvassize(4) - canvassize(3), canvassize(2) - canvassize(1),3);
        image(blank), axis(canvassize);
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
    
    I = double(I)/255;
    I_warp = double(I_warp)/255;
   
   
    for i = 1 : y;
        for j = 1 : x;
            q = [j i 1]';
            p = round(H_inv * q);
            p = p';
            %make sure we are not outside image
            if (p(1) > 0 && p(1) <= n && p(2) > 0 && p(2) <= m)
	    
                %check if there are four surrounding pixels in src image
                if (p(1) == 1 || p(1) == n || p(2) == 1 || p(2) == m)
                    %color(q) =  color(p)
                    I_warp(i,j,1) = I(p(2), p(1),1);
                    I_warp(i,j,2) = I(p(2), p(1),2);
                    I_warp(i,j,3) = I(p(2), p(1),3);
                else
                    %do bilinear interpolation
                    %setup interpolation points with neighbouring pixels
                    x1 = p(1) + 1;
                    y1 = p(2) + 1;
                    
                    x2 = p(1) - 1;
                    y2 = y1;
                    
                    x3 = x1;
                    y3 = p(2) - 1;
                    
                    x4 = x2;
                    y4 = y3;
                    for k = 1 : 3;
                        x_inter1 = (((x1 - p(1))/(x1 - x2))*I(y2,x2,k)) + (((p(1) - x2)/(x1 - x2))*I(y1,x1,k));
                        x_inter2 = (((x1 - p(1))/(x1 - x2))*I(y4,x4,k)) + (((p(1) - x2)/(x1 - x2))*I(y3,x3,k));
                        
                        estimate = (((y1 - p(2))/(y1 - y3))*x_inter1) + (((p(2) - y3)/(y1 - y3))*x_inter2);
                        
                        I_warp(i,j,k) = estimate;
                    end;
                end;
            else
                %outside image boundary color pixel blank
                I_warp(i,j,1) = 1.0;
                I_warp(i,j,2) = 1.0;
                I_warp(i,j,3) = 1.0;
            end;
        end;
    end;
    %I_warp
    %I_warp = I_warp/255;
    
    figure(2), image(I_warp), axis on, title('Warped Image');
    imwrite(I_warp, warppedimagefile, 'JPEG');
