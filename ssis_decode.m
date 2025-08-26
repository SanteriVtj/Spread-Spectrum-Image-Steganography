function S_hat = ssis_decode(path, nB, key, blockSize)
    im = im2double(imread(path));
    im = rgb2ycbcr(im);
    stego = im(:,:,1);

    [H,W] = size(stego);
    S_hat = zeros(nB,1);

    dct = dctmtx(blockSize);

    rng(key);
    % pn = 2*randi([0,1], nB, 1)-1;
    pn = rand(nB,1);
    idx = 1;
    blocks = {1:nB};
    for row=1:blockSize:H
        for col = 1:blockSize:W
            if idx>nB; break; end
            blocks{idx} = [row (row+blockSize-1); col (col+blockSize-1)];
            block = stego(row:row+blockSize-1, col:col+blockSize-1);
            D = dct * block * dct';
            S_hat(idx) = (D(4,3)*pn(idx))>0;
            idx = idx + 1;
        end
    end
end