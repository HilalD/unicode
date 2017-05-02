 function Iout = readAndPreprocessImage(filename)
                
%         I = imread(filename);
%         Iout = I(:,1:150:end);
%         Iout = reshape(Iout,1,[]);
        % Some images may be grayscale. Replicate the image 3 times to
        % create an RGB image. 
%         if ismatrix(I)
%             I = cat(3,I,I,I);
%         end
       % I(:,:,4) = [];
       % I = mat2gray(I,[0 255]);
       % I = im2uint8(I);
       % I = im2uint16(rgb2gray(I));
        % Resize the image as required for the CNN. 
%         Iout = imresize(I, [227 227]);  
        
        % Note that the aspect ratio is not preserved. In Caltech 101, the
        % object of interest is centered in the image and occupies a
        % majority of the image scene. Therefore, preserving the aspect
        % ratio is not critical. However, for other data sets, it may prove
        % beneficial to preserve the aspect ratio of the original image
        % when resizing.
          Iout = load(filename);
          Iout = Iout.tempmat;
    end