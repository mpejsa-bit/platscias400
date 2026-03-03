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
      *
      *****************************************************************
     h*OPTION (*NODEBUGIO)
     fPLACTDRVP IF   e           k disk
     fPLORDRQL1 UF   e           k disk
     fMCMSGD    IF   e           k disk
     fUNITS     IF   e           k disk

      // Prototype to call DLYJOB command
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Prototype to call SBMJOB command
     dSBMJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Constants/Variables to Delay Job
     d dlycmd          s            150a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd

      // Constants/Variables to Submit Job
     d sbmcmd          s           5500a   inz(*blanks)                         delay job cmd
     d sbmcmd11        c                   const('SBMJOB CMD(CALL PGM(')
     d sbmcmd12        c                   const(')) JOB(PLATSCIQ) JOBQ(*LIBL/-
     d                                     PLATSCI)')

      *  Program Information
     D progstatus     sds
     D parms             *parms
     D progname          *proc
     D errMsgId               40     46

     D driver          s             10a
     D deeplink        s             50a
     D message         s           5000a
     D  message1       s             40a
     D  message2       s             40a
     D  message3       s             40a
     D  message4       s             40a
     D  message5       s             40a
     D  messageA       s             40a   dim(50)
     D x               s              3  0
     D retocc          S              7  0 INZ(*ZEROS)
     D procflag        s              1    INZ('N')
     D dirn            s              1    INZ('O')
     D unit#           s              6
     D order#          s              7
     D disp#           s              2
AX001D ldmil           s              4  0
AX001D mtmil           s              4  0
AX001D pplan           s              1a
AX001D mode            s              1a

