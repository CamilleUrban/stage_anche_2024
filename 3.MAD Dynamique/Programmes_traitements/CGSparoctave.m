function CGS_out=CGSparoctave(ampint,f1)




b=find(170<f1 & f1<=340 );
CGS_out(1)=(sum(ampint(b).*f1(b))/sum(ampint(b)));

c=find(340<f1 & f1<=680 );
CGS_out(2)=(sum(ampint(c).*f1(c))/sum(ampint(c)));

d=find(680<f1 & f1<=1360 );
CGS_out(3)=(sum(ampint(d).*f1(d))/sum(ampint(d)));

e=find(1360<f1 & f1<=2720 );
CGS_out(4)=(sum(ampint(e).*f1(e))/sum(ampint(e)));

f=find(2720<f1 & f1<=5440 );
CGS_out(5)=(sum(ampint(f).*f1(f))/sum(ampint(f)));


% figure;
% % semilogx(63:1:125,CGS(1),'b')
% % hold on
% semilogx(125:1:250,CGS_out(2),'b')
% hold on
% semilogx(250:1:500,CGS_out(3),'b')
% hold on
% semilogx(500:1:1000,CGS_out(4),'b')
% hold on
% semilogx(1000:1:2000,CGS_out(5),'b')
% hold on
% semilogx(2000:1:4000,CGS_out(6),'b')
% pause





