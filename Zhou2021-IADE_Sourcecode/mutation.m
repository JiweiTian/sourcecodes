%Ϊ�˱�֤�����ԣ��ڲ����µ���Ⱥ����Ĺ����У�������nrandI��������ȵ����������i�Բ���ȣ�
%����ÿ�����ĵ� i ���¸������õ����ѡ����nrandI���ɸ��岻���ǵ� i ���ɸ��塣

function V=mutation(X,bestX,F,lamda,u)
NP=length(X);
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
    V(i,:)=u.*X(r(1),:)+(1-u).*bestX+F.*(lamda.*(X(r(2),:)-X(r(3),:))+(1-lamda).*(bestX-X(r(4),:)));   
end
