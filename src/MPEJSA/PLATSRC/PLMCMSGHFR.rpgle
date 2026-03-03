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
      *  03/20/20   R007  JB/PS  Split workflow messages into two jobs.
      *  04/03/20   R008  JB/PS  Accomodate teams for Cancel Preplan.
      *
      *****************************************************************
     FPLJRNCTLP UF   e           k disk
     Funits     if   e           k disk
AR006Fload      if   e           k disk
     Fmcmsgd    if   e           k disk
AR006Fmcmsgh    if   e           k disk
     Fplactdrvp if   e           k disk
     Fplactordl1if   e           k disk
AR006Fplfueldrvpif   e           k disk
     Fpltwfordp o    e           k disk
     Fpltaoordp o    e           k disk
      *-----------------------------------------------------
      * Journal Receiver Data Structure
      *-----------------------------------------------------
     D JeEntry         ds
     D  JeLen                         5  0
     D  JeSeq                        10  0
     D  JeCode                        1
     D  JeType                        2
     D  JeDate                        6
     D   JeMMDD                       4  0 overlay(JeDate:1)
     D   JeYear                       2  0 overlay(JeDate:5)
     D  JeTime                        6
     D   JeHHMM                       4  0 overlay(JeTime:1)
     D  JeJobn                       10
     D  JeJobu                       10
     D  JeJob#                        6
     D  JePgmn                       10
     D  JeObjn                       10
     D  JeObjl                       10
     D  JeMbrn                       10
     D  JeRrn                        10  0
     D  JeFlg                         1
     D  JeCmid                       10
     D  JeRsvd                        8
     D  JeRcd                       600
     D Dtime                         20  0
     D  Wdate                         8  0 overlay(Dtime)
     D  Wtime                         6  0 overlay(Dtime:*Next)
     D  Stamp                  3     14  0

     DMCMSGH_Rcd     e ds                  extname(MCMSGH)
     D                                     prefix(R_)
     DMCMSGH_Bfr     e ds                  extname(MCMSGH)
     D                                     prefix(B_)
     DMCMSGH_Aft     e ds                  extname(MCMSGH)
     D                                     prefix(A_)
       //procedure prototypes
     D cancelJob       PR                  ExtPgm('PLTWFCANR')
CR009D  jobID                        28a
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
     D passdate        s              7s 0
     D passtime        s              6s 0
     D RETOCC          S              7  0 INZ(*ZEROS)
AR003D M               s              1  0
AR006D t40date         s                   like(mhdate)
AR006D t40time         s                   like(mhtime)
AR006D w_didate        s                   like(mhdate)
AR006D w_ditime        s                   like(mhtime)
AR007D ffmsg           s               n   inz(*on)
AR007D wfmsg           s               n   inz(*off)
      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
     C     *entry        plist
     C                   parm                    JeEntry
     C                   parm                    pflag             1

      /free
DR005   //lcinfo();

        //first time UP journal skip it
        if (JrnFirstFlag = *on and jetype = 'UP');
          JrnFirstFlag = *off ;
        else ;
          JrnFirstFlag = *off ;

          // Update last processed date/time in control file
AR007     if ffmsg = *on;
  |         chain (%trim(JeObjn) + 'FF') PLJRNCTLP;
  |       elseif wfmsg = *on;
  |         chain (%trim(JeObjn) + 'WF') PLJRNCTLP;
AR007     else;
            chain JeObjn PLJRNCTLP;
AR007     endif;
            if %found(PLJRNCTLP) = *on;
              Dtime = %dec(%Timestamp());
              //PLjlstdt = Wdate;
     C                   movel     Wdate         @cent2            2
     C                   move      JeYear        @year2            2
     C                   move      JeMMDD        @mmdd4            4
              wrkDate  = @mmdd4 + @cent2 + @year2;
              PLjlstdt = %dec(wrkDate:8:0);
              //PLjlsttm = Wtime;
              PLjlsttm = %dec(JeTime:6:0);
              update PLJRNCTLR;
            endif;

            //Process journal time out
            select;
            when (pflag = '0');

            //Process journal entries
            when (pflag = '1');

              if (JeObjn = 'MCMSGH');
AR007           if ffmsg = *on;
  |               exsr      MCMSGHFFsr;
  |             elseif wfmsg = *on;
  |               exsr      MCMSGHWFsr;
AR007           else;
                  exsr      MCMSGHsr;
