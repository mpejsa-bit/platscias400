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
      * this program reads a DB of inbound messages from a driver   *
      * via the AMQP process.                                       *
      * ONce processed the records are marked as such.              *
      * these feed into ICC mobile comm for integration.            *
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *  12/04/19   R001  JB/PS  Corrected ETA Time format for update.
      *  12/05/19   R002  JB/PS  Update driver responding to preplan,
      *                          and add driver to Cancel Preplan API.
      *  12/11/19   R003  JB/PS  Add gmt offset function call.
      *  12/12/19   R004  JB/PS  Adjust ETA field gmt for local timezone.
      *  02/14/20   R005  JB/PS  Retrieve Seal# for Empty Call macro.
      *  02/26/20   R006  MP/PS  temp fix for 5180 bad lat long Mcallen TX
      *  03/20/20   R007  MP/PS  move header info into setup and add a FF proces
      *  07/01/20   R008  JB/PS  temp fix for 5158 bad lat long Fort Meyers,FL
      *  07/31/20   R009  JB/PS  Add tCall inbound form processing.
      *
      *****************************************************************
     FPlmsgql1  uF   e           k disk
     Fmclocat   iF   e           k disk
     Funits     iF   e           k disk
     Funitsdr1  iF   e           k disk    rename(runitmas:dr1)
     Funitsdr2  iF   e           k disk    rename(runitmas:dr2)
     Fpltintp   iF   E           k DISK    usropn
     Fplactdrvp UF A e           k disk
AR004Fcities    if   e           k disk
AR004Fordstopl1 if   e           k disk

       //procedure prototypes
     D cancelPP        PR                  ExtPgm('PLTPPCANR')
     D  PP                            7a
AR002D  drvcde                        6a   options(*nopass)
      * Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')
     d                             3000a   const options(*varsize)
     d                               15p 5 const

AR003d rtvtimz         pr                  extpgm('RTVTIMZ')
AR003d   offset                       2a

      * Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)
     d dlycmd11        c                   const('DLYJOB (')
     d dlycmd12        c                   const(')')
      *
     D*MACQUE          DS
     D* msg                           3  0
     D* NM                            2
     D* Three                         3
     D* truck1                        8
     D* truck2                        8
     D* blank                         7
     D* datetime                     21  0
     D* blank1                        3
     D* zeros                         7
     D* blank3                        3
     D* zeros2                       33
     D* msgbody                     100
      *
      *
     D MACQUE          DS
     D  seq                    1      3
     D  notused1               4      4
     D  notused2               5      5
     D  trantype               6      8
     D  truck1                 9     16
     D  notused3              17     31
     D  dateTime              32     45  0
     D  lat                   47     52
     D  long                  57     62
     D  longE                 62     62
     D* msg#                  56     62
     D  form                  66     68
     D  formver               69     70  0
     D  outmsg#               92     98
     D  msgbody               99   2000

     D up              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'

     D ebc             C                   'JKLMNOPQR'
     D num             C                   '123456789'

     d exampleTS       s             20a   inz(*blanks)
     d body            s           1900a   varying
     D  datetimeChar   s             20
     D timestamp6      s               z
     D RETOCC          S              7  0 INZ(*ZEROS)
     d E               S              7  0 Inz(*zeros)
     d L               S              7  0 Inz(*zeros)
     d S               S              7  0 Inz(*zeros)
     D appcode         s              2a   inz('WF')
     d @ffmsg          s           1900a
     d @seal           s             10a
     d @drptrlr        s             14a
     d @bol            s             20a
     d @drLod          s              1a
     d @weight         s              6a
     d @pieces         s              5a
     d @eta            s             26a
     d @etamm          s              2a
     d @etahh          s              2a
     d @etadd          s              2a
     d @etamin         s              2a
     d @preplan        s              9a
     d yesno           s              1a
     d @curtrlr        s             14a
     d @order          s              7a
