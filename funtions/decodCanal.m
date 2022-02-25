function [Mr] = decodCanal(C)
    G = [1 1 0 1]; % x^3 + x^2 + 1
    P = [1 0 0 0]; % x^(n-k)=x^3
    n = 7;
    k = 4;    
    H = [1 0 1 1 1 0 0; 1 1 1 0 0 1 0; 0 1 1 1 0 0 1]; % MATRIZ DE PARIDAD

    R = (C);                % CODIGO RECIBIDO
    R = reshape(R,7,[]);
    [rows,columns] = size(R);
    sizeR = rows*columns;
    Mr = zeros(4,sizeR/7);
    
    for i=1:columns
        Ri = R(:,i)';
        [D,S] = deconv(Ri,G);    % R/G
        S = binarizarVector(S);
        S = S(1,k+1:n)';         % SINDROME = R mod G
        if S == zeros(1,3)
            Mr(:,i) = Ri(1:4);
        else
            j = 1;
            findError = 0;
            while j<=n | findError == 0
                if H(1:3,j) == S
                    disp("ERROR EN: ");disp(Ri());disp(" EN BIT: " + j + " CORRIGIENDO...");
                    if Ri(j) == 1
                        Ri(j) = 0;
                    else
                        Ri(j) = 1;
                    end
                    disp("R CORREGIDO: ");disp(Ri);
                    findError = 1;
                end
                j = j+1;
            end
%             if findError == 0
%                 disp("ERROR DETECTADO, PERO NO SE PUDO CORREGIR: "); disp(Ri);
%             end
            Mr(:,i) = Ri(1:4);
        end
    end

    bitsAgregados = bi2de(Mr(:,columns)');
    Mr = reshape(Mr,1,[]);
    Mr = Mr(1:length(Mr)-bitsAgregados-4);
end

