function [U,H]=crossover(X,V,CR)
[NP,Dim]=size(X);
for i=1:NP         %NP����Ⱥ������Dim:ά�ȣ�V������������U������������
    jRand=randi([1,Dim]);  %jRand��[1,Dim]
    for j=1:Dim
        k=rand;
        if k<=CR||j==jRand  %j==jRand��Ϊ��ȷ��������һ��U(i,j)=V(i,j)
            U(i,j)=V(i,j);
        else
            U(i,j)=X(i,j);
        end
        if k>CR
            H(i,j)=X(i,j);
        else
            H(i,j)=V(i,j);
        end        
    end
end
end
