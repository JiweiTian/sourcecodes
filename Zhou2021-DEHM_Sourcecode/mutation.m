%Ϊ�˱�֤�����ԣ��ڲ����µ���Ⱥ����Ĺ����У�������nrandI��������ȵ����������i�Բ���ȣ�
%����ÿ�����ĵ� i ���¸������õ����ѡ����nrandI���ɸ��岻���ǵ� i ���ɸ��塣
function V=mutation(X,bestX,F,flag,finalx)
% function V=mutation(X,bestX,F,lamda,u,flag,finalx)
NP=size(X,1);
for i=1:NP
    %��[1 NP]�в���nrandI��������ȵ������������i�Բ����
    nrandI=4;
    r=randi([1,NP],1,nrandI);
    for j=1:nrandI
        equalr(j)=sum(r==r(j));
    end
    equali=sum(r==i);
    equalall=sum(equalr)+equali;
    while(equalall>nrandI) %�����������������ȵĻ���i��ȵġ�����Ҫ�������������
        r=randi([1,NP],1,nrandI);
        for j=1:nrandI
            equalr(j)=sum(r==r(j));
        end
        equali=sum(r==i);
        equalall=sum(equalr)+equali;
    end
    if flag==0

         V(i,:)=X(i,:)+F.*(finalx-X(r(1),:))+F.*(bestX-X(r(2),:));   
    else
         temp=0.2*NP;
         k1=0;k2=0;
         while k1==k2
         k1=ceil(temp*rand);
         k2=ceil(temp*rand);
    end
      V(i,:)=X(i,:)+F.*(X(k1,:)-X(r(1),:))+F.*(X(k2,:)-X(r(2),:));   
    end
end