AX001D Q               c                   CONST('''')

     iPLWFORDR      01
     iPLAOORDR      02

      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
      /free

       dou procflag = 'Y';
          // process open records
          setll *loval PLORDRQL1;
          dou %eof(PLORDRQL1);

             *in01 = *off;
             *in02 = *off;
             read PLORDRQL1;

             if not %eof(PLORDRQL1) and *IN01;
                chain plwfunit UNITS;
                if %found(UNITS) and undel <> 'D';
                 //chain undr1 PLACTDRVP;
                 //if %found(PLACTDRVP);
                      select;
                      when plwftype = 'WF';
                         exsr createWFJob;
                      when plwftype = 'PP';
                         exsr sendPPMsg;
                      endsl;
                 //endif;
                endif;
             endif;

             if not %eof(PLORDRQL1) and *IN02;
                chain plaounit UNITS;
                if %found(UNITS) and undel <> 'D';
                   chain undr1 PLACTDRVP;
                   if %found(PLACTDRVP);
                      select;
                      when plaomtype = 'T00';
                       //exsr sendT00Msg;
                      when plaomtype = 'T43';
                       //exsr sendPPTMsg;
                      endsl;
                   endif;
                endif;
             endif;
          enddo;

          dlycmd = %trim(dlycmd11) + %trim('15') + dlycmd12;
          // Delay before reprocessing
          callp DLYJOB(dlycmd:%size(dlycmd));
       enddo;

       return;

       //-------------------------------------------------------------
       //- call program to create WF job       -----------------------
       //-------------------------------------------------------------
         begsr createWFJob;
         //createjob(plmhunit:plmhdate:plmhtime);

         sbmcmd = %trim(sbmcmd11 + 'PLTWFJOBR) PARM(' + Q +
                  plwfunit + Q + ' X' + Q + %editc(plmhdate:'X') +
                  'F' + Q + ' X' + Q + '0' + %editc(plmhtime:'X') +
                  'F' + Q + sbmcmd12);

         // Issue the SBMJOB command
         monitor;
         callp SBMJOB(sbmcmd:%size(sbmcmd));
         on-error;
            plwfrety +=1;
            update plwfordr;
            leaveSr;
         endmon;

         if errmsgID = *blanks;
            plwfprdate = %timestamp();
            plwfproc = 'Y';
         else;
            plwfrety +=1;
         endif;

         update plwfordr;

          // Temp delay for debugging
          //dlycmd = %trim(dlycmd11) + %trim('3') + dlycmd12;
          //callp DLYJOB(dlycmd:%size(dlycmd));
         endsr;
       //-------------------------------------------------------------
       //- send pre plan message         -----------------------
       //-------------------------------------------------------------
         begsr sendPPmsg;
         //createPPlan(plmhunit:plmhdate:plmhtime);

         sbmcmd = %trim(sbmcmd11 + 'PLTPPJOBR) PARM(' + Q +
                  plwfunit + Q + ' X' + Q + %editc(plmhdate:'X') +
                  'F' + Q + ' X' + Q + '0' + %editc(plmhtime:'X') +
                  'F' + Q + sbmcmd12);

         // Issue the SBMJOB command
         monitor;
         callp SBMJOB(sbmcmd:%size(sbmcmd));
         on-error;
            plwfrety +=1;
            update plwfordr;
            leaveSr;
         endmon;

         if errmsgID = *blanks;
            plwfprdate = %timestamp();
            plwfproc = 'Y';
         else;
            plwfrety +=1;
         endif;

         update plwfordr;

          // Temp delay for debugging
          //dlycmd = %trim(dlycmd11) + %trim('3') + dlycmd12;
          //callp DLYJOB(dlycmd:%size(dlycmd));
         endsr;
       //-------------------------------------------------------------
       //- send pre t-call plan message         -----------------------
       //-------------------------------------------------------------
         begsr sendPPTmsg;
         clear message;
         exsr getmsgbody;
         deeplink = *blanks;
         //sendFFmsg(driver:message:deeplink);

         sbmcmd = %trim(sbmcmd11 + 'PLMSGFFR) PARM(' + Q +
                  %trim(driver) + Q + ' ' + Q + %trim(message) +
                  Q + ' ' + Q + %trim(deeplink) + Q + sbmcmd12);

         // Issue the SBMJOB command
         monitor;
         callp SBMJOB(sbmcmd:%size(sbmcmd));
         on-error;
            plaorety +=1;
            update plaoordr;
            leaveSr;
         endmon;

         if errmsgID = *blanks;
            plaotime = %timestamp();
            plaoproc = 'Y';
         else;
            plaorety +=1;
         endif;

         update plaoordr;
         endsr;
       //-------------------------------------------------------------
       //- call program to send any ff message -----------------------
       //-------------------------------------------------------------
         begsr sendT00msg;

         clear message;
         exsr getmsgbody;
         deeplink = *blanks;
         retocc = %scan('DISP.INFO.':message);
         if retocc = 0;
            //sendFFmsg(driver:message:deeplink);

            sbmcmd = %trim(sbmcmd11 + 'PLMSGFFR) PARM(' + Q +
                     %trim(driver) + Q + ' ' + Q + %trim(message) +
                     Q + ' ' + Q + %trim(deeplink) + Q + sbmcmd12);

            // Issue the SBMJOB command
            monitor;
            callp SBMJOB(sbmcmd:%size(sbmcmd));
            on-error;
               plaorety +=1;
               update plaoordr;
               leaveSr;
            endmon;

            if errmsgID = *blanks;
               plaotime = %timestamp();
               plaoproc = 'Y';
            else;
               plaorety +=1;
            endif;

            update plaoordr;
         endif;
         endsr;
       //-------------------------------------------------------------
       //- get message body -----------------------
       //-------------------------------------------------------------
         begsr getmsgbody;
         clear message;
         clear messageA;
         driver = %trim(pldrvcode);
         x = 0;
         setll (plaounit
               :plmhdate
               :plmhtime
               :dirn) mcmsgd;
         reade (plaounit
               :plmhdate
               :plmhtime
               :dirn) mcmsgd;
         dow %eof(mcmsgd) = *off;
            x = x + 1;
            messageA(x) = %trim(mdmsgs);
            reade (plaounit
                  :plmhdate
                  :plmhtime
                  :dirn) mcmsgd;
         enddo;
     C                   movea     messageA      message
         endsr;
      /end-free
