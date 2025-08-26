function stego = ssis_encode(coverPath, S, alpha, key, blockSize)
    C = im2double(imread(coverPath));
    Cy = rgb2ycbcr(C);

    [H,W,~] = size(C);
    nS = numel(S);

    % Prepare secret
    noise = rand(nS,1);
    Senc = noise.*S+(1-S).*g(noise);
    Sgauss = norminv(Senc);

    % Reduce the size of cover image to be a multiple of blockSize
    Hc = floor(H/blockSize)*blockSize;
    Wc = floor(W/blockSize)*blockSize;
    Cy = Cy(1:Hc,1:Wc,:);
    Y = Cy(:,:,1);

    dct = dctmtx(blockSize);
    N = Hc/blockSize*Wc/blockSize;
    if N<nS
        error("Too long secret!")
    end

    rng(key);
    % pn = 2*randi([0,1],nS,1)-1;
    % blockIndices = randperm(N);
    idx = 1;
    for i = 1:blockSize:Hc
        for j = 1:blockSize:Wc
            if idx>nS, break; end
            D = dct*block*dct';
            % D(4,3) = D(4,3) + alpha*(2*Sgauss(idx)-1)*pn(idx);
            D(4,3) = D(4,3) + alpha*Sgauss(idx);
            
            Dinv = dct'*D*dct;
            Y(i:i+blockSize-1,j:j+blockSize-1) = Dinv;

            idx = idx + 1;
        end
    end

    stego = Cy;
    stego(:,:,1) = Y;
    stego = ycbcr2rgb(stego);
end

function U = g(u)
    U = (u+0.5).*(u<0.5)+(u-0.5).*(u>=0.5);
end