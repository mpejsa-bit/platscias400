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
      *  04.03.20  R001  JB/PS  Augment for teams on Cancel Preplan.  *
      *****************************************************************
      //
     h option (*nodebugio)
     fdrivers   if   e           k disk
     fmcmsgd    if   e           k disk
     fmcmsgh    if   e           k disk
     fplactdrvp if   e           k disk
     fpljrnctl2 uf   e           k disk
     fpltppordp o    e           k disk
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
     d Dtime           ds

     d Timex           ds
     d  Wtime                        20  0
     d   Wdate                        8  0 overlay(Wtime)
     d    Wcent                       2  0 overlay(Wdate:1)

     dOPPLAN_Rcd     e ds                  extname(OPPLAN)
     d                                     prefix(R_)
     dOPPLAN_Bfr     e ds                  extname(OPPLAN)
     d                                     prefix(B_)
     dOPPLAN_Aft     e ds                  extname(OPPLAN)
     d                                     prefix(A_)
       //procedure prototypes
     d cancelPPJob     pr                  ExtPgm('PLTPPCANR')
     d  order#                        7a
     d  drvcde                        6a   options(*nopass)

     d createPPlan     PR                  ExtPgm('PLTPPJOBR')
     d  unit                          6a
     d  date                          7s 0
     d  time                          6s 0

     d lcInfo          pr                  Extpgm('LCINFO')

     d datCon          pr                  Extpgm('DATCON')
     d                                7  0
     d                                6a

      // Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd

      *-----------------------------------------------------
      * message segment to retrieve order# and dispatch
      *-----------------------------------------------------
     d Segment         ds
     d  txtord                        9
     d  seqord                        7
     d  txtdisp                       9
     d  seqdisp                       2

     d  SysDate        s               d   inz(*sys) datfmt(*MDY)
     dJrnFirstFlag     s              1a   INZ(*on)

     d unit            s              6a
     d date            s              7s 0
     d time            s              6s 0
     d w_juldat        s              7  0
     d w_grgDat        s              6a
     d w_jetime        s              6s 0
     d w_dir           s              1a
     d w_type          s              2a
     d w_order#        s              7a
     d wrkDate         s              8a
     d Code            s              6a
     d Status          s              1a
     d rec#            s              2s 0
     d jobID           S             28a   Inz(*blanks)
     d  driver         s             10a
     d  DeepLink       s             50a
     d  message        s           5000a
     d  message1       s             40a
     d  message2       s             40a
     d  message3       s             40a
     d  message4       s             40a
     d  message5       s             40a
     d  messageA       s             40a   dim(50)
     d X               s              3s 0
      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
     c     *entry        plist
     c                   parm                    JeEntry
     c                   parm                    pflag             1

      /free
        //lcinfo();

        //first time UP journal skip it
        if        (JrnFirstFlag = *on) and
                  (jetype = 'UP') ;
          JrnFirstFlag = *off ;
        else ;
          JrnFirstFlag = *off ;

          // Update last processed date/time in control file
          chain JeObjn PLJRNCTL2;
          if %found(PLJRNCTL2) = *on;
            Wtime    = %dec(%Timestamp());
            wrkDate  = %char(JeMMDD) + %char(Wcent) + %char(JeYear);
            PLjlstdt = %dec(wrkDate:8:0);
            PLjlsttm = %dec(JeTime:6:0);
            update PLJRNCTLR;
          endif;

          select;
            //Process journal time out
            when      (pflag = '0');

            //Process journal entries
            when      (pflag = '1');

              if      (JeObjn = 'OPPLAN');
                 exsr      OPPLANsr;
              endif;

           //Process swapping journal receivers
            when      (pflag = '3');
              *inlr = *on;
          endsl;
          endif;
        return;

        //---------------------------------------------------------
        //OPPLANsr - Process OPPLAN journal entry
        //---------------------------------------------------------
       begsr OPPLANsr;

         select;
           when    (JeType = 'DL') or
                   (JeType = 'DX');
           OPPLAN_Aft = JeRcd;

           //process MC messages sent to drivrs for non-committed preplans,
           //which are potentially outstanding on driver tablet
           //if a_opsent = 'Y' and a_opc4st <> 'Y';
           if a_opsent = 'Y';
             //delay for 10 seconds to accomodate dispatch scenario
             dlycmd = %trim(dlycmd11) + %trim('10') + dlycmd12;
             callp DLYJOB(dlycmd:%size(dlycmd));
             //interrogate status of planned drivers
             chain a_opqvcd drivers;
             if %found(drivers);
               //exit if planned order is now dispatched on driver
               if drord# = a_opord# and drstat = 'D';
                 leavesr;
               endif;
               //only process if an active PS driver
               setll a_opqvcd plactdrvp;
               if %equal(plactdrvp);
                 w_dir = 'O';
                 clear w_juldat;
                 //convert to julian format-
                 datCon(w_juldat:jedate);
                 //start 10 seconds later for dispatch scenario.
                 if jeSS >= 50;
                 w_jetime = %int(jetime) + 50;
                 else;
                 w_jetime = %int(jetime) + 10;
                 endif;
                 exsr ChkCanPPmsg;
               endif;
             endif;
           endif;

           when    (JeType = 'UB');
           OPPLAN_Bfr = JeRcd;

           when    (JeType = 'UP');
           OPPLAN_Aft = JeRcd;

         endsl;
       endsr;
       //-------------------------------------------------------------
       //- TMS order unplan; delete PP from driver -------------------
       //-------------------------------------------------------------
       begsr chkCanPPmsg;

         setgt (a_opd8cd:w_juldat:w_jetime:w_dir) mcmsgh;
         dou %eof(mcmsgh) or (w_juldat - mhdate) > 2;
         readpe (a_opd8cd) mcmsgh;
           if not %eof(mcmsgh) and mhdir = 'O'
                  and (mhpmid = 'T40' or mhpmid = 'T41' or
                       mhpmid = 'T45' or mhpmid = 'T46');
             setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
             dou %eof(mcmsgd);
             reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
               if not %eof(mcmsgd);
                 select;
                 when mhpmid = 'T45' and mdrec# = 03;
                   w_order# = %subst(mdmsgs:9:7);
                   //log and remove outstanding preplan message
                   if w_order# = a_opord#;
                     w_type = 'PP';
                     exsr writePPrec;
                     leavesr;
                   endif;
                 when mhpmid = 'T46' and mdrec# = 02;
                   w_order# = %subst(mdmsgs:20:7);
                   //ignore unplan message previously removed
                   if w_order# = a_opord#;
                   //w_type = 'UP';
                   //exsr writePPrec;
                     leavesr;
                   endif;
                 when (mhpmid = 'T40' and mdrec# = 02 or
                       mhpmid = 'T41' and mdrec# = 02)
                  and (%subst(mdmsgs:7:4) = 'LA00' or
                       %subst(mdmsgs:7:4) = 'LA90');
                   w_order# = %subst(mdmsgs:20:7);
                   //ignore preplan message removal for dispatch
                   if w_order# = a_opord#;
                     leavesr;
                   endif;
                 endsl;
               endif;
             enddo;
           endif;
         enddo;

       endsr;
       //-------------------------------------------------------------
       //- write preplan record to log.           --------------------
       //-------------------------------------------------------------
       begsr writePPrec;

        //write to a preplan processing file
        plppord  = a_opord#;
        plpptype = w_type;
        plppunit = a_opd8cd;
        plppdrv1  = a_opqvcd;
        plppdrv2  = a_opqwcd;
        plppdate = w_juldat;
        plpptime = %int(jetime);
        write plppordr;

        cancelPPjob(a_opord#:a_opqvcd);

        if a_opqwcd > *blanks;
          //interrogate status of planned drivers
          chain a_opqwcd drivers;
          if %found(drivers);
            //exit if planned order is now dispatched on driver
            if drord# = a_opord# and drstat = 'D';
              leavesr;
            endif;
            //only process if an active PS driver
            setll a_opqwcd plactdrvp;
            if %equal(plactdrvp);
DR001         //cancelPPjob(a_opord#:a_opqwcd);
            endif;
          endif;
        endif;

       endsr;
      /end-free
