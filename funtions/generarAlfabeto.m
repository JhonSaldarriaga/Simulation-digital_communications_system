function[alfabeto] = generarAlfabeto(mF2S)
    alfabeto = '';
    
    for i=1:1:length(mF2S)
        if contains(alfabeto,mF2S(i))==0
            if mF2S(i) == ' '
                alfabeto = alfabeto + " ";
            else
                alfabeto = strcat(alfabeto,mF2S(i));
            end
        end
    end
    
    alfabeto = char(alfabeto);
end