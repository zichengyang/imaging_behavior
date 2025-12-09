function f = Wilcoxon_Rank_Test( x,y ,alpha);
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
Z=[x;y];
[z1,z2]=sort(Z,'ascend');
for i= 1:size(x,1)
    for j=1:size(z1,1)
        if z1(j)==x(i)
            X(i,1)=j;
        end
    end
end
end

m=size(x,1);
n=size(y,1);
Ex=m*(m+n+1)/2;
Varx=m*n*(m+n+1)/12;
c=sqrt(Varx)*norminv(1-alpha/2);
beta=sum(X,1);
if abs(beta-Ex)>c
    disp('Reject Null Hypothesis');
    f=1;
else disp('Fail to Reject Null Hypothesis');
    f=0;
end