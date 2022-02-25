function [out] = unzipLzw(dataTotal)
    %%DECODIFICACION DE LOS DATOS DEL ZIP
    sizeAlfabetoRecibido = dataTotal(1:8);
    sizeAlfabetoRecibido = bin2dec(reverse(string(num2str(sizeAlfabetoRecibido))));
    nbitsRecibidos = dataTotal(9:16);
    nbitsRecibidos = bin2dec(reverse(string(num2str(nbitsRecibidos))));

    lineaAlfabeto = dataTotal(17:8*sizeAlfabetoRecibido+16);
    bitAlfabetoRestaurado = [sizeAlfabetoRecibido 8];
    k=1;
    i=1;
    rows = sizeAlfabetoRecibido;
    columns = 8;
    while i<=rows
        j=1;
        while j<=columns
            bitAlfabetoRestaurado(i,j) = lineaAlfabeto(1,k);
            k=k+1;
            j=j+1;
        end
        i=i+1;
    end

    alfabetoRestaurado = char(bin2dec(reverse(string(num2str(bitAlfabetoRestaurado))))'); %ALFABETO DEL LZW

    lineaReply = dataTotal(8*sizeAlfabetoRecibido+17:length(dataTotal));
    bitReplyRestaurado = [length(lineaReply)/nbitsRecibidos nbitsRecibidos];
    k=1;
    i=1;
    rows = length(lineaReply)/nbitsRecibidos;
    columns = nbitsRecibidos;
    while i<=rows
        j=1;
        while j<=columns
            bitReplyRestaurado(i,j) = lineaReply(1,k);
            k=k+1;
            j=j+1;
        end
        i=i+1;
    end
    
    replyRestaurado = bin2dec(reverse(string(num2str(bitReplyRestaurado))))';              %INFORMACION DEL LZW

    %%UNZIPLZW
    cod = replyRestaurado;
    dicc = alfabetoRestaurado;
    %%dicc = dicc';
    %%dicc = string(dicc);
    diccMap = containers.Map('KeyType','int32','ValueType','char');
    i=1;
    while i<=length(dicc)
        diccMap(i) = dicc(1,i);
        i = i+1;
    end

    codNuevo = 0;
    cadena = "";
    codViejo = cod(1,1);
    caracter = string(diccMap(codViejo));
    reply = "";
    reply = reply + caracter;
    eof = 0;
    indice = 2;

    while eof==0
        codNuevo = cod(1,indice);
        indice = indice+1;
        if codNuevo>size(diccMap,1)
            cadena = string(diccMap(codViejo));
            cadena = cadena + caracter;
        else
            cadena = string(diccMap(codNuevo));
        end

        reply = reply + cadena;
        cadena = char(cadena);
        caracter = string(cadena(1));
        cadena = string(cadena);
        diccMap(size(diccMap,1)+1)=char(diccMap(codViejo)+caracter);
        codViejo = codNuevo;
        if indice == length(cod)+1
            eof = 1;
        end
    end
    out = reply;
end