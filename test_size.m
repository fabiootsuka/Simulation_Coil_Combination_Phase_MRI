function Ac = test_size(A,B)
    
    a = zeros(ndims(A));
    b = zeros(ndims(B));
    n = zeros(ndims(A));
    for i=1:ndims(A)
        a(i) = size(A,i);
        b(i) = size(B,i);
        
        if a(i) > b(i)
            n(i) = a(i)-b(i);
        else
            n(i) = 0;
        end
        cSize(i) = a(i)-n(i);
    end
    
    Ac = zeros(cSize);
    Ac = A(1:cSize(1),1:cSize(2),1:cSize(3),:);