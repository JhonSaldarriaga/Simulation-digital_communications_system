function [vector] = binarizarVector(vector)
    vector = abs(vector);
    vector = de2bi(vector);
    vector = vector(:,1);
    vector = vector';
end

