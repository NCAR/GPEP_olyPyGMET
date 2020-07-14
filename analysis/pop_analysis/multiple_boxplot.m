function multiple_boxplot(data,xlab,Mlab,colors)
% data is a cell matrix of MxL where in each element there is a array of N
% length. M is how many data for the same group, L, how many groups.
%
% Optional:
% xlab is a cell array of strings of length L with the names of each
% group
%
% Mlab is a cell array of strings of length M
%
% colors is a Mx4 matrix with normalized RGBA colors for each M.
% check that data is ok.
if ~iscell(data)
    error('Input data is not even a cell array!');
end
% Get sizes
M=size(data,2);
L=size(data,1);
if nargin>=4
    if size(colors,2)~=M
        error('Wrong amount of colors!');
    end
end
if nargin>=2
    if length(xlab)~=L
        error('Wrong amount of X labels given');
    end
end
% Calculate the positions of the boxes
positions=1:0.25:M*L*0.25+1+0.25*L;
positions(1:M+1:end)=[];
% Extract data and label it in the group correctly
x=[];
group=[];
for ii=1:L
    for jj=1:M
        aux=data{ii,jj};
        x=vertcat(x,aux(:));
        group=vertcat(group,ones(size(aux(:)))*jj+(ii-1)*M);
    end
end
% Plot it
boxplot(x,group, 'positions', positions);
% Set the Xlabels
aux=reshape(positions,M,[]);
labelpos = sum(aux,1)./M;
set(gca,'xtick',labelpos)
if nargin>=2
    set(gca,'xticklabel',xlab);
else
    idx=1:L;
    set(gca,'xticklabel',strsplit(num2str(idx),' '));
end
    
% Get some colors
if nargin>=4
    cmap=colors;
else
    cmap = hsv(M);
    cmap=vertcat(cmap,ones(1,M)*0.5);
end
% color=repmat(cmap, 1, L);
color0=[0.0196    0.1882    0.3804;...
    0.6667    0.8235    0.8980;...
    0.9725    0.7216    0.5961;...
    0.4039         0    0.1216;...
    0	0	1];  % m_colmap('diverge',4)
color_scheme=zeros(15,3);
color_scheme(1:4,:)=repmat(color0(1,:),4,1);
color_scheme(5:8,:)=repmat(color0(2,:),4,1);
color_scheme(9:12,:)=repmat(color0(3,:),4,1);
color_scheme(13:14,:)=repmat(color0(4,:),2,1);
color_scheme(15:16,:)=repmat(color0(5,:),2,1);

color_scheme=color_scheme';
color=zeros(3,32);
color(:,1:2:end)=color_scheme;
color(:,2:2:end)=color_scheme;
color=fliplr(color);

colorfaal=zeros(1,34);
colorfaal(1:2:end)=0.2;
colorfaal(2:2:end)=0.7;
% Apply colors
h = findobj(gca,'Tag','Box');
for jj=1:length(h)
   patch(get(h(jj),'XData'),get(h(jj),'YData'),color(1:3,jj)','facealpha',colorfaal(jj));
end
% if nargin>=3
%     legend(fliplr(Mlab));
% end

h=findobj(gca,'tag','Outliers');
outcolor=[0.7 0.7 0.7];
for kk = 1:length(h)
    set(h(kk),'MarkerFaceColor',outcolor);
%     alpha(0.7)
%     h(kk).MarkerEdgeColor = outlier_marker_edgeColor;
%     set(h(kk),'MarkerEdgeColor',outlier_marker_edgeColor);
    set(h(kk),'MarkerEdgeColor',outcolor);
%     h(kk).MarkerSize = outlier_markerSize;
    set(h(kk),'MarkerSize',0.4);

end

%median line
lines = findobj(gcf, 'type', 'line', 'Tag', 'Median');
set(lines, 'Color', 'k');
end