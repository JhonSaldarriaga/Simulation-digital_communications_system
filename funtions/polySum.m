function [sum] = polySum(p1,p2)
    if length(p1)>length(p2)
        dif = length(p1) - length(p2);
        p2 = [zeros(1,dif) p2];
    elseif length(p2)>length(p1)
        dif = length(p2) - length(p1);
        p1 = [zeros(1,dif) p1];
    end
    sum = p1 + p2;
end

