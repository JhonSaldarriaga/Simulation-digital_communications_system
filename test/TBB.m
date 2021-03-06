clc;clear all;close all

% PRÁCTICA 3: TRANSMISIÓN EN BANDA BASE

%% BLOQUE DE FORMATEO DE LOS DATOS DE LA FUENTE
text = input('Ingrese el texto a transmitir: ','s'); % Texto de entrada
M = input('Ingrese el tamaño del alfabeto: ');  %Tamaño del alfabeto (símbolos digitales a Tx)
b = log2(M);                     % Número de bits/símbolo banda base o pasabanda

nbits = 8;
dec = double(text);          % Codifica cada carácter del texto en un número decimal
binary = de2bi(dec,nbits);   % Codifica cada número decimal en una matriz binaria de tamaño {length(text),nbits}
                              
disp('   Dec                     Binary                ')
disp('           msb                                     lsb')
disp('   -----   -------------------------------------------')
disp([double(text)', binary]);

[rows,columns] = size(binary);
data = reshape(binary,1,rows*columns);  % Transforma la matriz binary en una secuencia binaria(vector fila(1,row*columns))

figure(1);subplot(2,1,1);stem(data,'fill','r--','LineWidth',0.5);grid on;
title(['bits generated by the source = ',num2str(length(data))]);ylabel('Logic Level');
xlabel(['number of bits = ',num2str(length(data))]);

%% GRAFICAR LA SEÑAL DIGITAL EN TIEMPO DISCRETO
Nbits = length(data);	  % Número total de bits a transmitir
Tb = 1/Nbits;               % Intervalo o periodo de bit
Rb = 1/Tb;                  % Tasa de transmisión binaria (bits/s)
tb = (0:Tb:1-Tb)*10^0;     % Vector de tiempo de duración un segundo para graficar Rb

figure(1);subplot(2,1,2);stem(tb,data,'b--','fill','LineWidth',1.0);axis([0 1 0 1.1]);
xlabel('Time (s)');
ylabel('Logical Level');xlabel('Time (s)');
title([num2str(Nbits) ' bits generated by the source with bit period Tb = ',num2str(Tb*10^3), ' (ms) ']);grid on

%% BLOQUE CODIFICACIÓN DE FUENTE

%% BLOQUE CODIFICACIÓN DE CANAL



%% GENERANDO LOS SIMBOLOS BANDA BASE
Nsymb = Nbits/b;   % Numero de símbolos digitales banda base a TX, debe ser un número entero

% Para comprobar si Nsymb es un número entero
mod(Nbits,b);   % Si Nsymb es un entero, entonces mod(Nbits,b)=0 (El resto debe ser igual a cero)
% Si Nsymb NO ES ENTERO, SE DEBE CONCATENAR LA SECUENCIA BINARIA Nbits
data_c = 0;               % Inicializando la variable
if mod(Nbits,b)==0;   % Si el módulo o resto es igual a cero (es un entero), no se adicionan ceros a los datos originales
   data_c = [data de2bi(0,b)];         % los datos concatenados son iguales a los datos originales
elseif mod(Nbits,b)~= 0;                 % Para verificar si el modulo o resto es distinto de cero
       concat = zeros(1,b-mod(Nbits,b)); % Numero de ceros que se deben adicionar a los datos originales
       data_c = [data concat de2bi(b-mod(Nbits,b),b)];             % Datos originales concatenados con los ceros
end
Nbits_c = length(data_c);   % La nueva secuencia binaria con datos concatenados
mod(Nbits_c,b);             % Para comprobar que sea un numero entero, debe dar igual a cero

%% SE SEGMENTA LA NUEVA SECUENCIA BINARIA (número de símbolos o mensajes digitales banda base mi a transmitir)
Nsymb = Nbits_c/b;      % Numero de símbolos digitales
Ts = 1/Nsymb;           % Intervalo o periodo de símbolo banda base
Rs = 1/Ts;              % Tasa de transmisión de símbolos banda base (símbolos/s)
ts = 0:Ts:1-Ts;         % Vector de tiempo para graficar el código de línea

%% CODIFICACIÓN GRAY PARA CADA UNO DE LOS SIMBOLOS DIGITALES mi
bits_symbol = zeros(b,Nsymb);
bits_symbol(:)= data_c;

indice_symbol = bi2de(transpose(bits_symbol),'left-msb');       %LISTA CADA SIMBOLO A ENVIAR Y SU VALOR EN DECIMAL
A = 1;                                                          % distancia de separación de los símbolos M-PAM

[indices_pam,mapeo_pam] = bin2gray(indice_symbol,'pam',M);      % Codificación Gray de los símbolos

symbol_pam = transpose(indices_pam*2-(M-1));                    % VALORES DE VOLTAJE ai

figure(2);subplot(2,1,1);stem(ts,symbol_pam,'fill','r--','LineWidth',1.5); grid on;
title([num2str(Nsymb),' digital symbols to transmit with symbol period Ts = ', num2str(Ts*10^3),' (ms) ']);
xlabel('Time (s) ');ylabel('Voltaje Level ai (V)');grid on



Fs = 10^3;                  
Nsamples = Nsymb*Fs;       % Sampling frecuency
Tsam = 1/Nsamples;         % Periodo o intervalo de muestreo
ts = 0:Tsam:1-Tsam;        % Vector de tiempo para graficar el código de línea
Matriz = ones(Fs,1);
data1 = Matriz*symbol_pam;
data2 = data1(:);

figure(2);subplot(2,1,2); plot(ts,data2,'b','LineWidth',1.8);axis([0 1 (2-1-M)-1 (2*M-1-M)+1]);
xlabel('Continuos Time (s)');ylabel('Amplitude');grid on;
title(['Line Code Multilevel Binary ', num2str(M),'-PAM with symbol period Ts = ', num2str(Ts*10^3),' (ms) ']);
grid on;

Energia = mean(data2.^2)



%% PASAR LOS SIMBOLOS BANDA BASE POR EL CANAL AWGN (Solo adiciona ruido estocástico)
g = symbol_pam;                        % Símbolos banda base a transmitir
scatterplot(g,[],[],'r-*');grid on;    % Constelación de los símbolos banda base antes de entrar al canal
title('Transmit signal constellation');hold on
legend('Transmit signal');


% RELACIÓN SNR PARA EL CANAL AWGN
Es_N0_dB = [-3:1:20];        % Vector de relación señal a ruido para los símbolos values
Matriz = zeros(1,Nsymb);   % Matriz de Zeros

s = (1/sqrt(5))*g;         % normalization of energy of the baseband symbols, pulso conformador
n = 1/sqrt(2)*[randn(1,Nsymb) + j*randn(1,Nsymb)]; % AWGN; mean=0 dB
alpha = rand(1,length(Es_N0_dB));  % Attenuation factor

for ii = 1:length(Es_N0_dB)
y = s + 10^(-Es_N0_dB(ii)/20)*n;   % Transmited signal with only AWGN

% y = s*alpha(ii) + 10^(-Es_N0_dB(ii)/20)*n;   % Transmited signal with AWGN and attenuation

rx = real(y);                       % Rx signal and taking only the real part of de y
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

simBer = nErr/Nsymb;
theoryBer = 0.75*erfc(sqrt(0.2*(10.^(Es_N0_dB/10))));
figure;semilogy(Es_N0_dB,theoryBer,'b.-');hold on
semilogy(Es_N0_dB,simBer,'mx-');axis([-3 20 10^-5 1]);grid on
legend('theory', 'simulation');xlabel('Es/No, dB')
ylabel('Symbol Error Rate')
title('Symbol error Rate and Symbol Error Probability for 4-PAM modulation');

h = scatterplot(rx*sqrt(5),[],[],'b.');grid on;hold on
scatterplot(g,[],[],'r*',h)
title('Received signal constellation');
legend('Received Symbols','Transmit Symbols');

%% DEMODULACION
symbolPamRestaured = Matriz;
indicesPamRestaured = transpose((symbolPamRestaured+(M-1))/2); 
[indice_symbolRestaured, mapeo_symbol] = gray2bin(indicesPamRestaured,'pam',M);
bits_symbolRestaured = de2bi(transpose(indice_symbolRestaured),'left-msb');
data_c_restaured = reshape(bits_symbolRestaured', 1, []);
bitsABorrar = bi2de(data_c_restaured(length(data_c_restaured)-b+1:length(data_c_restaured)));
data_restaured = data_c_restaured(1:length(data_c_restaured)-bitsABorrar-b);
C_restaured = data_restaured;

