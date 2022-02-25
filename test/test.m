
clc;clear all;

load('vector_a_enviar.mat');
fuente = vector_a_enviar;
%fuente = [-1.001,0,0,0,1.01,0];
i = 1;
newFuente = "";

s = length(fuente);
while i<=s
    newFuente = newFuente + char(string(fuente(i)));
    newFuente = newFuente + " ";
    i=i+1;
end
fuente = char(newFuente);

%fuente = 'ME QUIERO SUICIDAR' 
alfabeto = generarAlfabeto(fuente);

tic;
dataTotal = zipLzw(fuente);
"ZIPLZW TERMINADO"
toc

tic;
C = codCanal(dataTotal);    
"COD CANAL TERMINADO"
toc

%% COMIENZA MODULACION PAM-16
tic;
data = C;
M = 16;                                             %Tamaño del alfabeto (símbolos digitales a Tx)
b = log2(M);                                        % Número de bits/símbolo banda base o pasabanda

Nbits = length(data);	                            % Número total de bits a transmitir
% GENERANDO LOS SIMBOLOS BANDA BASE
Nsymb = Nbits/b;                                    % Numero de símbolos digitales banda base a TX, debe ser un número entero

% Si Nsymb NO ES ENTERO, SE DEBE CONCATENAR LA SECUENCIA BINARIA Nbits
data_c = 0;                                         % Inicializando la variable
if mod(Nbits,b)==0;                             
   data_c = [data de2bi(0,b)];           
elseif mod(Nbits,b)~= 0;
   concat = zeros(1,b-mod(Nbits,b));                % Numero de ceros que se deben adicionar a los datos originales
   data_c = [data concat de2bi(b-mod(Nbits,b),b)];  % Datos originales concatenados con los ceros y la cantidad de ceros
end
Nbits_c = length(data_c);   % La nueva secuencia binaria con datos concatenados

% SE SEGMENTA LA NUEVA SECUENCIA BINARIA (número de símbolos o mensajes digitales banda base mi a transmitir)
Nsymb = Nbits_c/b;                                  % Numero de símbolos digitales
Ts = 1/Nsymb;                                       % Intervalo o periodo de símbolo banda base
Rs = 1/Ts;                                          % Tasa de transmisión de símbolos banda base (símbolos/s)

% CODIFICACIÓN GRAY PARA CADA UNO DE LOS SIMBOLOS DIGITALES mi
bits_symbol = zeros(b,Nsymb);
bits_symbol(:)= data_c;

%LISTA CADA SIMBOLO A ENVIAR Y SU VALOR EN DECIMAL
indice_symbol = bi2de(transpose(bits_symbol),'left-msb');       
A = 1;                                              % distancia de separación de los símbolos M-PAM

% Codificación Gray de los símbolos
[indices_pam,mapeo_pam] = bin2gray(indice_symbol,'pam',M);      

symbol_pam = transpose(indices_pam*2-(M-1));        % VALORES DE VOLTAJE ai

g = symbol_pam;                                     % Símbolos banda base a transmitir
"MODULACION PAM-16 TERMINADO"
toc


%% PASAR LOS SIMBOLOS BANDA BASE POR EL CANAL AWGN (Solo adiciona ruido estocástico)

scatterplot(g,[],[],'r-*');grid on;    % Constelación de los símbolos banda base antes de entrar al canal
title('Transmit signal constellation');hold on
legend('Transmit signal');

% RELACIÓN SNR PARA EL CANAL AWGN
Es_N0_dB = [-2:2:20];        % Vector de relación señal a ruido para los símbolos values
Matriz = zeros(1,Nsymb);   % Matriz de Zeros

s = (1/sqrt(5))*g;         % normalization of energy of the baseband symbols, pulso conformador
n = 1/sqrt(2)*[randn(1,Nsymb) + j*randn(1,Nsymb)]; % AWGN; mean=0 dB
alpha = rand(1,length(Es_N0_dB));  % Attenuation factor

for ii = 1:length(Es_N0_dB)
%%  TRANSMISION
    y = s + 10^(-Es_N0_dB(ii)/20)*n;   % Transmited signal with only AWGN
    
    % y = s*alpha(ii) + 10^(-Es_N0_dB(ii)/20)*n;   % Transmited signal with AWGN and attenuation
    
%%  RECEPCION
    rx = real(y);                       % Rx signal and taking only the real part of de y