AR007           endif;
              endif;

            //Process swapping journal receivers
            when (pflag = '3');
              *inlr = *on;
            endsl;
        endif;
        return;

        //---------------------------------------------------------
        //MCMSGHFFsr - Process MCMSGH journal entry (Freeform only)
        //---------------------------------------------------------
AR007   Begsr MCMSGHFFsr;
  |
  |       select;
  |       when (JeType = 'PT' or JeType = 'PX');
  |         Mcmsgh_Aft = JeRcd;
  |         if a_mhpmid = 'T00';
  |           chain a_mhunit units;
  |           if %found(units);
  |             chain undr1 plactdrvp;
  |             if %found(plactdrvp);
  |               exsr sendT00msg;
  |
  |               //execute for new fuel stops on active drivers only.
  |               chain undr1 plfueldrvp;
  |               if %found(plfueldrvp);
  |                 exsr getT40time;
 |                 //resend workflow if current T00 is EF for current disp.
  |                 if t40time > *zero And (a_mhdate > T40date or
  |                    a_mhdate = T40date and a_mhtime >= T40time);
  |                   chain (a_mhunit:a_mhdate:a_mhtime:a_mhdir) mcmsgd;
  |                   if %found(mcmsgd) And %subst(mdmsgs:1:9) = 'IDSC/FUEL'
  |                      And %subst(mdmsgs:12:7) = unord#;
  |                     clear retocc;
  |                     retocc = %scan('NO SOLUTION':mdmsgs);
  |                     if retocc = 0;
  |                       passdate = T40date;
  |                       passtime = T40time;
  |                       createJob(a_mhunit:passdate:passtime);
  |                     endif;
  |                   endif;
  |                 endif;
  |               endif;
  |             endif;
  |           endif;
  |         endif;
  |
  |       //UPDATE (before)
  |       when (JeType = 'UB');
  |         Mcmsgh_Bfr = JeRcd;
  |
  |       //UPDATE (after)
  |       when (JeType = 'UP');
  |         Mcmsgh_Aft = JeRcd;
  |       endsl;
  |
AR007   endsr;

        //---------------------------------------------------------
        //MCMSGHWFsr - Process MCMSGH journal entry (Workflow only)
        //---------------------------------------------------------
AR007   Begsr MCMSGHWFsr;
  |
  |       select;
  |       when (JeType = 'PT' or JeType = 'PX');
  |         Mcmsgh_Aft = JeRcd;
  |         if a_mhpmid = 'T40'
  |          //or a_mhpmid = 'T58'
  |          or a_mhpmid = 'T45'
  |          or a_mhpmid = 'T54'
  |          or a_mhpmid = 'T48'
  |          or a_mhpmid = 'T46'
  |          or a_mhpmid = 'T42'
  |          or a_mhpmid = 'T33'
  |          or a_mhpmid = 'T43';
  |           chain a_mhunit units;
  |           if %found(units) = *on;
  |             chain undr1 plactdrvp;
  |             if %found(plactdrvp) = *on;
  |               select;
  |               when a_mhpmid = 'T40';
  |                 exsr createWFJob;
  |               when a_mhpmid = 'T48';
  |                 exsr createWFJobAddStop;
  |                 exsr sendT00msg;
  |                 //exsr getT40time;
  |                 //if t40time > *zero;
  |                 //  exsr createWFJob;
  |                 //endif;
  |               when a_mhpmid = 'T43';
  |                 exsr sendPPTmsg;
  |               when a_mhpmid = 'T45';
  |                 exsr sendPPmsg;
  |               when a_mhpmid = 'T46';
  |                 exsr sendCanPPmsg;
  |               when a_mhpmid = 'T54'
  |                or a_mhpmid = 'T42'
  |                or a_mhpmid = 'T33';
  |                 exsr sendT00msg;
  |               endsl;
  |             endif;
  |           endif;
  |         endif;
  |
  |       //UPDATE (before)
  |       when (JeType = 'UB');
  |         Mcmsgh_Bfr = JeRcd;
  |
  |       //UPDATE (after)
  |       when (JeType = 'UP');
  |         Mcmsgh_Aft = JeRcd;
  |       endsl;
  |
AR007   endsr;

        //---------------------------------------------------------
        //MCMSGH- Process MCMSGH journal entry
        //---------------------------------------------------------
        Begsr MCMSGHSr;

        select;
         when      (JeType = 'PT') or
                   (JeType = 'PX');
           Mcmsgh_Aft = JeRcd;
           if a_mhpmid = 'T40'
