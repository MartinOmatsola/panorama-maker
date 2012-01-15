function pick3pts(inputfile, outputfile, pickedpts)

    I = imread(inputfile);
    figure(1), axis off, image(I);
    
    %get picked points
    pts = ginput(3);
    pts = round(pts);
    
    %construct lines
    p1 = pts(1,:);
    p2 = pts(2,:);
    p3 = pts(3,:);
    
    %construct line1 from p1 and p3
    v1 = p3 - p1;
    l1 = [p1;v1];
    
    %construct line2 from p1 and p2
    v2 = p2 - p1;
    l2 = [p2;v2];
    
    %construct line3 from p2 and p3
    v3 = p3 - p2;
    l3 = [p2;v3];
    
    %color original points black
    for i = 1:3
        I(p1(1,2), p1(1,1), i) = 0;
        I(p2(1,2), p2(1,1), i) = 0;
        I(p3(1,2), p3(1,1), i) = 0;
    end;
    
    %determine rectangular region around triangle
    %used to improve performance, all points falling
    %outside this boundary will immediately be colored
    %white
    b1 = max(pts);
    b2 = min(pts);
    
    [m,n,o] = size(I);

    for i = 1 : m;
        for j = 1 : n;
            %check if pixel is in boundary
            
            if (j > b2(1,1) && j < b1(1,1) && i > b2(1,2) && i < b1(1,2))
                count = 0;
               
                %check if ray intersects with more than two lines
                
                %check l1
                %stores x postion of endpoint of ray, inital value set to
                %-1
                x_val1 = -1;
                if (v1(1,2) ~= 0)
                    t1 = (i - p1(1,2))/v1(1,2);
                    x_val1 = p1(1,1) + (t1 * v1(1,1));
                    if (t1 >= 0 && t1 <= 1 && x_val1 - j >= 0)
                        count = count + 1;
                    end;
                end;
                
                %check l2
                x_val2 = -2;
                if (v2(1,2) ~= 0)
                    t2 = (i - p1(1,2))/v2(1,2);
                    x_val2 = p1(1,1) + (t2 * v2(1,1));
                    if (t2 >= 0 && t2 <= 1 && x_val2 - j >= 0)
                        count = count + 1;
                    end;
                end;
                
                %check l3
                x_val3 = -3;
                if (v3(1,2) ~= 0)
                    t3 = (i - p2(1,2))/v3(1,2);
                    x_val3 = p2(1,1) + (t3 * v3(1,1));
                    if (t3 >= 0 && t3 <= 1 && x_val3 - j >= 0)
                        count = count + 1;
                    end;
                end;
                
                %check for special case when ray hits a vertex
                isVertex = (x_val1 == x_val2 || x_val2 == x_val3 || x_val3 == x_val1);
                
                %color pixel black 
                if (count == 1)
                    I(i,j,1) = 0;
                    I(i,j,2) = 0;
                    I(i,j,3) = 0;
                elseif (count == 2 && isVertex == 1)
                    I(i,j,1) = 0;
                    I(i,j,2) = 0;
                    I(i,j,3) = 0;
                else
                    I(i,j,1) = 255;
                    I(i,j,2) = 255;
                    I(i,j,3) = 255;
                end;
            else
                I(i,j,1) = 255;
                I(i,j,2) = 255;
                I(i,j,3) = 255;
            end;
        end;
    end;
    
    figure(2), image(I), axis off;
    
    save(pickedpts, 'pts', '-ascii');
    imwrite(I, outputfile, 'JPEG');