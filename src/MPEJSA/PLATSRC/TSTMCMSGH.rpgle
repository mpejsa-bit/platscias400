     H OPTION (*NODEBUGIO)
      *---------------------------------------------------------------*
      *                                                               *
      *    @ Copyright Platform Science                             *
      *                9255 towne center                           *
      *                San Diego , CA 92121                         *
      *                                                               *
      * This software is licensed material of Platform Science and  *
      * may only be used consistent with the license granted.  No   *
      * part of this material may be reproduced, tranferred, or     *
      * copied for any purpose without the express written permis-  *
      * sion of Platform Science.      Copyright 2019.              *
      *                                                               *
      *                                                               *
      *---------------------------------------------------------------*
      *  Program Description
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *  12/05/19   R002  JB/PS  Add driver to Cancel Preplan API.
      *  12/20/19   R003  JB/PS  Execute delay if no message detail.
      *  12/21/19   R004  JB/PS  Add T48 as FF message.
      *  12/26/19   R005  JB/PS  Account for all MC outbound messages.
      *  01/08/20   R006  JB/PS  Submit workflow on new IDSC Fuel record.
      *
      *****************************************************************
AR006Fload      if   e           k disk
     Funits     if   e           k disk
     Fmcmsgh    if   e           k disk
       //procedure prototypes
     D cancelJob       PR                  ExtPgm('PLTWFCANR')
     D  unit                          6a
     D cancelPPJob     PR                  ExtPgm('PLTPPCANR')
     D  order#                        7a
AR002D  drvcde                        6a   options(*nopass)
     D createJob       PR                  ExtPgm('PLTWFJOBR')
     D  unit                          6a
     D  passdate                      7s 0
     D  passtime                      6s 0
     D createPPlan     PR                  ExtPgm('PLTPPJOBR')
     D  unit                          6a
     D  passdate                      7s 0
     D  passtime                      6s 0
     D sendFFmsg       PR                  ExtPgm('PLMSGFFR')
     D  driver                       10a
     D  message                    5000a
     D  deeplink                     50a
      //

      // Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd
       //procedure prototypes
AX001D lcinfo          Pr                  Extpgm('LCINFO')
       //procedure prototypes
AX001D SendLoad        Pr                  Extpgm('MC0047')
AX001D                                6a
AX001D                                1a
AX001D                                1a
AX001D                                7a
AX001D                                2a
AX001D                                4  0
AX001D                                4  0
AX001D  unit#          s              6a
AX001D  mode           s              1a
AX001D  Pplan          s              1a
AX001D  order#         s              7a
AX001D  disp#          s              2a
AX001D  ldmil          s              4  0
AX001D  mtmil          s              4  0
      *-----------------------------------------------------
      * message segment to retrieve order# and dispatch
      *-----------------------------------------------------
     D Segment         ds
     D  txtord                        9
     D  seqord                        7
     D  txtdisp                       9
     D  seqdisp                       2

     D  SysDate        s               d   inz(*sys) datfmt(*MDY)
     DJrnFirstFlag     s              1a   INZ(*on)

     D wrkDate         s              8a
     D Code            s              6a
     D Status          s              1a
     D rec#            s              2  0
     d jobID           S             28A   Inz(*blanks)
     D  driver         s             10a
     D  DeepLink       s             50a
     D  message        s           5000a
     D  message1       s             40a
     D  message2       s             40a
     D  message3       s             40a
     D  message4       s             40a
     D  message5       s             40a
     D  messageA       s             40a   dim(50)
     D X               s              3  0
     D  passdate       s              7  0
     D  passtime       s              6  0
     D RETOCC          S              7  0 INZ(*ZEROS)
AR003D M               s              1  0
AR006D t40time         s              6  0
      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
     C     *entry        plist
     C                   parm                    truck             6
     C                   parm                    mdate             7
     C                   parm                    mtime             6

      /free

AR006      mhunit = truck;
AR006      mhdate = %int(mdate);
AR006      mhtime = %int(mtime);
AR006      mhdir  = 'O';
           chain mhunit units;
  |        if %found(units);
AR006        exsr getT40time;
  |          if t40time > *zero;
  |            exsr createWFJob;
AR006        endif;
AR006      endif;
AR006      *inlr = *on;

       //-------------------------------------------------------------
       //- retrieve the T40 dispatch record time for reprocessing ----
       //-------------------------------------------------------------
AR006    begsr getT40Time;
  |
  |        clear t40time;
  |        chain (unord#:undisp) load;
  |        if %found(load) And unstat = 'D';
  |          setll (mhunit:mhdate:mhtime:mhdir) mcmsgh;
  |          dou %eof(mcmsgh) Or mhdate < didate Or
  |             (mhdate = didate and
  |             %subst(%char(mhtime):1:4) < ditime);
  |            readpe mhunit mcmsgh;
  |            if not %eof(mcmsgh) And mhdir = 'O' And mhpmid = 'T40';
  |              t40time = mhtime;
  |              leave;
  |            endif;
  |          enddo;
  |        endif;
AR006    endsr;
  |
       //-------------------------------------------------------------
       //- call program to create WF job       -----------------------
       //-------------------------------------------------------------
         begsr createWFJob;
           //createjob(mdunit:mddate:t40time);
         endsr;

      /end-free
