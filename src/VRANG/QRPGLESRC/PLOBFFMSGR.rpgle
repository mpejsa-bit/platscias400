     H OPTION (*NODEBUGIO) DFTACTGRP(*NO)
      *---------------------------------------------------------------*
      *                                                               *
      * \Z   @ Copyright Platform Science            \Z               *
      * \Z               9255 towne center          \Z                *
      * \Z               San Diego , CA 92121        \Z               *
      *                                                               *
      * \ZThis software is licensed material of Platform Science and  *
      * \Zmay only be used consistent with the license granted.  No   *
      * \Zpart of this material may be reproduced, tranferred, or     *
      * \Zcopied for any purpose without the express written permis-  *
      * \Zsion of Platform Science.      Copyright 2019.              *
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
      *  04/30/20   R009  JB/PS  Create freeform messages via API.
      *  04/30/20   R010  JB/PS  Cancel team preplans.
      *  09/16/20   R011  JB/PS  Only process active Fuel Solutions.
      *  11/05/20   R012  JB/PS  Remove whitelist feature.
      *  05/31/21   R013  JB/PS  Add urgent priority for Ff messages.
      *  10/15/21   R014  MP/PS  lower job delay time from 5 to 2.
      *  12/15/21   R015  JB/PS  Remove fuel solutions.
      *  11/29/21   R016  MP/PS  add in macro 53 for urgent message
      *  06/13/22   R017  JB/PS  send macro 48 as freeform message
      *  06/26/23   R018  VR/PS  Message delivery optimization
      *****************************************************************
        dcl-f pljrnctlp  usage(*update) keyed;
        dcl-f units      usage(*input)  keyed;
        dcl-f mcmsgh     usage(*input)  keyed;
        dcl-f plactdrvp  usage(*input)  keyed;
        dcl-f mcmsgd     usage(*input)  keyed;
AR018   dcl-f psobffmsgp usage(*output);

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

       dcl-ds MCMSGH_Rcd extname('MCMSGH') prefix(R_);
       end-ds;

       dcl-ds MCMSGH_Bfr extname('MCMSGH') prefix(B_);
       end-ds;

       dcl-ds MCMSGH_Aft extname('MCMSGH') prefix(A_);
       end-ds;

       dcl-pr usleep int(10) extproc('usleep') ;
        *n uns(10) value;
       end-pr;

       dcl-pr SendMessage extpgm('PSSNDMSG');
         *n char(10);                      // Driver ID
         *n char(5000);                    // Message
         *n char(50);                      // Deeplink
         *n char(50) options(*nopass);     // Subject
         *n char(10) options(*nopass);     // Priority
         *n char(200) options(*nopass);    // Error response
       end-PR;

        dcl-s JrnFirstFlag char(1) inz(*on);
        dcl-s driver char(10);
        dcl-s wrkDate char(8);
        dcl-s Message char(5000);
        dcl-s conversationName char(50);
        dcl-s messagePriority char(10);
        dcl-s ErrorReturn char(200);
        dcl-s DeepLink char(50);

      *----------------------------------------------------------
      * Entry point
      *----------------------------------------------------------
     C     *entry        plist
     C                   parm                    JeEntry
     C                   parm                    pflag             1


        //first time UP journal skip it
        if (JrnFirstFlag = *on and jetype = 'UP');
          JrnFirstFlag = *off ;
        else ;
          JrnFirstFlag = *off ;

          // Update last processed date/time in control file
           chain (%trim(JeObjn) + 'FF') PLJRNCTLP;
            if %found(PLJRNCTLP) = *on;
              Dtime = %dec(%Timestamp());
     C                   movel     Wdate         @cent2            2
     C                   move      JeYear        @year2            2
     C                   move      JeMMDD        @mmdd4            4
              wrkDate  = @mmdd4 + @cent2 + @year2;
              PLjlstdt = %dec(wrkDate:8:0);
              PLjlsttm = %dec(JeTime:6:0);
              update PLJRNCTLR;
            endif;

            //Process journal time out
            select;
            when (pflag = '0');

            //Process journal entries
            when (pflag = '1');

              if (JeObjn = 'MCMSGH');
               exsr      MCMSGHFFsr;
              endif;

            //Process swapping journal receivers
            when (pflag = '3');
              *inlr = *on;
            endsl;
        endif;
        return;

        //---------------------------------------------------------
        //MCMSGHFFsr - Process MCMSGH journal entry (Freeform only)
        // 01/02 - Random Message
        // 04 - Loaded Call Reminder Message
        // 05 - Empty Call Reminder Message
        // 08/54 - Customer Directions
        // 17 - Scale Your Load Reminder Message
        // 19 - Trainer Driver Informational Message
        // 20 - Money Withdrew Message
        // 22/23 - Detention Message
        // 26/31/52 - Customer Specific Load Dispatch Information
        // 27 - Tire Instruction Message
        // 29 - Written Warning Message
        // 32 - Low Bridge Message
        // 35 - Pre-Trip Message
        // 37 - Driver Charge Back Message
        // 48 - Appointment Time
        // 53/62 - Load Tarp Message
        // 55 - Advance Authorization
        // 56 - Extra Pay Messages
        // 57 - PO Authorization
        // 09/59 - Pay Message
        // 25/60 - High Value Load
        // 61 - Breakdown Instructions
        //---------------------------------------------------------
       Begsr MCMSGHFFsr;

         select;
          When (JeType = 'PT' or JeType = 'PX');
           Mcmsgh_Aft = JeRcd;
           if a_mhdir = 'O';
             chain a_mhunit units;
             if %found(units);
               chain undr1 plactdrvp;
               if %found(plactdrvp);
