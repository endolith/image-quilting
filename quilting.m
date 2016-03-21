% Parameters
bsize = 20;              % Set by user
ovsize = floor(bsize/6); % Efros and Freeman
tolerance = 0.02;         % Tolerance level

% Open image
im = double(imread('images/rice.jpg'));
[im_h, im_w, ~] = size(im);

mri = floor(im_h/bsize); % maximum row index
mci = floor(im_w/bsize); % maximum col index

% out = uint8(zeros(im_w*2, im_h*2, 3));
out = double(zeros(300, 300, 3));
[out_h, out_w, ~] = size(out);

% Set the first block at random for the block comparison
first_block = get_block(im, bsize, randi(mri), randi(mci));
prev_block = first_block;
out(1:bsize, 1:bsize, :) = prev_block;

% Fill in first row
for col = 2:floor((out_w/bsize)) + 1    % +1 fills in half block gap at end
  col_cut = max(1, (col-1)*(bsize) - ovsize):(col*bsize - ovsize);
  
  if length(col_cut) > bsize
    col_cut = col_cut(1:end-1);
  end
  
  % Totally random selection
  % out(1:bsize, col_cut, :) = get_block(im, bsize, randi(mri), randi(mci));
  
  % Random selection from best matches
  prev_block = random_match_1(prev_block, im, bsize, ovsize, tolerance, 'vert');
  out(1:bsize, col_cut, :) = prev_block;
end

% Fill in first column
prev_block = first_block;
for row = 2:floor((out_h/bsize)) + 1    % +1 fills in half block gap at end
  row_cut = max(1, (row-1)*(bsize) - ovsize):(row*bsize - ovsize);
  
  if length(row_cut) > bsize
    row_cut = row_cut(1:end-1);
  end
  
  % Totally random selection
  % out(row_cut, 1:bsize, :) = get_block(im, bsize, randi(mri), randi(mci));
  
  % Random selection from best matches
  prev_block = random_match_1(prev_block, im, bsize, ovsize, tolerance, 'hori');
  out(row_cut, 1:bsize, :) = prev_block;
end

% Fill in the rest of the output image
for row = 2:floor((out_h/bsize)) + 1 
  for col = 2:floor((out_w/bsize)) + 1
    % Indexes in output image to write to
    row_cut = max(1, (row-1)*bsize):row*bsize;
    col_cut = max(1, (col-1)*bsize):col*bsize;
    
    if length(row_cut) > bsize
      row_cut = row_cut(1:end-1);
    end
    
    if length(col_cut) > bsize
      col_cut = col_cut(1:end-1);
    end
    
    % Left and above blocks to compare to
    block_left = get_block(out, bsize, row, col-1);
    block_above = get_block(out, bsize, row-1, col);
    
    % Random selection from k best matches
    out(row_cut, col_cut, :) = random_match_2(block_left, block_above, im, bsize, ovsize, tolerance);
%     out(row_cut, col_cut, :) = random_match_1(block_above, im, bsize, ovsize, tolerance, 'hori');
  end
end

% % Fill in the rest
% for row = 1:(out_h/bsize)+2
%   row_cut = row*bsize:(row+1)*bsize;
%
%   if length(row_cut) > bsize
%     row_cut = row_cut(1:end-1);
%   end
%
%   for col = 1:(out_w/bsize)+2
%     col_cut = col*bsize:(col+1)*bsize;
%
%     if length(col_cut) > bsize
%       col_cut = col_cut(1:end-1);
%     end
%
%     % Randomly pick blocks
%     out(row_cut, col_cut, :) = get_block(im, bsize, randi(mci), randi(mri));
%   end
% end

imshow(uint8(out));