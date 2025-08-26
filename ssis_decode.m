function [S_hat, params] = ssis_decode(path, nB, key, alpha, blockSize)
    im = im2double(imread(path));
    im = rgb2ycbcr(im);
    stego = im(:,:,1);

    % Reduce the size of cover image to be a multiple of blockSize and
    % compute size
    [H,W] = size(stego);
    Hc = floor(H/blockSize)*blockSize;
    Wc = floor(W/blockSize)*blockSize;
    N = Hc/blockSize*Wc/blockSize;

    % Initialize secret and cosin transformation matrix
    S_hat = zeros(nB,1);
    dct = dctmtx(blockSize);

    % Secret encoding sequences
    rng(key);
    pn = 2*randi([0,1],nB,1)-1;
    blockIndices = randperm(N);

    % Frequencies to which the secrets are saved in cosin transform
    positions = [
        2 3; 
        3 2; 
        3 3; 
        4 2; 
        2 4; 
        3 4; 
        4 3
    ];
    positionIndices = randi([1,size(positions,1)], nB, 1);

    idx = 1;
    for i = blockIndices
        if idx>nB; break; end
        % Choose the block to be altered
        [r,c] = ind2sub([Hc/blockSize, Wc/blockSize], i);
        row = (r-1)*blockSize+1; 
        col = (c-1)*blockSize+1;
        block = stego(row:row+blockSize-1, col:col+blockSize-1);

        % Coefficient index
        x = positions(positionIndices(idx),1);
        y = positions(positionIndices(idx),2);

        D = dct * block * dct';
        
        S_hat(idx) = D(x,y)/(alpha*mean(abs(D(:))))*pn(idx)>0;

        idx = idx + 1;
    end

    params = struct();
    params.blockIndices = blockIndices;
    params.pn = pn;
    params.positionIndices = positionIndices;
end