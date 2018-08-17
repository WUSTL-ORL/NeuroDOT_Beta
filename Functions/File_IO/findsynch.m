function [synchpts,synchtype]=findsynch(synch)

% findsynch() interprets processed synchronization pulse time traces from
% stimulus protocols. The raw synch trace should already have been
% processed by the subfunction stimsynch() within loaddata().
% 
% To use finsynch() the syntax is:
% 
% [synchpts synchtype]=findsynch(synch)
% 
% The input synch should have either one or two rows. The first row is the
% time trace of synch pulses (which tells you whether or not a pulse
% happened). The second row of synch (optional) tells you what type of
% synch pulse happened.
% 
% findsynch() detects peaks in the first row of synch. The locations of
% these peaks are returned in syncpts. The value of the second row of synch
% at these points is returned as synchtype.
% 
% Note, with the new steps file formats of the stimulus code, findsynch()
% should soon become obsolete. So, be wary of developing new programs that
% use it. 
%
% (c) 2009 Washington University in St. Louis
% All Right Reserved
%
% Licensed under the Apache License, Version 2.0 (the "License");
% You may not use this file except in compliance with the License.
% A copy of the License is available is with the distribution and can also
% be found at:
%
% http://www.apache.org/licenses/LICENSE-2.0
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
% IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
% THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
% PURPOSE, OR THAT THE USE OF THE SOFTWARD WILL NOT INFRINGE ANY PATENT
% COPYRIGHT, TRADEMARK, OR OTHER PROPRIETARY RIGHTS ARE DISCLAIMED. IN NO
% EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
% DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
% OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
% HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
% STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
% ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

% first row contains the standard deviation in each frame
synch1=squeeze(synch(1,:))-mean(synch(1,:)); 

% set peak threshold
m=0.25*max(synch1);
dt=5;
%m=2e-4;

% Peak finder
%   Minimum of height of what we'll call a peak: m
%   Allowed minimum distance between peaks: 90 (prevents double counting)
[pks,synchpts]=findpeaks(synch1,'minpeakheight',m,'minpeakdistance',dt);

% if we have Freq. info, then look at peak times.
if size(synch,1)>1
    synchtype=synch(2,synchpts);
    Ust=unique(synchtype);
    df=diff(Ust);
    if any(df==1)
        probs=find(df==1);
        Nprobs=length(probs);
        for j=1:Nprobs
            fixM=Ust((probs(j)));
            fixS=Ust((probs(j))+1);
            synchtype(synchtype==fixS)=fixM;
        end
    end
else
    synchtype=[];
end

end