%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  MATLAB Code for                                              %
%                                                               %
%  Non-dominated Sorting Genetic Algorithm II (NSGA-II)         %
%  Version 1.0 - April 2010                                     %
%                                                               %
%  Programmed By: S. Mostapha Kalami Heris                      %
%                                                               %
%         e-Mail: sm.kalami@gmail.com                           %
%                 kalami@ee.kntu.ac.ir                          %
%                                                               %
%       Homepage: http://www.kalami.ir                          %
%                                                               %
%  BinaryTournamentSelection.m : implelemnts binary tournament  %
%                                selection                      %
%                                                               %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [p q]=tournament(select)

    npop=numel(select);
    
    i=randperm(100,4);
    
    p1=select{i(1)};
    p2=select{i(2)};
    q1=select{i(3)};
    q2=select{i(4)};
    
    if p1.Rank < p2.Rank
        p=p1;
    elseif p1.Rank > p2.Rank
        p=p2;
    else
        p=p1;
    end
    
    if q1.Rank < q2.Rank
        q=q1;
    elseif q1.Rank > q2.Rank
        q=q2;
    else
        q=q1;
    end

end