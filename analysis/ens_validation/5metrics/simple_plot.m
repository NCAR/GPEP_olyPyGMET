% simple plot
metnum=4;
for vv=1:varnum
    subplot(1,3,vv);
    varvv=vars{vv};
    filestn=['stn_',varvv,'.mat'];
    outfile=['metric_',varvv,'.mat'];
    load(filestn,'LLE');
    load(outfile,'metric','metname');
    met=nanmean(squeeze(metric(:,metnum,:)),2);
    scatter(LLE(:,2),LLE(:,1),5,met,'filled')
    colormap(jet)
%     if vv==1
%         caxis([0,0.7]);
%     else
%         caxis([0,1]);
%     end
    colorbar
    title([varvv,': KGE']);
end