function blendtri(image1file, image2file, compositefile, pickpts, pickedpts, alpha)

    I = imread(image1file);
    I2 = imread(image2file);
    
    %convert to double
    I = double(I)/255;
    I2 = double(I2)/255;
    
    pts = [];
    %load points from file
    if (pickpts == 0)
        pts = load(pickedpts, '-ascii');
    %get picked points
    else
        subplot(1,2,1), image(I), axis on, title('Image 1');
        subplot(1,2,2), image(I2), axis on, title('Image 2, select points here');
        pts = ginput(3);
        pts = round(pts);
        save(pickedpts, 'pts', '-ascii');
    end;
    
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
    
    %copy original 3 points from image2 to image1
    for i = 1:3
        I(p1(1,2), p1(1,1), i) = I2(p1(1,2), p1(1,1), i);
        I(p2(1,2), p2(1,1), i) = I2(p2(1,2), p2(1,1), i);
        I(p3(1,2), p3(1,1), i) = I2(p3(1,2), p3(1,1), i);
    end;
    
    %determine rectangular region around triangle
    %used to improve performance, all points falling
    %outside this boundary will not be considered
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
                %x endpoint position of ray, we give it an initial value of -1
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
                
                %copy pixel value from image2 to image1 
                if (count == 1)
                    I(i,j,1) = I(i,j,1) + ((I2(i,j,1) - I(i,j,1)) * alpha) ;
                    I(i,j,2) = I(i,j,2) + ((I2(i,j,2) - I(i,j,2)) * alpha);
                    I(i,j,3) = I(i,j,3) + ((I2(i,j,3) - I(i,j,3)) * alpha);
                elseif (count == 2 && isVertex == 1)
                    I(i,j,1) = I(i,j,1) + ((I2(i,j,1) - I(i,j,1)) * alpha);
                    I(i,j,2) = I(i,j,2) + ((I2(i,j,2) - I(i,j,2)) * alpha);
                    I(i,j,3) = I(i,j,3) + ((I2(i,j,3) - I(i,j,3)) * alpha);
                end;
            end;
        end;
    end;
    
    figure(2), image(I), axis off, title('Composite Image');
    imwrite(I, compositefile, 'JPEG');