CR018            //exsr sendT00msg;

AR018            Clear PSOBFFMSGR;

                 Chain(N)(PSWUSR) PSOBFWUSRP;
                 If %Found(PSOBFWUSRP);

                   //Fleetwide Messages
                   PSMTYP = 'FW';

                 ElseIf
                   (a_mhpmid  = '011' Or  a_mhpmid  = '013'  Or
                    a_mhpmid  = '014' Or  a_mhpmid  = '015'  Or
                    a_mhpmid  = '035' Or  a_mhpmid  = '053'  Or
                    a_mhpmid  = '017' Or  a_mhpmid  = '027');

                   //Low priority messages
                    PSMTYP = 'LO';

                 ElseIf
                   (a_mhpmid  < '040'       Or
                    a_mhpmid  = '044'       Or
                    a_mhpmid  = '047'       Or
                    a_mhpmid  = '048'       Or
                    a_mhpmid  = '049'       Or
                    (a_mhpmid >= '050' And
                     a_mhpmid <= '057')     Or
                    a_mhpmid >= '059');

                       //High priority messages
                       PSMTYP = 'HI';

                 EndIf;

                 If PSMTYP <> *Blanks;

                   PSUNIT = A_MHUNIT;
                   PSDATE = A_MHDATE;
                   PSTIME = A_MHTIME;
                   PSMSG# = A_MHMSG#;
                   PSDRV1 = UNDR1;
                   PSDRV2 = UNDR2;
                   PSWUSR = A_MH_WUSER;

                   if a_mhpmid = '000' And a_MH_UUSER <> 'QPGMR'
                      or a_mhpmid = '053';
                      PSMPRI = 'urgent';
                   else;
                     Clear PSMPRI;
                   endif;

                   //Clear PSMSUB;
                   //Clear PSDLNK;
                   PSWRTT = %Timestamp();
                   //Clear PSSNDQ;
                   //Clear PSSNDT;
                   //Clear PSDSTS;
                   //Clear PSOMSG;

                   Exec SQL
                     SELECT LISTAGG(trim(mdmsgs), ' ')
                         INTO :PSOMSG  FROM mcmsgd Where
                         MDUNIT = : A_MHUNIT AND
                         MDDATE = : A_MHDATE AND
                         MDTIME = : A_MHTIME AND
                         MDDIR  = 'O';

                   Write PSOBFFMSGR;

                 EndIf;
               EndIf;
             EndIf;
           EndIf;

         //UPDATE (before)
         when (JeType = 'UB');
           Mcmsgh_Bfr = JeRcd;

         //UPDATE (after)
        when (JeType = 'UP');
           Mcmsgh_Aft = JeRcd;
         endsl;

       endsr;
       //-------------------------------------------------------------
       //- call program to send any ff message -----------------------
       //-------------------------------------------------------------
         begsr sendT00msg;

          exsr GetMessage;

            SendMessage(Driver:Message:Deeplink:conversationName
               :messagePriority:ErrorReturn);

          endsr;
       //-------------------------------------------------------------
       //- Get Message from MC tables
       //-------------------------------------------------------------
         begsr GetMessage;
          Clear MessagePriority;
          Clear ConversationName;
          Clear DeepLink;
          Clear Driver;

          Driver = undr1;

            usleep(200000);
          Exec SQL
            SELECT LISTAGG(trim(mdmsgs), ' ')
                INTO :Message FROM mcmsgd Where
                MDUNIT = : A_MHUNIT AND
                MDDATE = : A_MHDATE AND
                MDTIME = : A_MHTIME AND
                MDDIR  = 'O';

            Deeplink = *Blanks;
            ConversationName = *Blanks;
            if a_mhpmid = '000' And a_MH_UUSER <> 'QPGMR'
               or a_mhpmid = '053';
               Messagepriority = 'urgent';
            endif;
         endsr;
