function C = interptab_Tingey_s1505528(N,Q)

warning 'N must be an even integer'; 

q = 1:Q; % set q to values between 1 and Q
alpha = (-Q/2 +q -1)/Q; % set values for alpha
beta = -(N-1)/2:1:(N-1)/2; % set values for beta (position)

L = zeros(N,N,Q); % preassign a 3 dimensional matrix that will be used to find the table
L1 = zeros(N,Q); % preassign a 2 dimensional matrix that will hold coefficients

% My method here is an interesting one and hard to explain. First I create
% an N by Q matrix that holds values for alpha(1) - beta(n) in the first
% column, alpha(2) - beta(n) in the second column..... up to alpha(Q) -
% beta(n) in the Qth column. (where n ranges from 1 to N). 

for i = 1:N
    for j = 1:Q
        L1(i,j) = alpha(j)-beta(i); % create a for loop that reads in values to be used in calculation for polynomial.
    end 
end 

% Now I take that initial matrix and from it I create a 3 dimensional
% matrix that will hold the key to creating all possible polynomial
% coefficients for my final table matrix. I read in the first column of my
% NxQ (L1) matrix into every column of my first NxN matrix (L(:,:,1)). Then the kth
% column of my NxQ matrix into the kth NxN matrix (L(:,:,k))... etc.

for i = 1:N
    for j = 1:N
        for k = 1:Q
    L(:,j,k) = L1(:,k); % this for loop takes each column of L1 and makes Q NxN matrices where each NxN matrix has exactly the same columns.
        end
    end 
end 

% Now I need to make sure that each NxN matrix in my 3-dimensional matrix
% has a diagonal equal to 1. This is so when I take the product of the
% columns later they will correspond to the numerator of each of the different polynomial
% coefficients for each separate alpha value. 


for k = 1:Q
L(:,:,k) = L(:,:,k) - diag(diag(L(:,:,k))-1); % this loop puts the value 1 across the diagonal of each matrix to fit the formula for the polynomial when I eventually take the product.
end 

% The formula to find the diagonal firstly identifies the diagonal of the
% kth NxN matrix and makes it 0, and then reconstructs the desired matrix
% with 1's across the diagonal. I found out how to achieve this after some
% research online, and then applied it to my 3-dimensional matrix. 

% initialise a denominator matrix. 

H = zeros(N,N);

% This for loop now creates the denominator which will be used to create
% the interpolating table. I realise from the lecture notes that it is some
% factorial function, however I have decided to do it this way as I am not
% quite sure how to implement the factorial method. 

for i = 1:N
    for h = 1:N
        H(i,h) = beta(h) - beta(i); % this for loop computes columns that will give the denominator of the polynomial.
    end
end

% This next step lets the diagonal of the matrix H be 1 instead of 0. Important to
% calculate the product. The reason why I can use 'eye' is because the
% diagonal of the H matrix is originally always zero... as it takes beta(i)
% - beta(i) = 0 for the ith row and column. 

H = H + eye(N);  

Num = zeros(N,Q); % numerator of polynomial
Denom = zeros(1,N); % denominator of polynomial
Table = zeros(Q,N); % preassign table size

% Now all I have to do is take the product of each column of the kth matrix
% in my 3 dimensional matrix and read it into a new matrix named 'Num'.
% This mean every column in my 'Num' Matrix is a product for separate alpha
% values. Also, I do a similar thing for the denominator. Then I divide the
% numerator by the denominator to give me a table of the polynomial
% coefficients. 

for i = 1:Q
    for j = 1:N
    Num(1:N,i) = prod(L(:,:,i)); % takes the product of each column of the ith NxN matrix.
    Denom(1,j) = prod(H(:,j));  % takes the product of each column in the H matrix to give denominator. 
    end 
end 

DenomInv = 1./Denom; % calculate inverse so there are no divisions in for loop. 

for i = 1:Q
    for j = 1:N
        Table(i,j) = Num(j,i).*DenomInv(1,j); % produces the polynomial coefficient matrix. Will have Q rows and N columns.
    end 
end 
C = Table;


% Notes: I know in the tutorial there was some mention of using a 'squeeze'
% function and then something else. I found that slightly too complicated
% so I decided to use for loops instead. I am intrigued in how I could make
% this method even more efficient however. 

    









