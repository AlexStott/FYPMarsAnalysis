function [ O ] = focal_stacking( fPath )
%take the path to the input directory as input
%produce the output image
    inputFiles = dir(strcat(fPath, '.\*.tif'));
    numOfImages = length(inputFiles);
    inputImages = cell(1, numOfImages);
    grayInputImages = cell(1, numOfImages);
    laImages = cell(1, numOfImages);
    H = fspecial('laplacian');
    %apply lapacian filter to all the input images
    %use average filter to smooth the laplacian distribution
    G = fspecial('average', [15, 15]);  %best for fly
    %G = fspecial('average', [35, 35]);  %best for watch
    %G = G./sum(G(:));
    stepSize = 1;
    imageName = inputFiles(1).name;
    inputImagesSample = imread(strcat(fPath, '\', imageName));
    [m,n,d] = size(inputImagesSample);
    
    LaImgTotal = double(zeros(m, n));%sum of laplacian
    for i=1:stepSize:numOfImages
        imageName = inputFiles(i).name;
        inputImages{i} = imread(strcat(fPath, '\', imageName));
        grayInputImages{i} = rgb2gray(inputImages{i});
        %apply laplacian filter
        laImages{i} = abs(imfilter(grayInputImages{i}, H, 'replicate', 'same'));
        
        templaImages = laImages{i};
        templaImages(templaImages < 20) = 0;
        LaImgTotal = LaImgTotal + double(templaImages);
        %figure, imshow(laImages{i}, []);
        %apply average filter
        laImages{i} = imfilter(double(laImages{i}), double(G), 'replicate', 'same');
        %laImages{i} = medfilt2(laImages{i}, [10, 10]);
        laImages{i}(laImages{i}<=0) = eps;
        %figure, imshow(laImages{i}, []);
    end
    %figure, imshow(uint8(LaImgTotal));
    save('totalLap', 'LaImgTotal');
    %get the pixel with the highest lapacian value
    Map = uint16(zeros(m, n));
    for i=1:1:m
        for j=1:1:n
            selectedImage = 1;
            maxLap = laImages{selectedImage}(i, j);
            for k = 1 + stepSize:stepSize:numOfImages
                if (laImages{k}(i, j) > maxLap)
                    maxLap = laImages{k}(i, j);
                    selectedImage = k;
                end
            end
            O(i, j, :) = inputImages{selectedImage}(i, j, :);
            Map(i, j) = selectedImage;
        end
    end
    laRes = abs(imfilter(rgb2gray(O), H, 'replicate', 'same'));
    laErr = uint8(laRes) - uint8(LaImgTotal);
    laErr(laErr < 0) = 0;
    %smoothed laplacian only
    figure, imshow(O);
    %figure, imshow(laErr);
    %instead of search from the corner, we search from the pixel with max
    %laplacian
    maxLa = max(LaImgTotal(:));
    [starti, startj] = find(LaImgTotal==maxLa);
    for i=starti(1, 1):1:m
        for j=startj(1,1):1:n
            if (LaImgTotal(i, j) > 0)
                %if there's an edge, choose the pixels from frame with
                %highest laplacian
                selectedImage = 1;
                maxLap = laImages{selectedImage}(i, j);
                for k = 1 + stepSize:stepSize:numOfImages
                    if (laImages{k}(i, j) > maxLap)
                        maxLap = laImages{k}(i, j);
                        selectedImage = k;
                    end
                end
            else
                %if there's no edge, choose the same as its neighbors
                if (i == starti(1, 1))
                    selectedImage = Map(i, j-1);
                elseif (j == startj(1,1))
                    selectedImage = Map(i-1, j);
                else
                    %from the 3 neighboors, choose the one that has the
                    %highest laplacian
                    lap1 = laImages{Map(i-1, j-1)}(i-1, j-1);
                    lap2 = laImages{Map(i, j-1)}(i, j-1);
                    lap3 = laImages{Map(i-1, j)}(i-1, j);
                    maxLap123 = max([lap1, lap2, lap3]);
                    if (maxLap123 == lap1)
                        selectedImage = Map(i-1, j-1);
                    elseif (maxLap123 == lap2)
                        selectedImage = Map(i, j-1);
                    else
                        selectedImage = Map(i-1, j);
                    end
                end
            end
            O(i, j, :) = inputImages{selectedImage}(i, j, :);
            Map(i, j) = selectedImage;
        end
    end
    for i=starti(1, 1):-1:1
        for j=startj(1,1):1:n
            if (LaImgTotal(i, j) > 0)
                %if there's an edge, choose the pixels from frame with
                %highest laplacian
                selectedImage = 1;
                maxLap = laImages{selectedImage}(i, j);
                for k = 1 + stepSize:stepSize:numOfImages
                    if (laImages{k}(i, j) > maxLap)
                        maxLap = laImages{k}(i, j);
                        selectedImage = k;
                    end
                end
            else
                %if there's no edge, choose the same as its neighbors
                if (j == startj(1,1))
                    selectedImage = Map(i+1, j);
                else
                    lap1 = laImages{Map(i+1, j-1)}(i+1, j-1);
                    lap2 = laImages{Map(i+1, j)}(i+1, j);
                    lap3 = laImages{Map(i, j-1)}(i, j-1);
                    maxLap123 = max([lap1, lap2, lap3]);
                    if (maxLap123 == lap1)
                        selectedImage = Map(i+1, j-1);
                    elseif (maxLap123 == lap2)
                        selectedImage = Map(i+1, j);
                    else
                        selectedImage = Map(i, j-1);
                    end
                end
            end
            O(i, j, :) = inputImages{selectedImage}(i, j, :);
            Map(i, j) = selectedImage;
        end
    end
    for i=starti(1, 1):1:m
        for j = startj(1,1):-1:1
            if (LaImgTotal(i, j) > 0)
                %if there's an edge, choose the pixels from frame with
                %highest laplacian
                selectedImage = 1;
                maxLap = laImages{selectedImage}(i, j);
                for k = 1 + stepSize:stepSize:numOfImages
                    if (laImages{k}(i, j) > maxLap)
                        maxLap = laImages{k}(i, j);
                        selectedImage = k;
                    end
                end
            else
                %if there's no edge, choose the same as its neighbors
                if (i == starti(1, 1))
                    selectedImage = Map(i, j+1);
                else
                    lap1 = laImages{Map(i-1, j+1)}(i-1, j+1);
                    lap2 = laImages{Map(i-1, j)}(i-1, j);
                    lap3 = laImages{Map(i, j+1)}(i, j+1);
                    maxLap123 = max([lap1, lap2, lap3]);
                    if (maxLap123 == lap1)
                        selectedImage = Map(i-1, j+1);
                    elseif (maxLap123 == lap2)
                        selectedImage = Map(i-1, j);
                    else
                        selectedImage = Map(i, j+1);
                    end
                end
            end
            O(i, j, :) = inputImages{selectedImage}(i, j, :);
            Map(i, j) = selectedImage;
        end
    end
    for i=starti(1, 1):-1:1
        for j=startj(1, 1):-1:1
            if (LaImgTotal(i, j) > 0)
                %if there's an edge, choose the pixels from frame with
                %highest laplacian
                selectedImage = 1;
                maxLap = laImages{selectedImage}(i, j);
                for k = 1 + stepSize:stepSize:numOfImages
                    if (laImages{k}(i, j) > maxLap)
                        maxLap = laImages{k}(i, j);
                        selectedImage = k;
                    end
                end
            else
                %if there's no edge, choose the same as its neighbors
                lap1 = laImages{Map(i+1, j+1)}(i+1, j+1);
                lap2 = laImages{Map(i+1, j)}(i+1, j);
                lap3 = laImages{Map(i, j+1)}(i, j+1);
                maxLap123 = max([lap1, lap2, lap3]);
                if (maxLap123 == lap1)
                    selectedImage = Map(i+1, j+1);
                elseif (maxLap123 == lap2)
                    selectedImage = Map(i+1, j);
                else
                    selectedImage = Map(i, j+1);
                end
            end
            O(i, j, :) = inputImages{selectedImage}(i, j, :);
            Map(i, j) = selectedImage;
        end
    end
    figure, imshow(O);
    figure, imshow(Map, []);
end