AR002d @driver         s              8a
     d @stopId         s              2a
     d #stopId         s              2  0
     d process         s              1a
     d currentorder    s              7a
     d currentdisp     s              2a
     d PP              s              7a
AR002d drvcde          s              6a
AR003d offset          S              2a
AR004d tsChar          s             26a
AR004d tzAug           s              2  0
AR009d @custCode       s             15a
AR009d @dropTrlr       s              3a
AR009d @dropTrlrYN     s              1a
AR009d @dropTrlr#      s             14a
     d timefix         s               z

      /free
        dou *inlr = *on;
AR003     rtvtimz(offset);
          exsr main;
          exsr delayjob;
        enddo;
        *inlr = *on;

        //------------------------------------------------
        begsr delayjob;

          monitor;
          open pltintp;
          read pltintp;
          on-error;
          read pltintp;
          close pltintp;
          endmon;

          // "DLYJOB(" + variable from file + ")"
          dlycmd = %trim(dlycmd11) + %trim(pltdftdly2) + dlycmd12;
          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr main;
        appCode = 'WF';
        setll appCode plmsgql1;
        reade appCode plmsgql1;
        dow  %eof(plmsgql1) = *off;
        exsr setup;


        select;
        when plmsgtyp = 'arrivedShipper';
        Clear MacQue;
        tranType = '002';
        exsr arrivedShipper;

        when plmsgtyp = 'loadedCallDeparture';
        Clear MacQue;
        tranType = '002';
        exsr loadedCall;

        when plmsgtyp = 'arrivedStop';
        Clear MacQue;
        tranType = '002';
        exsr arrivedStop;

        when plmsgtyp = 'departStopDeparture';
        Clear MacQue;
        tranType = '002';
        exsr departStop;

        when plmsgtyp = 'arrivedConsignee';
        Clear MacQue;
        tranType = '002';
        exsr arrivedConsignee;

        when plmsgtyp = 'emptyCallDeparture';
        Clear MacQue;
        tranType = '002';
        exsr emptyCall;

        when plmsgtyp = 'preplan';
        Clear MacQue;
        tranType = '002';
        exsr prePlan;

        when plmsgtyp = 'MessagingEvent';
        Clear MacQue;
        tranType = '002';
        exsr freeForm;

AR009   when plmsgtyp = 'tCall';
  |     Clear MacQue;
  |     tranType = '002';
AR009   exsr tCall;

        endsl;

        exsr  whitelist;
        plproc = 'Y';
        update plmsgqr;
      //delete plmsgqr;
        reade appCode plmsgql1;
        enddo;

        appCode = 'FF';
        setll appCode plmsgql1;
        reade appCode plmsgql1;
        dow  %eof(plmsgql1) = *off;
        exsr setup;

        select;

        when plmsgtyp = 'MessagingEvent';
        Clear MacQue;
        tranType = '002';
        exsr freeForm;

        endsl;

        exsr  whitelist;
        plproc = 'Y';
        update plmsgqr;
      //delete plmsgqr;
        reade appCode plmsgql1;
        enddo;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        begsr setup;
        timefix = plquets;
