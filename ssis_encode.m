function [stego, params] = ssis_encode(coverPath, S, alpha, key, blockSize)
    C = im2double(imread(coverPath));
    Cy = rgb2ycbcr(C);

    [H,W,~] = size(C);
    nS = numel(S);

    % Reduce the size of cover image to be a multiple of blockSize and
    % compute size
    Hc = floor(H/blockSize)*blockSize;
    Wc = floor(W/blockSize)*blockSize;
    N = Hc/blockSize*Wc/blockSize;
    Cy = Cy(1:Hc,1:Wc,:);
    Y = Cy(:,:,1);

    % Compute cosin transform matrix
    dct = dctmtx(blockSize);

    if N<nS
        error("Too long secret!")
    end

    % Prepare secret
    % noise = rand(nS,1);
    % Senc = noise.*S+(1-S).*g(noise);
    % Sgauss = norminv(Senc);
    Sgauss = 2*S-1;

    % Secret encoding sequences
    rng(key);
    pn = 2*randi([0,1],nS,1)-1;
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
    positionIndices = randi([1,size(positions,1)], nS, 1);
    
    idx = 1;
    for i = blockIndices
        if idx>nS, break; end
        % Choose the block to be altered
        [r,c] = ind2sub([Hc/blockSize, Wc/blockSize], i);
        row = (r-1)*blockSize+1; 
        col = (c-1)*blockSize+1;
        block = Y(row:row+blockSize-1, col:col+blockSize-1);

        % Choose the frequencies to be altered
        x = positions(positionIndices(idx),1);
        y = positions(positionIndices(idx),2);

        % Do the transformation
        D = dct*block*dct';
        D(x,y) = D(x,y) + alpha*Sgauss(idx)*pn(idx)*mean(abs(D(:)));
        
        Dinv = dct'*D*dct;
        Y(row:row+blockSize-1,col:col+blockSize-1) = Dinv;

        idx = idx + 1;
    end

    stego = Cy;
    stego(:,:,1) = Y;
    stego = ycbcr2rgb(stego);

    params = struct();
    params.blockIndices = blockIndices;
    params.pn = pn;
    params.positionIndices = positionIndices;
end

function U = g(u)
    U = (u+0.5).*(u<0.5)+(u-0.5).*(u>=0.5);
end