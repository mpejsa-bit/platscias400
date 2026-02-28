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
      *    Date    Mod    Who   Description                           *
      *  --------  ----  -----  ------------------------------------  *
      *  01.23.20  R001  JB/PS  Add status journaling or ORDER table. *
      *  01.23.20  R002  JB/PS  Catch Void status with same #DSP/DSP#.*
      *  03.16.20  R003  JB/PS  Remove faulty T-call orders as code X.*
      *  03.17.20  R004  JB/PS  Prevent record lock on active orders. *
      *  03.18.20  R005  JB/PS  Insert unique codes to order records. *
      *  03.30.20  R006  JB/PS  Flag finished load as Complete to     *
      *                         keep on tablet for driver reference.  *
      *  04.01.20  R007  JB/PS  Rework bucket to catch faulty T-Call. *
      *  04.03.20  R008  JB/PS  Augment for teams on Cancel Preplan.  *
      *  09.01.20  R009  JB/PS  Set triggers for $job form parms.     *
      *****************************************************************
      //
     h option (*nodebugio)
     fdrivers   if   e           k disk
     fmcmsgd    if   e           k disk
     fmcmsgh    if   e           k disk
AR001forder     if   e           k disk
AR001fload      if   e           k disk
     fplactdrvp if   e           k disk
AR001fplactordp uf   e           k disk
AR001fpldltordp o    e           k disk
AR006f**plfueldrvpif   e           k disk
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

AR001dORDER_Rcd      e ds                  extname(ORDER)
  |  d                                     prefix(R_)
  |  dORDER_Bfr      e ds                  extname(ORDER)
  |  d                                     prefix(B_)
  |  dORDER_Aft      e ds                  extname(ORDER)
AR001d                                     prefix(A_)

AR009dLOAD_Rcd       e ds                  extname(LOAD)
  |  d                                     prefix(R_)
  |  dLOAD_Bfr       e ds                  extname(LOAD)
  |  d                                     prefix(B_)
  |  dLOAD_Aft       e ds                  extname(LOAD)
AR009d                                     prefix(A_)

       //procedure prototypes
     d cancelPPJob     pr                  ExtPgm('PLTPPCANR')
     d  order#                        7a
     d  drvcde                        6a   options(*nopass)

     d createPPlan     PR                  ExtPgm('PLTPPJOBR')
     d  unit                          6a
     d  date                          7s 0
     d  time                          6s 0

AR001d cancelWFJob     pr                  ExtPgm('PLTWFCANR')
  |  d  job                          28a
  |
  |  d createWFJob     PR                  ExtPgm('PLTWFJOBR')
AR001d  unit                          6a
CR009d  date                          7s 0 options(*nopass)
CR009d  time                          6s 0 options(*nopass)

AR006d completeWFJob   pr                  ExtPgm('PLTWFCMPR')
AR006d  job                          10a
AR006d  rsn                          30a

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
AR005d w_code          s              1a
AR006d w_reason        s             30a
AR001d w_time4         s              4a
AR001d w_time60        s              6s 0
AR001d w_date70        s              7s 0
     d wrkDate         s              8a
     d Code            s              6a
     d Status          s              1a
     d rec#            s              2s 0
     d jobId           S             28a   Inz(*blanks)
     d job#            S             10a   Inz(*blanks)
     d jobRsn          S             30a   Inz(*blanks)
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
AR001         elseif  (JeObjn = 'ORDER');
AR001            exsr      ORDERsr;
AR009         elseif  (JeObjn = 'LOAD');
AR009            exsr      LOADsr;
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

