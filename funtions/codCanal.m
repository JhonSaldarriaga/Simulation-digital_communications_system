function [C] = codCanal(dataTotal)
    G = [1 1 0 1]; % x^3 + x^2 + 1
    P = [1 0 0 0]; % x^(n-k)=x^3
    n = 7;
    k = 4;
    
    M = dataTotal;
    diferencia = k - mod(length(M),k);
    if mod(length(M),k) ~= 0
        M = [M zeros(1,diferencia) de2bi(diferencia,k)];
    else
        M = [M de2bi(0,k)];
    end
    
    M = reshape(M,4,[]);
    [rows,columns] = size(M);
    sizeM = rows*columns;
    C = zeros(7,sizeM/4);
    
    for i=1:columns
        Mi = M(:,i)';
        PM = conv(P,Mi);                            % x^(n-k)*M
        [Q,Re] = deconv(PM,G);                      % x^(n-k)*M mod G
        B = Re;                 
        B = binarizarVector(B);                     % B(x)
        C(:,i) = binarizarVector(polySum(PM,B))';   % x^(n-k)*M + B(x)
        %C(randi([1,7],1,1),i) = randi([0,1],1,1);   %SIMULACION DE ERROR
    end
    C = reshape(C,1,[]);
end