%%  DEMODULACION
    Matriz(find(rx< -14/sqrt(5))) = -15;
    Matriz(find(rx>= -14/sqrt(5) & rx<=-13/sqrt(5))) = -13;
    Matriz(find(rx< -12/sqrt(5) & rx>-13/sqrt(5))) = -13;
    Matriz(find(rx>= -12/sqrt(5) & rx<=-11/sqrt(5))) = -11;
    Matriz(find(rx< -10/sqrt(5) & rx>-11/sqrt(5))) = -11;
    Matriz(find(rx>= -10/sqrt(5) & rx<=-9/sqrt(5))) = -9;
    Matriz(find(rx< -8/sqrt(5) & rx>-9/sqrt(5))) = -9;
    Matriz(find(rx>= -8/sqrt(5) & rx<=-7/sqrt(5))) = -7;
    Matriz(find(rx< -6/sqrt(5) & rx>-7/sqrt(5))) = -7;
    Matriz(find(rx>= -6/sqrt(5) & rx<=-5/sqrt(5))) = -5;
    Matriz(find(rx< -4/sqrt(5) & rx>-5/sqrt(5))) = -5;
    Matriz(find(rx>= -4/sqrt(5) & rx<=-3/sqrt(5))) = -3;
    Matriz(find(rx< -2/sqrt(5) & rx>-3/sqrt(5))) = -3;
    Matriz(find(rx>= -2/sqrt(5) & rx<=-1/sqrt(5))) = -1;
    Matriz(find(rx< 0/sqrt(5) & rx>-1/sqrt(5))) = -1;
    Matriz(find(rx>= 0/sqrt(5) & rx<=1/sqrt(5))) = 1;
    Matriz(find(rx< 2/sqrt(5) & rx>1/sqrt(5))) = 1;
    Matriz(find(rx>= 2/sqrt(5) & rx<=3/sqrt(5))) = 3;
    Matriz(find(rx< 4/sqrt(5) & rx>3/sqrt(5))) = 3;
    Matriz(find(rx>= 4/sqrt(5) & rx<=5/sqrt(5))) = 5;
    Matriz(find(rx< 6/sqrt(5) & rx>5/sqrt(5))) = 5;
    Matriz(find(rx>= 6/sqrt(5) & rx<=7/sqrt(5))) = 7;
    Matriz(find(rx< 8/sqrt(5) & rx>7/sqrt(5))) = 7;
    Matriz(find(rx>= 8/sqrt(5) & rx<=9/sqrt(5))) = 9;
    Matriz(find(rx< 10/sqrt(5) & rx>9/sqrt(5))) = 9;
    Matriz(find(rx>= 10/sqrt(5) & rx<=11/sqrt(5))) = 11;
    Matriz(find(rx< 12/sqrt(5) & rx>11/sqrt(5))) = 11;
    Matriz(find(rx>= 12/sqrt(5) & rx<=13/sqrt(5))) = 13;
    Matriz(find(rx< 14/sqrt(5) & rx>13/sqrt(5))) = 13;
    Matriz(find(rx>= 14/sqrt(5))) = 15;
    nErr(ii) = size(find([g - Matriz]),2);     % couting the number of errors
end


%% GRAFICA PROBABILIDAD DE ERROR DE SIMBOLO VS RELACION SEÑAL A RUIDO
simBer = nErr/Nsymb;
figure;semilogy(Es_N0_dB,simBer,'mx-');axis([-3 20 10^-5 1]);grid on
legend('simulation');xlabel('Es/No, dB')
ylabel('Symbol Error Rate')
title('Symbol error Rate for 16-PAM modulation');

%% CONSTELACION DE LOS SIMBOLOS PASABANDA Tx Rx
h = scatterplot(rx*sqrt(5),[],[],'b.');grid on;hold on
scatterplot(g,[],[],'r*',h)
title('Received signal constellation');
legend('Received Symbols','Transmit Symbols');

%% DECODIFICACION DE LOS SIMBOLOS 16 PAM
tic;
symbolPamRestaured = Matriz;
indicesPamRestaured = transpose((symbolPamRestaured+(M-1))/2); 
[indice_symbolRestaured, mapeo_symbol] = gray2bin(indicesPamRestaured,'pam',M);
bits_symbolRestaured = de2bi(transpose(indice_symbolRestaured),'left-msb');
data_c_restaured = reshape(bits_symbolRestaured', 1, []);
bitsABorrar = bi2de(data_c_restaured(length(data_c_restaured)-b+1:length(data_c_restaured)));
data_restaured = data_c_restaured(1:length(data_c_restaured)-bitsABorrar-b);
C_restaured = data_restaured;
"DEMODULACION PAM16 TERMINADO"
toc

tic;
Mr = decodCanal(C_restaured);
"DECODIFICACION DE CANAL TERMINADO"
toc

tic;
out = unzipLzw(dataTotal);
"UNZIPLZW TERMINADO"
toc

image_name = 'walter.jpg';
x=double(imread(image_name));           
[r,c]=size(x);
fuenteReconstruida = str2num(out);
imagenDescomprimida = unzipImage(fuenteReconstruida,r,c);

%% IMAGEN RECIBIDA
figure;
imshow(imagenDescomprimida/255);        % Muestra la imagen descomprimida
% Below value is a measure of compression ratio, not the exact ratio
% compression_ratio=n1/n2
title('IMAGEN RECIBIDA');

%dataTotal = zipLzw(fuente,alfabeto);
% reply = unzipLzw(dataTotal);



%alfabetoRestaurado = bin2dec(reverse(string(num2str(bitAlfabeto))));
%%d = double(t)
%%sReconstruido = str2num(char(d))
%%fuente = num2str(mF');

%dPrueba = [45,49,46,48,48,49,32,48,32,48,32,48,32,49,46,48,49,32,48]
%reconstruccionPrueba = str2num(char(dPrueba))
