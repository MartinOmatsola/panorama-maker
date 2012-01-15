function makepanorama(directoryname, correspfile, panoramaimagefile)

    files = strcat(directoryname, '/*.jpg');
    d=dir(files);
    numfiles = length(d);
    %stores selected points
    pts = load(correspfile, '-ascii');
    img = [];
    
    %setup panorama image
    %we use the last image as a starting point
    image2 = strcat(directoryname, strcat('/', d(numfiles).name));
    base = imread(image2);
    imwrite(base, panoramaimagefile, 'JPEG');
    imcounter = numfiles;
    
    %main loop, load images and make panorama
    for k = (numfiles+2)*4 : -8 : 8;
        %start from last image
        image2 = panoramaimagefile;
        image1 = strcat(directoryname, strcat('/', d(imcounter).name));
        I2 = imread(image2);
        I = imread(image1);
        %get currentt set of points
        pts1 = pts(k-7:k-4, :);
        pts2 = pts(k-3:k, :);
        for i = 1 : 4
            pts1(i,3) = 1;
            pts2(i,3) = 1;
        end;
      
        pts1 = pts1';
        pts2 = pts2';
        H = homography(pts2, pts1);
        H_inv = inv(H);
   
        [m n o] = size(I2);
        [x y z] = size(I);
        corners = H_inv * [1 m 1;n m 1;n 1 1;1 1 1]';
        corners = corners';
        corners = round(corners(:,1:2));
        save('temp.txt', 'corners', '-ascii');
        
        %warp image n to image n-1 space
        bbox = lwbilinear(image2, [], 'warped.jpg', 0, 'temp.txt');
   
        I = double(I)/255;
        img = imread('warped.jpg');
        img = double(img)/255;
        [r s t] = size(img);
        %r, x, s,y
        y_min = min([r x]);
        y_max = max([r x]);
        x_min = min([s y]);
        x_max = max([s y]);
        %[u v w] = size(I(1:x,1:y));
        %[r s t] = size(img(1:x,1:y));
        % u,v,w,r,s,t
        
        img(1:y_min,1:x_min,1) = I(1:y_min,1:x_min,1) + ((img(1:y_min,1:x_min,1) - I(1:y_min,1:x_min,1)) * 0.08);
        img(1:y_min,1:x_min,2) = I(1:y_min,1:x_min,2) + ((img(1:y_min,1:x_min,2) - I(1:y_min,1:x_min,2)) * 0.08);
        img(1:y_min,1:x_min,3) = I(1:y_min,1:x_min,3) + ((img(1:y_min,1:x_min,3) - I(1:y_min,1:x_min,3)) * 0.08);
        
        %save partials to disk, iteratively builds up final image
        figure(k), image(img);
        imwrite(img, panoramaimagefile, 'JPEG');
        imcounter = imcounter - 1;
    end;
   
   figure(3), image(img);

    
    
    