DR005    //or a_mhpmid = 'T58'
DR007    //or a_mhpmid = 'T00'
           or a_mhpmid = 'T45'
           or a_mhpmid = 'T54'
           or a_mhpmid = 'T48'
           or a_mhpmid = 'T46'
AR005      or a_mhpmid = 'T42'
AR005      or a_mhpmid = 'T33'
           or a_mhpmid = 'T43';
           chain a_mhunit units;
           if %found(units) = *on;

           chain undr1 plactdrvp;
           if %found(plactdrvp) = *on;

           select;
           when a_mhpmid = 'T40';
           exsr createWFJob;

           when a_mhpmid = 'T48';
           exsr createWFJobAddStop;
AR004      exsr sendT00msg;
AR006      //exsr getT40time;
  |        //if t40time > *zero;
  |        //  exsr createWFJob;
AR006      //endif;

           when a_mhpmid = 'T43';
           exsr sendPPTmsg;

           when a_mhpmid = 'T45';
           exsr sendPPmsg;

           when a_mhpmid = 'T46';
           exsr sendCanPPmsg;

           when a_mhpmid = 'T00';
           exsr sendT00msg;

AR006      //execute for new fuel stops on active drivers only.
  |        chain undr1 plfueldrvp;
  |        if %found(plfueldrvp);
  |          exsr getT40time;
 |          //resend workflow if current T00 is EF for current disp.
  |          if t40time > *zero And (a_mhdate > T40date or
  |             a_mhdate = T40date and a_mhtime >= T40time);
  |            chain (a_mhunit:a_mhdate:a_mhtime:a_mhdir) mcmsgd;
  |            if %found(mcmsgd) And %subst(mdmsgs:1:9) = 'IDSC/FUEL'
  |               And %subst(mdmsgs:12:7) = unord#;
  |              clear retocc;
  |              retocc = %scan('NO SOLUTION':mdmsgs);
  |              if retocc = 0;
  |                passdate = T40date;
  |                passtime = T40time;
  |                createJob(a_mhunit:passdate:passtime);
  |              endif;
  |            endif;
  |          endif;
AR006      endif;

           when a_mhpmid = 'T54'
AR005           or a_mhpmid = 'T42'
AR005           or a_mhpmid = 'T33';
           exsr sendT00msg;
           endsl;
           endif;
           endif;
           endif;

         when      (JeType = 'UB');
           Mcmsgh_Bfr = JeRcd;

        //UPDATE (after)
         when      (JeType = 'UP');
           Mcmsgh_Aft = JeRcd;
         endsl;
         endsr;
       //-------------------------------------------------------------
       //- call program to create WF job  appt or stop added ---------
       //-------------------------------------------------------------
         begsr createWFJobaddStop;
           unit# = a_mhunit;
           mode = '1';
           pplan = 'N';
           order# = *blanks;
           disp# = *blanks;
           ldmil = 0;
           mtmil = 0;
AX001     //Sendload(unit#:mode:Pplan:order#:disp#:ldmil:mtmil);
         endsr;
       //-------------------------------------------------------------
       //-------------------------------------------------------------
       //- call program to create WF job       -----------------------
       //-------------------------------------------------------------
         begsr createWFJob;
       // changed to write to a transaction processing file
         PLWFORD  = a_mhord#;
         PLWFTYPE = 'WF';
         PLWFUNIT = a_mhunit;
         PLMHDATE = a_mhdate;
         PLMHTIME = a_mhtime;
         write plwfordr;
         createjob(a_mhunit:a_mhdate:a_mhtime);
         endsr;
       //-------------------------------------------------------------
       //- send pre plan message         -----------------------
       //-------------------------------------------------------------
         begsr sendPPmsg;
       // changed to write to a transaction processing file
         PLWFORD  = a_mhord#;
         PLWFTYPE = 'PP';
         PLWFUNIT = a_mhunit;
         PLMHDATE = a_mhdate;
         PLMHTIME = a_mhtime;
         write plwfordr;
         createPPlan(a_mhunit:a_mhdate:a_mhtime);
         endsr;
       //-------------------------------------------------------------
       //- send pre t-call plan message         -----------------------
       //-------------------------------------------------------------
         begsr sendPPTmsg;
       // changed to write to a transaction processing file
         PLAOORD  = a_mhord#;
         PLAOMTYPE = a_mhpmid;
         PLaoUNIT = a_mhunit;
         PLMHDATE = a_mhdate;
         PLMHTIME = a_mhtime;
         write plaoordr;
         clear message;
         exsr getmsgbody;