DR003   //timefix = %timestamp(timefix) - %Hours(7);
AR003   timefix = %timestamp(timefix) - %Hours(%Int(offset));
        timestamp6 = %timestamp(timefix);

        pldrvcd1= %XLATE(lo:up:pldrvcd1);
        pldrvcd2= %XLATE(lo:up:pldrvcd2);
        process = *off;
        if pldrvcd1 <> *blanks;
        chain(n) pldrvcd1 unitsdr1;
        if %found(unitsdr1) = *on;
        process = *on;
        plunit = ununit;
        endif;
        endif;

        if process = *off;
        if pldrvcd2 <> *blanks;
        chain(n) pldrvcd2 unitsdr2;
        if %found(unitsdr2) = *on;
        process = *on;
        plunit = ununit;
        endif;
        endif;
        endif;

        if process = *off;
        if pldrvcd1 <> *blanks;
        chain(n) pldrvcd1 unitsdr2;
        if %found(unitsdr2) = *on;
        process = *on;
        plunit = ununit;
        endif;
        endif;
        endif;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        begsr whitelist;
        //white list new drivers
        if undr1 <> *blanks;
        chain(n) undr1 plactdrvp;
        if %found = *off;
        pldrvcode = undr1;
        write plactdrvr;
        endif;
        endif;

        if undr2 <> *blanks;
        chain(n) undr2 plactdrvp;
        if %found = *off;
        pldrvcode = undr2;
        write plactdrvr;
        endif;
        endif;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr freeForm;

        if process = *on;
        exsr header;
        form     = '000';
          retocc = %scan('"message":':plpaylod);
          if retocc > 0;
              S = retocc + 11;
          E = %scan('"':plpaylod:S);
              L = E - S;
          monitor;
              @ffmsg  = %trim(%subst(plpaylod:S:L));
              @ffmsg  = %xlate('"':' ':@ffmsg);
              @ffmsg  = %XLATE(lo:up: @ffmsg);
          on-error;
              @ffmsg  = *blanks;
          endmon;
          endif;

        msgbody  = @ffmsg;
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endif;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr loadedCall;
          clear @bol;
          clear @weight;
          clear @pieces;
          clear @eta;
          clear @etamm;
          clear @etahh;
          clear @etadd;
          clear @etamin;
          clear @seal;
          clear @drptrlr;
          clear @curtrlr;
        exsr header;
        form     = '004';

          retocc = %scan('"PlannedBOL":':plpaylod);
          if retocc > 0;
              S = retocc + 14;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @bol = %trim(%subst(plpaylod:S:L));
              @bol = %xlate('"':' ':@bol);
          on-error;
              @bol  = *blanks;
          endmon;
          endif;

          retocc = %scan('"Weight":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @weight = %trim(%subst(plpaylod:S:L));
              @weight = %xlate('"':' ':@weight);
          on-error;
              @weight= *blanks;
          endmon;
          endif;

          retocc = %scan('"Pieces":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @pieces = %trim(%subst(plpaylod:S:L));
              @pieces = %xlate('"':' ':@pieces);
          on-error;
              @pieces= *blanks;
          endmon;
          endif;

          retocc = %scan('"ETA":':plpaylod);
          if retocc > 0;
              S = retocc + 7;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @eta = %trim(%subst(plpaylod:S:L));
              @eta = %xlate('"':' ':@eta);
DR004      //if @eta <> 'null';
AR004      if @eta <> 'null' and @eta <> 'ull';
              @eta = %trim(%subst(plpaylod:S:L));
              @eta = %xlate('"':' ':@eta);

AR004         clear tzAug;
  |           //retrieve customer for loaded-call
  |           #stopid = 1;
  |           chain (unord#:undisp:#stopid) ordstopl1;
  |           if %found(ordstopl1);
  |             chain (oulst:oulcty) cities;
  |             if %found(cities) and citime > '00';
  |              //augment timezone from El Paso system offset.
  |               tzAug = 5 - %int(citime);
  |             endif;
  |           endif;
  |
  |          tsChar  = %subst(@eta:1:10) + '-' +
  |                    %subst(@eta:12:8) + '.000000';
  |          tsChar  = %xlate(':':'.':tsChar);
  |          timefix = %timestamp(%char(tsChar))
  |                    - %Hours(%Int(offset) - tzAug);
  |          tsChar  = %char(timefix);
  |          @etamm = %subst(tsChar:6:2);
  |          @etadd = %subst(tsChar:9:2);
  |          @etahh = %subst(tsChar:12:2);
AR004        @etamin= %subst(tsChar:15:2);
DR004        //@etamm = %subst(@eta:6:2);
  |          //@etadd = %subst(@eta:9:2);
  |          //@etahh = %subst(@eta:12:2);
DR004        //@etamin= %subst(@eta:15:2);
           endif;
          endif;

          retocc = %scan('"Seal":':plpaylod);
          if retocc > 0;
              S = retocc + 8;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @seal = %trim(%subst(plpaylod:S:L));
              @seal = %xlate('"':' ':@seal);
              @seal = %XLATE(lo:up: @seal);
          on-error;
              @seal= *blanks;
          endmon;
          endif;

          retocc = %scan('"DroppedTrailer":':plpaylod);
          if retocc > 0;
              S = retocc + 17;
              clear E;
              E = %scan(',':plpaylod:S);
              if E = 0;
                E = %scan(' ':plpaylod:S);
              endif;
              L = E - S;
              @drptrlr = %trim(%subst(plpaylod:S:L));
              @drptrlr = %xlate('"}':'  ':@drptrlr);
              if @drptrlr = 'null';
              clear @drptrlr;
              endif;
          endif;

          retocc = %scan('"CurrOrPickedTrailer":':plpaylod);
          if retocc > 0;
              S = retocc + 22;
              clear E;
              E = %scan(',':plpaylod:S);
              if E = 0;
                E = %scan(' ':plpaylod:S);
              endif;
              L = E - S;
              @curtrlr = %trim(%subst(plpaylod:S:L));
              @curtrlr = %xlate('"}':'  ':@curtrlr);
              if @curtrlr = 'null';
              clear @curtrlr;
              endif;
          endif;

              @order  = %trim(plorder);

        msgbody  = @bol + @weight+ @pieces + @seal +
A001    @etamm+ @etadd + @etahh + @etamin + @drptrlr + @curtrlr;
D001  //@etamm+ @etadd + @etahh + @etamm + @drptrlr + @curtrlr;
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr prePlan;

        if process = *on;
        exsr header;
        form     = '001';

AR002     clear @driver;
  |       retocc = %scan('"users":{"data":':plpaylod);
  |       if retocc > 0;
  |         S = retocc + 16;
  |         retocc = %scan('"external_id":':plpaylod:S);
  |         if retocc > 0;
  |           S = retocc + 14;
  |           E = %scan(',':plpaylod:S);
  |           L = E - S;
  |           monitor;
  |             @driver = %trim(%subst(plpaylod:S:L));
  |             @driver = %triml(%xlate('"':' ':@driver));
  |           on-error;
  |             @driver = *blanks;
  |           endmon;
  |         endif;
AR002     endif;

AR002     retocc = %scan('"action":':plpaylod:S);
DR002   //retocc = %scan('"action":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @preplan = %trim(%subst(plpaylod:S:L));
              @preplan = %xlate('"':' ':@preplan);
          endif;
              select;
              when @preplan = 'committed';
              yesno = 'Y';
              when @preplan = 'declined';
              yesno = 'N';
              other;
              yesno = ' ';
              endsl;


        if yesno <> *blanks;
          @order  = %trim(plorder);
DR002     //drvcde  = %trim(@driver);
AR002     //pass driver code matching TMS
AR002     drvcde  = %trim(%xlate(lo:up:@driver));
          msgbody  = yesno + @order;
AR002   //msgbody  = yesno + @order + drvcde;
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
          if yesno = 'N';
          PP = @order;
AR002       if drvcde > *blanks;
AR002         //pass driver code from payload
AR002         cancelPP(PP:@driver);
DR002       //cancelPP(PP);
AR002       endif;
          endif;
        endif;
        endif;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr emptyCall;
          clear @bol;
          clear @weight;
          clear @pieces;
          clear @seal;
          clear @drLod;
          clear @drptrlr;
          clear @curtrlr;
        exsr header;
        form     = '008';

          retocc = %scan('"DriverUnload":':plpaylod);
          if retocc > 0;
              S = retocc + 16;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @drLod = %trim(%subst(plpaylod:S:L));
              @drLod = %xlate('"':' ':@drLod);
          on-error;
              @drlod =*blanks;
          endmon;
          endif;

          retocc = %scan('"PlannedBOL":':plpaylod);
          if retocc > 0;
              S = retocc + 14;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @bol = %trim(%subst(plpaylod:S:L));
              @bol = %xlate('"':' ':@bol);
          on-error;
              @bol   =*blanks;
          endmon;
          endif;

          retocc = %scan('"Weight":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @weight = %trim(%subst(plpaylod:S:L));
              @weight = %xlate('"':' ':@weight);
          on-error;
              @weight=*blanks;
          endmon;
          endif;

          retocc = %scan('"Pieces":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @pieces = %trim(%subst(plpaylod:S:L));
              @pieces = %xlate('"':' ':@pieces);
          on-error;
              @pieces=*blanks;
          endmon;
          endif;

AR005     retocc = %scan('"Seal":':plpaylod);
  |       if retocc > 0;
  |           S = retocc + 8;
  |       E = %scan(',':plpaylod:S);
  |           L = E - S;
  |       monitor;
  |           @seal = %trim(%subst(plpaylod:S:L));
  |           @seal = %xlate('"':' ':@seal);
  |           @seal = %XLATE(lo:up: @seal);
  |       on-error;
  |           @seal= *blanks;
  |       endmon;
AR005     endif;

          retocc = %scan('"DroppedTrailer":':plpaylod);
          if retocc > 0;
              S = retocc + 17;
              clear E;
              E = %scan(',':plpaylod:S);
              if E = 0;
                E = %scan(' ':plpaylod:S);
              endif;
              L = E - S;
              @drptrlr = %trim(%subst(plpaylod:S:L));
              @drptrlr = %xlate('"}':'  ':@drptrlr);
              if @drptrlr = 'null';
              clear @drptrlr;
              endif;
          endif;

          retocc = %scan('"CurrOrPickedTrailer":':plpaylod);
          if retocc > 0;
              S = retocc + 22;
              clear E;
              E = %scan(',':plpaylod:S);
              if E = 0;
                E = %scan(' ':plpaylod:S);
              endif;
              L = E - S;
              @curtrlr = %trim(%subst(plpaylod:S:L));
              @curtrlr = %xlate('"}':'  ':@curtrlr);
              if @curtrlr = 'null';
              clear @curtrlr;
              endif;
          endif;

              @order  = %trim(plorder);
        msgbody  = @order + @drptrlr + @curtrlr + @bol +@weight
        + @pieces + @seal + @drLod;
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr arrivedStop;
        clear @stopId;
        clear #stopId;
        exsr header;
        form     = '005';
          retocc = %scan('"StopOffId":':plpaylod);
          if retocc > 0;
              S = retocc + 12;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @stopId = %trim(%subst(plpaylod:S:L));
              @stopId = %xlate('"':' ':@stopId);
          endif;
        #stopid = %int(@stopId);
        #stopid = #stopId - 1;
        @stopId = %char(#stopId);
        msgbody  = %trim(@stopId);
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr departStop;
          clear @bol;
          clear @weight;
          clear @pieces;
          clear @eta;
          clear @etamm;
          clear @etahh;
          clear @etadd;
          clear @etamin;
          clear @drptrlr;
          clear @curtrlr;
          clear @seal;
          clear @stopid;
          clear #stopid;
        exsr header;
        form     = '006';
          retocc = %scan('"StopOffId":':plpaylod);
          if retocc > 0;
              S = retocc + 12;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @stopId = %trim(%subst(plpaylod:S:L));
              @stopId = %xlate('"':' ':@stopId);
        #stopid = %int(@stopId);
        #stopid = #stopId - 1;
        @stopId = %char(#stopId);
          endif;

          retocc = %scan('"PlannedBOL":':plpaylod);
          if retocc > 0;
              S = retocc + 14;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @bol = %trim(%subst(plpaylod:S:L));
              @bol = %xlate('"':' ':@bol);
          on-error;
              @bol   =*blanks;
          endmon;
          endif;

          retocc = %scan('"Weight":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @weight = %trim(%subst(plpaylod:S:L));
              @weight = %xlate('"':' ':@weight);
          on-error;
              @weight=*blanks;
          endmon;
          endif;

          retocc = %scan('"Pieces":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @pieces = %trim(%subst(plpaylod:S:L));
              @pieces = %xlate('"':' ':@pieces);
          on-error;
              @pieces=*blanks;
          endmon;
          endif;

          retocc = %scan('"ETA":':plpaylod);
          if retocc > 0;
              S = retocc + 7;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @eta = %trim(%subst(plpaylod:S:L));
              @eta = %xlate('"':' ':@eta);
DR004      //if @eta <> 'null';
AR004      if @eta <> 'null' and @eta <> 'ull';
              @eta = %trim(%subst(plpaylod:S:L));
              @eta = %xlate('"':' ':@eta);

AR004         clear tzAug;
  |           //retrieve customer for stopoff
  |           chain (unord#:undisp:#stopid) ordstopl1;
  |           if %found(ordstopl1);
  |             chain (oulst:oulcty) cities;
  |             if %found(cities) and citime > '00';
  |              //augment timezone from El Paso system offset.
  |               tzAug = 5 - %int(citime);
  |             endif;
  |           endif;
  |
  |          tsChar  = %subst(@eta:1:10) + '-' +
  |                    %subst(@eta:12:8) + '.000000';
  |          tsChar  = %xlate(':':'.':tsChar);
  |          timefix = %timestamp(%char(tsChar))
  |                    - %Hours(%Int(offset) - tzAug);
  |          tsChar  = %char(timefix);
  |          @etamm = %subst(tsChar:6:2);
  |          @etadd = %subst(tsChar:9:2);
  |          @etahh = %subst(tsChar:12:2);
AR004        @etamin= %subst(tsChar:15:2);
DR004        //@etamm = %subst(@eta:6:2);
  |          //@etadd = %subst(@eta:9:2);
  |          //@etahh = %subst(@eta:12:2);
DR004        //@etamin= %subst(@eta:15:2);
           endif;
          endif;

          retocc = %scan('"Seal":':plpaylod);
          if retocc > 0;
              S = retocc + 8;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
              @seal = %trim(%subst(plpaylod:S:L));
              @seal = %xlate('"':' ':@seal);
              @seal = %XLATE(lo:up: @seal);
          on-error;
              @seal  =*blanks;
          endmon;
          endif;

          retocc = %scan('"DroppedTrailer":':plpaylod);
          if retocc > 0;
              S = retocc + 17;
              clear E;
              E = %scan(',':plpaylod:S);
              if E = 0;
                E = %scan(' ':plpaylod:S);
              endif;
              L = E - S;
              @drptrlr = %trim(%subst(plpaylod:S:L));
              @drptrlr = %xlate('"}':'  ':@drptrlr);
              if @drptrlr = 'null';
              clear @drptrlr;
              endif;
          endif;

          retocc = %scan('"CurrOrPickedTrailer":':plpaylod);
          if retocc > 0;
              S = retocc + 22;
              clear E;
              E = %scan(',':plpaylod:S);
              if E = 0;
                E = %scan(' ':plpaylod:S);
              endif;
              L = E - S;
              @curtrlr = %trim(%subst(plpaylod:S:L));
              @curtrlr = %xlate('"}':'  ':@curtrlr);
              if @curtrlr = 'null';
              clear @curtrlr;
              endif;
          endif;

              @order  = %trim(plorder);

        msgbody  = %trim(@stopId) + ' ' + @bol + @weight+ @pieces + @seal +
A001    @etamm+ @etadd + @etahh + @etamin;
D001  //@etamm+ @etadd + @etahh + @etamm;
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr arrivedShipper;
        exsr header;

        form     = '003';
        msgbody  = ' ';
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr arrivedConsignee;
        exsr header;

        form     = '007';
        msgbody  = ' ';
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
AR009  begsr tCall;
  |      clear @custCode;
  |      clear @dropTrlr;
  |      clear @dropTrlrYN;
         clear @dropTrlr#;
         exsr header;
         form     = '009';

         retocc = %scan('"tcustCode":':plpaylod);
         if retocc > 0;
           S = retocc + 13;
           E = %scan('"':plpaylod:S);
           L = E - S;
           monitor;
             @custCode = %trim(%subst(plpaylod:S:L));
             @custCode = %xlate('"':' ':@custCode);
           on-error;
             @custCode = *blanks;
           endmon;
         endif;

         @dropTrlrYN = 'N';
         retocc = %scan('"PickUpEmptyTrailer":':plpaylod);
         if retocc > 0;
           S = retocc + 22;
           E = %scan('"':plpaylod:S);
           L = E - S;
            monitor;
             @dropTrlr = %trim(%subst(plpaylod:S:L));
             @dropTrlr = %xlate('"':' ':@dropTrlr);
             @dropTrlr = %XLATE(lo:up:@dropTrlr);
            on-error;
             @dropTrlr = *blanks;
           endmon;
           if @dropTrlr = 'YES';
             @dropTrlrYN = 'Y';
           endif;
         endif;

         retocc = %scan('"PickedTrailerNumber":':plpaylod);
         if retocc > 0;
           S = retocc + 23;
           E = %scan('"':plpaylod:S);
           L = E - S;
           monitor;
             @dropTrlr# = %trim(%subst(plpaylod:S:L));
             @dropTrlr# = %xlate('"':' ':@dropTrlr#);
             evalr @dropTrlr# = %XLATE(lo:up:@dropTrlr#);
           on-error;
             @dropTrlr# = *blanks;
           endmon;
         endif;

         if @dropTrlr# = 'null' Or @dropTrlr# = 'ull' Or @dropTrlrYN = 'N';
           clear @dropTrlr#;
         endif;

         msgbody = @custCode + @dropTrlrYN + @dropTrlr#;

  |       DQFLD = MacQue;
  |       DQ    = 'PEOPLEINQ';
  |       exsr senddtaq;
AR009   endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr header;
        truck1 = %trim(plunit);

        chain(n) plunit  units;
        if %found(units) = *on;
        currentorder = unord#;
        currentdisp = undisp;
        endif;

          setgt plunit mclocat;
          readpe(n) plunit mclocat;
          dow %eof = *off;
          lat = %char(ullat);
          long =%char(ullong);
          longE   = %XLATE(num:ebc:longE);
          if ulcty = 'LARE' and ulstat = 'TX';
          lat = '0000000';
          long = '0000000';
          endif;
r006      if ulunit = '  5180'
r008      or ulunit = '  5158';
          lat = '0000000';
          long = '0000000';
          endif;
          leave;
          readpe(n) plunit mclocat;
          enddo;
        //msg# = '0}';
        outmsg# = '000000}0';
        datetimeChar = %CHAR(timestamp6 : *iso0);
     c                   movel     datetimeChar  datetime
        endsr;
       //-----------------------------------------------------------------------
       //SendDtaq - send to ICC mobile comm processing dataqueue
       //------------------------------------------------
     C     SendDtaq      begsr
     C                   CALL      'QSNDDTAQ'
     C                   PARM                    DQ               10
     C                   PARM      '*LIBL'       DQLIB            10
     C                   PARM      2080          DQLEN             5 0
     C                   PARM                    DQFLD          2090
     c                   Endsr
     C*----------------------------------------------------------------
