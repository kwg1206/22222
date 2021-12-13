function  [classmat_correct,nochixy_nextsort]=correct_ClassMat(classmat)
%功能：补全classmat矩阵的通道
%输入：classmat  2040*2040*1的1-9的类别标签矩阵
%输出：classmat_correct  补全通道后的classmat
%      nochixy_nextsort 校正后classmat_correct缺通道的位置

    chindexmat0=[flipdim(classmat(2:13,:),1);classmat;flipdim(classmat(end-12:end-1,:),1)];
    chindexmat=[flipdim(chindexmat0(:,2:13),2),chindexmat0,flipdim(chindexmat0(:,end-12:end-1),2)];
    chindexmat_correct=chindexmat;
    bfindi=ones(344,344);
    no1xy=[];
    
    for i=1:344
        for j=1:344
            b66i=chindexmat(6*i-5:6*i,6*j-5:6*j);
            b66i_correct=b66i;
            %找b66i缺chi的位置
            for chi=1:9
                if isempty(find(b66i==chi))==1                                
                    bfindi(i,j)=0;
                    no1xy(end+1,:)=[i,j,chi];       

                  %% 补缺的chi，确定ch1的位置
                    % 中间位置缺chi
                    if i>2 && i<343 && j>2 && j<343
                        bb55=chindexmat(6*i-17:6*i+12,6*j-17:6*j+12);

                        %25个bb5566的36个位置上各位置处出现1的总数
                        num36=zeros(1,36);                        
                        for ii=1:5
                            for jj=1:5
                                bb5566=bb55(6*ii-5:6*ii,6*jj-5:6*jj);
                                xyi=find(bb5566==chi);
                                for ij=1:length(xyi)
                                    num36(1,xyi(ij))=num36(1,xyi(ij))+1;      
                                end                    
                            end
                        end
                        [num36_max,num36_maxindex]=max(num36);

                        i_correct=mod(num36_maxindex,6);
                        if i_correct==0
                            i_correct=6;
                        end                   
                        j_correct=floor((num36_maxindex-i_correct)/6)+1;

                        %b66i_correct=b66i;
                        b66i_correct(i_correct,j_correct)=chi;        
                        chindexmat_correct(6*i-5:6*i,6*j-5:6*j)=b66i_correct;

                    end
                end
            end

        end
    end
    classmat_correct=chindexmat_correct(13:end-12,13:end-12);
    
    
    
    
    
    
    %%
    chindexmat_next0=[flipdim(classmat_correct(2:13,:),1);classmat_correct;flipdim(classmat_correct(end-12:end-1,:),1)];
    chindexmat_next=[flipdim(chindexmat_next0(:,2:13),2),chindexmat_next0,flipdim(chindexmat_next0(:,end-12:end-1),2)];
    
    nochixy_next=[];   
    for i=1:344
        for j=1:344
            b66i_next=chindexmat_next(6*i-5:6*i,6*j-5:6*j);
            %找b66i缺chi的位置
            for chi=1:9
                if isempty(find(b66i_next==chi))==1                                
                    nochixy_next(end+1,:)=[i,j,chi];       
                end
            end
        end
    end
    
    
    if isempty(nochixy_next)==0
        [vv,inin]=sort(nochixy_next(:,3));
        nochixy_nextsort=no1xy(inin,:);

        for cxi=[1,2,343,344]
            for cxj=1:2
                nochixy_nextsort(find(nochixy_nextsort(:,cxj)==cxi),:)=[];   
            end    
        end
        
    else
        nochixy_nextsort=[];
        
    end


end