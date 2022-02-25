function [z] = unzipImage(fuenteReconstruida,r,c)
    %H1, H2, H3 son las matrices de las transformadas de wavelet de Haar
    H1=[0.5 0 0 0 0.5 0 0 0;0.5 0 0 0 -0.5 0 0 0;0 0.5 0 0 0 0.5 0 0 ;0 0.5 0 0 0 -0.5 0 0 ;0 0 0.5 0 0 0 0.5 0;0 0 0.5 0 0 0 -0.5 0;0 0 0 0.5 0 0 0 0.5;0 0 0 0.5 0 0 0 -0.5;];
    H2=[0.5 0 0.5 0 0 0 0 0;0.5 0 -0.5 0 0 0 0 0;0 0.5 0 0.5 0 0 0 0;0 0.5 0 -0.5 0 0 0 0;0 0 0 0 1 0 0 0;0 0 0 0 0 1 0 0;0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 1;];
    H3=[0.5 0.5 0 0 0 0 0 0;0.5 -0.5 0 0 0 0 0 0;0 0 1 0 0 0 0 0;0 0 0 1 0 0 0 0;0 0 0 0 1 0 0 0;0 0 0 0 0 1 0 0;0 0 0 0 0 0 1 0;0 0 0 0 0 0 0 1;];
    
    % Normalizacion de cada matriz H1, H2, H3  (Esto da como resultado columnas ortonormales de cada matriz)
    H1=normc(H1);
    H2=normc(H2);
    H3=normc(H3);
    H=H1*H2*H3; %Multiplicacion de matrices ortogonales resultantes
    %***************************************************************************

    reconstruccion_matriz = reshape(fuenteReconstruida,r,c);
    
    %DWT inversa de la imagen
    for i=0:8:r-8
        for j=0:8:c-8
            p=i+1;
            q=j+1;
            z(p:p+7,q:q+7)=H*reconstruccion_matriz(p:p+7,q:q+7)*H';   %Descompresion
        end
    end
end

