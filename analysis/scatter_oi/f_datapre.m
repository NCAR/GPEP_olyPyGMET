function [Data,Xrange,Yrange] = f_datapre(xdata,ydata,Step,Xlim,Ylim)
% Res=100;  % ���񻮷ֵķ���
Maxx=Xlim(2);
Minx=Xlim(1);
Xrange=Minx:Step:Maxx;   % ��ʾ��

Maxy=Ylim(2);
Miny=Ylim(1);
Yrange=Miny:Step:Maxy;    % ��ʾ��

Num=length(Xrange);
Data=nan * zeros(Num-1,Num-1);
for i=1:Num-1   % ��
    for j=1:Num-1   % ��
        Data(i,j)=sum(ydata(:)>=Yrange(Num-i)&ydata(:)<Yrange(Num+1-i)&xdata(:)<Xrange(j+1)&xdata(:)>=Xrange(j));
    end
end
end

