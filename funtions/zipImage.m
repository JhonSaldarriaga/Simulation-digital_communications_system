function[vector_a_enviar] = zipImage(image_name,delta)
    % 'image_name' es el nombre de la imagen de color gris con la extensión de archivo
    % 'delta' debe ser un valor entre 0 y 1
    % El valor del 'delta' es una medida de la relación de compresión
    % cuando el valor 'delta' es alto, la compresión será alta
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
    x=double(imread(image_name));%double usa 8 Bytes %imread lee la imagen del archivo especificado por filename, infiriendo el formato del archivo a partir de su contenido. 
    len=length(size(x)); % length(X) devuelve la longitud de la dimensión de matriz más grande en X. %size(A) devuelve un vector de fila cuyos elementos contienen la longitud de la dimensión correspondiente de A. Por ejemplo, si A es una matriz de 3 por 4, size(A) devuelve el vector [3 4]
    [r,c,d]=size(x);
    y=zeros(r,c);
    
    %Por encima de la matriz de transformación 8x8 (H) se multiplica por cada bloque de 8x8 en la imagen
    for i=0:8:r-8
        for j=0:8:c-8
            p=i+1;
            q=j+1;
            y(p:p+7,q:q+7)=(H')*x(p:p+7,q:q+7,1)*H;   %Ahora que la matriz de ceros ya esta formada se puede asignar un valor a cada una de las posiciones
        end
    end
    
    %%n1=nnz(y);             % Número de elementos distintos de cero en 'y'
    m=max(max(y));         % M = max(y) devuelve los elementos máximos de un array.
    y=y./m;                % Se reducen los valores haciendo que el maximo valor sea 1 
    y(abs(y)<delta)=0;     % Los valores dentro de + delta y -delta en 'y' se reemplazan por ceros (este es el comando que produce compresión)
    y=y.*m;                % Devolvemos los valores originales a y 
    %%n2=nnz(y);             % Número de elementos distintos de cero en actualizado 'y'
    
    matriz_a_enviar = y(:,:);
    vector_a_enviar = reshape(matriz_a_enviar,1,[]);
end