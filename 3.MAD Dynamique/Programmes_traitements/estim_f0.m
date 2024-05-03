function f0=estim_f0(x,Fe)


Np=floor(log(length(x)))/log(2);
Nfft=2^Np; 

y=fft(x(1:Nfft),Nfft);
f=Fe/Nfft:Fe/Nfft:Fe/2;
z=abs(y(1:Nfft/2));

[F_MAX] = detect_pic_local(f,z,5);

f0=min(F_MAX);






