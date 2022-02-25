function [dataTotal] = zipLzw(mF)
     %%ZIPLZW
    fuente = mF;
    alfabeto = generarAlfabeto(fuente);
    dicc = alfabeto;
    testingMap = containers.Map('KeyType','char','ValueType','int32');
    i=1;
    while i<=length(dicc)
        testingMap(dicc(1,i)) = i;
        i = i+1;
    end

    w="";
    k="";
    reply=("");
    eof = 0;
    firstValue = 1;
    i = 1;
    while eof == 0
        k = string(fuente(1,i));
        i = i+1;
        
        if isKey(testingMap,char(w+k))==1
            w = w + k;
        else
            if firstValue == 1
                reply(1) = string(testingMap(char(w)));
                firstValue = 0;
            else
                reply(length(reply)+1) = string(testingMap(char(w)));
            end
            testingMap(char(w+k)) = size(testingMap,1)+1;
            w=k;
        end
        if i == length(fuente)+1
            eof = 1;
        end
    end
    reply(length(reply)+1) = string(testingMap(char(w)));

    %%CODIFICACION DE LOS DATOS DEL ZIP
    nbits = ceil(log2(max(double(reply))));
    parametros = [de2bi(double(string(num2str(length(alfabeto)))),8) ; de2bi(double(string(num2str(nbits))),8)];
    bitAlfabeto = de2bi(double(alfabeto),8);
    bitAlfabeto = [parametros;bitAlfabeto];
    
    [rows,columns] = size(bitAlfabeto);
    dataAlfabeto = [1 rows*columns];
    k=1;
    for i=1:rows
        for j=1:columns
            dataAlfabeto(1,k) = bitAlfabeto(i,j);
            k=k+1;
        end
    end
    
    bitReply = de2bi(double(reply),nbits);
    
    [rows,columns] = size(bitReply);
    dataReply=[1 rows*columns];
    k=1;
    for i=1:rows
        for j=1:columns
            dataReply(1,k) = bitReply(i,j);
            k=k+1;
        end
    end
    dataTotal = [dataAlfabeto dataReply];
end