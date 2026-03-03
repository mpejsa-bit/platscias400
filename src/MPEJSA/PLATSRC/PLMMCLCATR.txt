      *---------------------------------------------------------------*
      *                                                               *
      *    @ Copyright Platform Science                             *
      *                9255 towne center                            *
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
      *  Program Description                                          *
      * Monitor for TMS preplan activity in form of deletion to     *
      * power to order plan record, and execute the corresponding   *
      * deletion of preplan order by driver.                        *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  -------------------------------------*
      *                                                               *
      *                                                               *
      *****************************************************************
      //
     h option (*nodebugio)
     fmclocat   uf   e           k disk
     fpljrnctl3 uf   e           k disk

      // Prototype to call FIXWFLCAT
     dFIXLCAT          pr                  extpgm('FIXWFLCAT')                  execute command

      // Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      *-----------------------------------------------------
      * Journal Receiver Data Structure
      *-----------------------------------------------------
     d JeEntry         ds
     d  JeLen                         5  0
     d  JeSeq                        10  0
     d  JeCode                        1
     d  JeType                        2
     d  JeDate                        6
     d   JeMMDD                       4  0 overlay(JeDate:1)
     d   JeYear                       2  0 overlay(JeDate:5)
     d  JeTime                        6
     d   JeHHMM                       4  0 overlay(JeTime:1)
     d   JeSS                         2  0 overlay(JeTime:5)
     d  JeJobn                       10
     d  JeJobu                       10
     d  JeJob#                        6
     d  JePgmn                       10
     d  JeObjn                       10
     d  JeObjl                       10
     d  JeMbrn                       10
     d  JeRrn                        10  0
     d  JeFlg                         1
     d  JeCmid                       10
     d  JeRsvd                        8
     d  JeRcd                       600

     d Timex           ds
     d  Wtime                        20  0
     d   Wdate                        8  0 overlay(Wtime)
     d    Wcent                       2  0 overlay(Wdate:1)

     dMCLOCAT_Rcd    e ds                  extname(MCLOCAT)
     d                                     prefix(R_)
     dMCLOCAT_Bfr    e ds                  extname(MCLOCAT)
     d                                     prefix(B_)
     dMCLOCAT_Aft    e ds                  extname(MCLOCAT)
     d                                     prefix(A_)

      // Constants/Variables to Delay the Job
     d sysDate         s               d   inz(*sys) datfmt(*MDY)
     d recUpdate       s               n   inz(*off)
     d recCnt          s              2  0
     d wrkDate         s              8a
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd

      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
     c     *entry        plist
     c                   parm                    JeEntry
     c                   parm                    pflag             1

      /free

       select;
       //Process journal time out
       when      (pflag = '0');

       //Process journal entries
       when (pflag = '1');
         if (JeObjn = 'MCLOCAT');
           // Update last processed date/time in control file
           chain JeObjn PLJRNCTL3;
           if %found(PLJRNCTL3);
             Wtime    = %dec(%Timestamp());
             wrkDate  = %char(JeMMDD) + %char(Wcent) + %char(JeYear);
             PLjlstdt = %dec(wrkDate:8:0);
             PLjlsttm = %dec(JeTime:6:0);
             PLjlseq  = JeRrn;
             update PLJRNCTLR;

           exsr      MCLOCATsr;
           endif;
         endif;

       //Process swapping journal receivers
       when (pflag = '3');
         *inlr = *on;
       endsl;

       return;

        //---------------------------------------------------------
        //MCLOCATsr - Process MCLOCAT journal entry
        //---------------------------------------------------------
       begsr MCLOCATsr;

         select;
           when    (JeType = 'PT') or
                   (JeType = 'PX');
           MCLOCAT_Rcd = JeRcd;

           //process MC messages sent to drivrs for non-committed preplans,
           if (r_ullatdd = 0.0 And r_ullat > 0.0) Or
              (r_ullondd = 0.0 And r_ullong > 0.0);
             //interrogate status of planned drivers
             clear recCnt;
             dou %found(mclocat) or recCnt = 3;
             chain(e) (r_ulunit:r_uldate:r_ultime) mclocat;
               if not %error() and %found(mclocat);
                 recUpdate = *off;
                 if r_ullat > 0 and ullatdd = 0;
                   //convert address lat whole seconds to decimal degrees
                   eval(h) ullatdd = r_ullat / 3600;
                   recUpdate = *on;
                 endif;
                 if r_ullong > 0 and ullondd = 0;
                   //convert address lon whole seconds to decimal degrees
                   eval(h) ullondd = r_ullong / 3600 * -1;
                   recUpdate = *on;
                 endif;
                 if recUpdate;
                   update rmclocat;
                 else;
                   unlock mclocat;
                 endif;
               else;
                 recCnt += 1;
                 // Delay 1 second to allow detail writes.
                 dlycmd = %trim(dlycmd11) + %trim('1') + dlycmd12;
                 callp DLYJOB(dlycmd:%size(dlycmd));
               endif;
             enddo;
             if %found(mclocat);
               unlock mclocat;
             elseif recCnt >= 3;
               callp FIXLCAT();
             endif;
           endif;

           when    (JeType = 'UB');
           MCLOCAT_Bfr = JeRcd;

           when    (JeType = 'UP');
           MCLOCAT_Aft = JeRcd;

           //process MC messages sent to drivrs for non-committed preplans,
           if (a_ullatdd = 0.0 And a_ullat > 0.0) Or
              (a_ullondd = 0.0 And a_ullong > 0.0);
             //interrogate status of planned drivers
             chain(e) (a_ulunit:a_uldate:a_ultime) mclocat;
             if not %error();
               if %found(mclocat);
                 recUpdate = *off;
                 if a_ullat > 0 and ullatdd = 0;
                   //convert address lat whole seconds to decimal degrees
                   eval(h) ullatdd = a_ullat / 3600;
                   recUpdate = *on;
                 endif;
                 if a_ullong > 0 and ullondd = 0;
                   //convert address lon whole seconds to decimal degrees
                   eval(h) ullondd = a_ullong / 3600 * -1;
                   recUpdate = *on;
                 endif;
                 if recUpdate;
                   update rmclocat;
                 else;
                   unlock mclocat;
                 endif;
               endif;
             else;
               unlock mclocat;
               callp FIXLCAT();
             endif;
           endif;

         endsl;
       endsr;

      /end-free
