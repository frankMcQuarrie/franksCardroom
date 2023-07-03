% runtestsM
% runs a battery of test problems for the Acoustics Toolbox

clear all

% general tests

% SPARC
sparcM( 'iso' )
plottsmat iso
%%
% bounce
bounce( 'refl' )
plotbrc( 'refl' )

%%
cases = [ ...
   'free       '; ...
   'VolAtt     '; ...
   'halfspace  '; ...
   'calib      '; ...
   'Munk       '; ...
   'sduct      '; ...
   'Dickins    '; ...
   'arctic     '; ...
   'SBCX       '; ...
   'BeamPattern'; ...
   'TabRefCoef '; ...
   'PointLine  '; ...
   'ParaBot    '; ...
   'Ellipse    '; ...
   'block      '; ...
   'step       '; ...
   %           'terrain    '; ...
   %           '3DAtlantic '; ...
   %           'wedge      '; ...
   'head       '; ...
   %           'TLslices   '; ...
   ];

 
for icase = 1 : size( cases, 1 )
   directory = deblank( cases( icase, : ) )
   eval( [ 'cd ' directory ] );
   % launch matlab in the background
   %eval( [ '! ' matlabroot '/bin/matlab -r runtestsM &' ] )
   runtestsM
   cd ..
end