AR001   //---------------------------------------------------------
  |     //ORDERsr - Process ORDER journal entry
  |     //---------------------------------------------------------
  |    begsr ORDERsr;
  |
  |      select;
  |      when (JeType = 'DL') or
  |           (JeType = 'DX');
  |        ORDER_Aft = JeRcd;
  |
  |        //remove preplan order for all drivers.
  |        cancelPPjob(a_orodr#);
  |
  |        //remove workflow job for all active orders.
  |        setll a_orodr# plactordp;
  |        dou %eof(plactordp);
  |          reade a_orodr# plactordp;
  |          if not %eof(plactordp);
  |            cnord# = plactord;
  |            cndisp = plactdisp;
  |            cncode = 'C';
  |            cndate = a_orpdat;
  |            cntime = a_orptim;
  |            write  pldltordr;
  |            delete plactordr;
  |              jobId = plactord +'-'+ plactdisp
  |                      +'/?id_type=external';
  |              cancelWFJob(jobId);
  |          endif;
  |        enddo;
  |
  |      when (JeType = 'UB');
  |        ORDER_Bfr = JeRcd;
  |
  |      when (JeType = 'UP');
  |        ORDER_Aft = JeRcd;
  |
  |        clear w_code;
AR006      clear w_reason;
  |        //Remove loads that have changed for:
  |        if (b_orstat <> a_orstat);
  |
  |          //Completed(Empty) Load
  |          if (a_orstat = 'E');
  |            w_code = 'E';
AR006          w_reason = 'TMS E-Call';
  |
  |          //Cancelled Load
  |          elseif (a_orstat = 'C');
  |            w_code = 'C';
  |
  |          //Voided Load with no prior pickup
  |          elseif (b_orstat = 'D' and a_orstat = 'A'
  |           and (a_or#dsp = '00' and b_or#dsp <> a_or#dsp)
  |           and (a_ordsp# = '00' and b_ordsp# <> a_ordsp#));
AR005          w_code = 'V';
  |          endif;
  |
AR002      //Remove loads that have not changed for:
AR002      else;
AR002        //Voided Load with prior pickup
AR002        if (a_orstat = 'D'
AR002         and (a_or#dsp > '00' and b_or#dsp <> a_or#dsp)
AR002         and (a_ordsp# = '00' and b_ordsp# <> a_ordsp#));
AR005          w_code = 'V';
  |
  |          //Terminated Load
  |          elseif (a_orstat = 'D'
  |           and (a_or#dsp > '00' and b_or#dsp =  a_or#dsp)
  |           and (a_ordsp# = '00' and b_ordsp# <> a_ordsp#));
AR005          w_code = 'T';
AR006          w_reason = 'TMS T-Call';
  |          endif;
  |        endif;
  |
  |        //remove preplan and loads based upon working code.
AR005      if w_code > *blanks;
  |          //Cancelled Load
  |          if w_code = 'C' Or w_code = 'E';
  |            //remove preplan order for all drivers.
  |            cancelPPjob(b_orodr#);
  |          endif;
  |
  |          chain (b_orodr#:b_or#dsp) plactordp;
  |          if %found(plactordp);
  |            cnord# = plactord ;
  |            cndisp = plactdisp;
CR005          cncode = w_code;
  |            cndate = plmhdate ;
  |  C                   movel     plmhtime      w_time4
  |            cntime = w_time4;
  |            write  pldltordr;
  |            delete plactordr;
AR006          if w_reason > *blanks;
AR006            //setll pldrvcode plfueldrvp;
AR006            //if %equal(plfueldrvp);
AR006              //flag current active job as Completed.
AR006              job# = plactord +'-'+ plactdisp;
AR006              completeWFJob(job#:w_reason);
AR006            //else;
  |              // jobId = plactord +'-'+ plactdisp
  |              //         +'/?id_type=external';
  |              // cancelWFjob(jobId);
AR006            //endif;
AR006          else;
AR006            jobId = plactord +'-'+ plactdisp
AR006                    +'/?id_type=external';
AR006            cancelWFjob(jobId);
AR006          endif;
  |          endif;
  |        endif;
  |
  |        //Reset order behaviour that have changed for:
  |        if (b_orstat <> a_orstat);
  |
  |          //Previously Inactive Order has been reset to Dispatched.
  |          if (b_orstat <> 'A' And a_orstat = 'D'
  |           And (b_ordsp# = a_ordsp# and a_ordsp# > '00')
  |           And (b_or#dsp = a_or#dsp and a_or#dsp > '00'));
  |
  |            //retrieve load information for processing.
  |            chain (b_orodr#:b_or#dsp) load;
  |            if %found(load);
  |              //remove preplan order for current driver.
  |              cancelPPjob(b_orodr#:didr1);
  |
  |              w_time60 = %int(ditime + '00');
  |              setll (diunit:didate:w_time60:'O') mcmsgh;
  |              dou %eof(mcmsgh) or mhpmid = 'T40';
  |                reade diunit mcmsgh;
  |                if not %eof(mcmsgh) and mhdir = 'O'
  |                 and mhpmid = 'T40';
  |                  //create order job for current truck.
  |                  w_date70 = mhdate;
  |                  w_time60 = mhtime;
  |                  createWFJob(diunit:w_date70:w_time60);
  |                endif;
  |              enddo;
  |            endif;
  |
  |          //Previously Active Order has been reset to Available.
  |          // (Void Call FAILED)
  |          elseif (b_orstat = 'D' And a_orstat = 'A'
  |           And (b_or#dsp = a_or#dsp and a_or#dsp > '00')
  |           And (b_ordsp# = a_ordsp# and a_ordsp# > '00'));
  |
  |            //remove preplan order for all drivers.
  |            cancelPPjob(b_orodr#);
  |
  |            //remove workflow job for all active orders.
  |            setll b_orodr# plactordp;
  |            dou %eof(plactordp);
  |              reade b_orodr# plactordp;
  |              if not %eof(plactordp);
  |                cnord# = plactord;
  |                cndisp = plactdisp;
CR007              cncode = 'W';
  |                cndate = b_orpdat;
  |                cntime = b_orptim;
  |                write  pldltordr;
  |                delete plactordr;
  |                  jobId = plactord +'-'+ plactdisp
  |                          +'/?id_type=external';
  |                  cancelWFJob(jobId);
  |              endif;
  |            enddo;
  |          endif;
  |
  |        //Reset order behaviour that have not changed for:
  |        else;
AR003        //Previously Active Order reset with Available Resources.
  |          // (Terminate-Call FAILED [Order dispatched/driver available])
  |          // (Empty-Call FAILED [Order dispatched/driver available])
DR007        if (a_orstat = 'D'
DR007         and (b_or#dsp = a_or#dsp And a_or#dsp > '00')
DR007         and (b_ordsp# = a_ordsp# And a_ordsp# > '00'));
AR007        //if (a_orstat = 'D'
AR007        // and (b_or#dsp > '00' and b_ordsp# > '00')
AR007        // and (a_or#dsp > '00' and a_ordsp# > '00'));
CR007          chain (b_orodr#:b_or#dsp) plactordp;
  |            if %found(plactordp);
  |              chain pldrvcode drivers;
  |              if %found(drivers) And (drstat <> 'D'
  |                 or (drord# <> plactord or drdisp <> plactdisp));
  |                cnord# = plactord;
  |                cndisp = plactdisp;
CR007              cncode = 'U';
  |                cndate = plmhdate;
  |  C                   movel     plmhtime      w_time4
  |                cntime = w_time4;
  |                write  pldltordr;
  |                delete plactordr;
AR006              //setll pldrvcode plfueldrvp;
AR006              //if %equal(plfueldrvp);
AR006                //flag current active job as Completed.
AR006                job# = plactord +'-'+ plactdisp;
AR006                w_reason = 'TMS T-Call';
AR006                completeWFJob(job#:w_reason);
AR006              //else;
  |                //  jobId = plactord +'-'+ plactdisp
  |                //          +'/?id_type=external';
  |                //  cancelWFjob(jobId);
AR006              //endif;
  |
AR009            //Current Active Order change of $job form parameters.
AR009            elseif %found(drivers) And drstat = 'D'
AR009               And drord# = plactord And drdisp = plactdisp
AR009               And (b_orsel1 <> a_orsel1
AR009               or b_orcsh#  <> a_orcsh#
AR009               or b_orwgt   <> a_orwgt
AR009               or b_orpiec  <> a_orpiec
AR009               or b_ortrlr  <> a_ortrlr);
CR009              unlock plactordp;
AR009              createWFJob(drunit);
  |              endif;
  |            endif;
  |          endif;
  |        endif;
  |      endsl;
AR001  endsr;

AR009   //---------------------------------------------------------
  |     //LOADsr - Process LOAD journal entry
  |     //---------------------------------------------------------
  |    begsr LOADsr;
  |
  |      select;
  |      when (JeType = 'DL') or
  |           (JeType = 'DX');
  |        LOAD_Aft = JeRcd;
  |
  |      when (JeType = 'UB');
  |        LOAD_Bfr = JeRcd;
  |
  |      when (JeType = 'UP');
  |        LOAD_Aft = JeRcd;
  |
  |          //Current Active Load with Trailer change.
  |          if (b_ditrlr <> a_ditrlr);
  |            chain(n) (a_diodr#:a_didisp) plactordp;
  |            if %found(plactordp);
  |              createWFJob(a_diunit);
  |            endif;
  |          endif;
  |      endsl;
AR001  endsr;

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
DR008         //cancelPPjob(a_opord#:a_opqwcd);
            endif;
          endif;
        endif;

       endsr;
      /end-free
