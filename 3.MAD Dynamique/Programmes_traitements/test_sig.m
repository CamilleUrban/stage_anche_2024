clear all
close all

f0=100;

Nh=20;

Fs=40000;
N=1000;
t=1/Fs:1/Fs:N/Fs;
x=zeros(size(t));

RSB=20;

for k=1:Nh
A=1/k;
phi=rand(1);
    x=x+A*cos(2*pi*k*f0.*t+phi); 
end

plot(x)

[fn,amp,f0]=enveloppe(x',Fs,100,30);

%%
RMS1=std(x)
RMS2=sqrt(sum(amp.^2/2))


bruit=RMS1*10^(-RSB/20)*randn(size(t));

xbruit=x+bruit;
xbruit(1000:2000)=zeros();

T=0.1;
Ts=1.2*T;
SRMS=sqrt(T/Ts)*RMS2


[fn,amp,f0]=enveloppe(xbruit',Fs,100,30);

%%
varbruitest=var(xbruit)-RMS2^2;

fn(1)
RSBest=10*log10(RMS2^2/varbruitest)