AR003      clear m;
  |        dow message = *blanks And m < 3;
  |          dlycmd = %trim(dlycmd11) + %trim('1') + dlycmd12;
  |          // Delay 1 second to allow detail writes.
  |          callp DLYJOB(dlycmd:%size(dlycmd));
  |          exsr getmsgbody;
  |          m +=1;
AR003      enddo;
         deeplink = *blanks;
         sendFFmsg(driver:message:deeplink);
         endsr;
       //-------------------------------------------------------------
       //- on unpreplan removed PP from driver    --------------------
       //-------------------------------------------------------------
         begsr sendCanPPmsg;
         clear order#;
         exsr getmsgbody;
AR003      clear m;
  |        dow message = *blanks And m < 3;
  |          dlycmd = %trim(dlycmd11) + %trim('1') + dlycmd12;
  |          // Delay 1 second to allow detail writes.
  |          callp DLYJOB(dlycmd:%size(dlycmd));
  |          exsr getmsgbody;
  |          m +=1;
AR003      enddo;
         order# = %subst(messageA(2):20:7);

DR002    //cancelPPjob(order#);
AR002      cancelPPjob(order#:undr1);

DR008    //if undr2 > *blanks;
  |        //chain undr2 plactdrvp;
  |        //if %found(plactdrvp);
  |          //cancelPPjob(order#:undr2);
  |        //endif;
DR008    //endif;

         endsr;
       //-------------------------------------------------------------
       //- call program to send any ff message -----------------------
       //-------------------------------------------------------------
         begsr sendT00msg;
           //changed to write to a transaction processing file
           PLAOORD  = a_mhord#;
           PLAOMTYPE = a_mhpmid;
           PLAOUNIT = a_mhunit;
           PLMHDATE = a_mhdate;
           PLMHTIME = a_mhtime;
           write plaoordr;

           if a_mhdir = 'O';
             clear message;
             exsr getmsgbody;
AR003        clear m;
  |          dow message = *blanks And m < 3;
  |            dlycmd = %trim(dlycmd11) + %trim('1') + dlycmd12;
  |            // Delay 1 second to allow detail writes.
  |            callp DLYJOB(dlycmd:%size(dlycmd));
  |            exsr getmsgbody;
  |            m +=1;
AR003        enddo;

             deeplink = *blanks;
             retocc = %scan('DISP.INFO.':message);
             if retocc = 0;
               sendFFmsg(driver:message:deeplink);
             endif;
           endif;
         endsr;

       //-------------------------------------------------------------
       //- get message body -----------------------
       //-------------------------------------------------------------
         begsr getmsgbody;
         clear message;
         clear messageA;
         driver = %trim(undr1);
         x = 0;
         setll (a_mhunit
               :a_mhdate
               :a_mhtime
               :a_mhdir) mcmsgd;
         reade (a_mhunit
               :a_mhdate
               :a_mhtime
               :a_mhdir) mcmsgd;
         dow %eof(mcmsgd) = *off;
         x = x + 1;
         messageA(x) = %trim(mdmsgs);
         reade (a_mhunit
               :a_mhdate
               :a_mhtime
               :a_mhdir) mcmsgd;
         enddo;

         driver = %trim(undr1);
     C                   movea     messageA      message
         endsr;

       //-------------------------------------------------------------
       //- retrieve the T40 dispatch record time for reprocessing ----
       //-------------------------------------------------------------
AR006    begsr getT40Time;
  |
  |        clear t40date;
  |        clear t40time;
  |        chain (unord#:undisp) load;
  |        if %found(load) And unstat = 'D';
  |          w_didate = didate;
  |          w_ditime = %int(ditime + '00');
  |          setll (a_mhunit:w_didate:w_ditime:a_mhdir) mcmsgh;
  |          dou %eof(mcmsgh) Or (mhdir = 'O' and mhpmid = 'T40');
  |            reade a_mhunit mcmsgh;
  |            if not %eof(mcmsgh) And mhdir = 'O' And mhpmid = 'T40';
  |              t40date = mhdate;
  |              t40time = mhtime;
  |              leave;
  |            endif;
  |          enddo;
  |        endif;
AR006    endsr;

      /end-free
