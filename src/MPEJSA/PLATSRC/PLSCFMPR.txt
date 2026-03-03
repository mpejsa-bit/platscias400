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
      *  12/05/19   R001  JB/PS  Remove Cancel Preplan API.
      *  12/11/19   R003  JB/PS  Add gmt offset function call.
      *  07/31/20   R004  JB/PS  Add tCall inbound form processing.
      *
      *****************************************************************
     FPlmsgql1  uF   e           k disk
     Fplactdrvp UF A e           k disk
     Fmclocat   iF   e           k disk
     Funits     iF   e           k disk
     Funitsdr1  iF   e           k disk    rename(runitmas:dr1)
     Funitsdr2  iF   e           k disk    rename(runitmas:dr2)
     Fpltintp   iF   E           k DISK    usropn

AR003d rtvtimz         pr                  extpgm('RTVTIMZ')
AR003d   offset                       2a
       //procedure prototypes
DR001D***cancelPP        PR                  ExtPgm('PLTPPCANR')
DR001D*** PP                            7a
      * Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      * Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)
     d dlycmd11        c                   const('DLYJOB (')
     d dlycmd12        c                   const(')')
      *
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
     D appcode         s              2a   inz('FM')
     d currentorder    s              7a
     d currentdisp     s              2a
     d process         s              1a
     D @tlfifth        s              1a
     D @tlefs          s              1a
     D @tlrbd          s              1a
     D @tlifw          s              1a
     D @tlilrs         s              1a
     D @tlfloor        s              1a
     D @tlcr           s              1a
     D @tluc           s              1a
     D @tlexp          s             74a
     D @tank           s              1a
     D @trbtr          s              1a
     D @trdc           s              1a
     D @trbb           s              1a
     D @trab           s              1a
     D @trint          s              1a
     D @trfr           s              1a
     D @trexp          s             74a
     D @rfc            s            200a
     D @type           s              2a
     D @DirOdr         s              7a
     D @Comment        s             40a
     D @ldulyet        s              1a
     D @reason         s             25a
     d timefix         s               z
AR003d offset          S              2a
AR004d @custCode       s             15a
AR004d @dropTrlr       s              3a
AR004d @dropTrlrYN     s              1a
AR004d @dropTrlr#      s             14a

      /free
        dou *inlr = *on;
AR003     rtvtimz(offset);
        exsr main;
        exsr delayjob;
        enddo;
        *inlr = *on;

        //------------------------------------------------
        //------------------------------------------------
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
          dlycmd = %trim(dlycmd11) + %trim(pltdftdly4) + dlycmd12;
          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr main;
        process = *off;
        setll appCode plmsgql1;
        reade appCode plmsgql1;
        dow  %eof(plmsgql1) = *off;

        timefix = plquets;
        //timefix = %timestamp(timefix) - %Hours(7);
AR003   timefix = %timestamp(timefix) - %Hours(%Int(offset));
        timestamp6 = %timestamp(timefix);

        pldrvcd1= %XLATE(lo:up:pldrvcd1);
        pldrvcd2= %XLATE(lo:up:pldrvcd2);

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

        if  process = *on;
        select;

        when plmsgtyp = 'trailerInspectionCAUS';
        Clear MacQue;
        tranType = '002';
        exsr CanToUSTrailer;

        when plmsgtyp = 'tractorInspectionCAUS';
        Clear MacQue;
        tranType = '002';
        exsr CanToUSTractor;

        when plmsgtyp = 'TankLevel';
        Clear MacQue;
        tranType = '002';
        exsr TankLevel;

        when plmsgtyp = 'runningLate';
        Clear MacQue;
        tranType = '002';
        exsr RunLate;

        when plmsgtyp = 'directionRequest';
        Clear MacQue;
        tranType = '002';
        exsr ReqDir;

        when plmsgtyp = 'fuelRequest';
        Clear MacQue;
        tranType = '002';
        exsr FuelRequest;

        when plmsgtyp = 'resendLoadAssignment';
        Clear MacQue;
        tranType = '002';
        exsr ResendLoad;

        when plmsgtyp = 'LoadUnloadStatus';
        Clear MacQue;
        tranType = '002';
        exsr LoadStatus;

AR004   when plmsgtyp = 'tCall';
  |     Clear MacQue;
  |     tranType = '002';
AR004   exsr tCall;

        endsl;
        exsr  whitelist;

        plproc = 'Y';
        update plmsgqr;
      //delete plmsgqr;
        endif;
        reade appCode plmsgql1;
        enddo;
        endsr;
        //------------------------------------------------
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
       begsr LoadStatus;
          clear @ldulyet;
          clear @reason;
        exsr header;
        form     = '032';

          retocc = %scan('"Status":':plpaylod);
          if retocc > 0;
              S = retocc + 10;
          E = %scan('"':plpaylod:S);
              L = E - S;
          monitor;
              @ldulyet= %trim(%subst(plpaylod:S:L));
              @ldulyet= %xlate('"':' ':@ldulyet);
          on-error;
              @ldulyet= *blanks;
          endmon;
          endif;

          retocc = %scan('"Explanation":':plpaylod);
          if retocc > 0;
              S = retocc + 15;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @reason = %trim(%subst(plpaylod:S:L));
              @reason = %xlate('"':' ':@reason);
              @reason = %XLATE(lo:up:@reason);
           on-error;
              @reason = *blanks;
          endmon;

          endif;

        msgbody=@ldulyet + @reason;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
AR004  begsr tCall;
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

         msgbody = @custCode + @dropTrlrYN + @dropTrlr#;

          DQFLD = MacQue;
          DQ    = 'PEOPLEINQ';
          exsr senddtaq;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr ResendLoad;
          clear @comment;
        exsr header;
        form     = '063';

          retocc = %scan('"Comments":':plpaylod);
          if retocc > 0;
              S = retocc + 12;
          E = %scan('"':plpaylod:S);
          if e > 0;
              L = E - S;
           monitor;
              @comment= %trim(%subst(plpaylod:S:L));
              @comment= %xlate('"':' ':@comment);
              @comment= %XLATE(lo:up:@comment);
           on-error;
              @comment= *blanks;
           endmon;
          endif;
          endif;

        msgbody=@comment;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr CanToUSTrailer;
          clear @tlfifth;
          clear @tlefs    ;
          clear @tlrbd    ;
          clear @tlifw    ;
          clear @tlilrs   ;
          clear @tlfloor  ;
          clear @tlcr     ;
          clear @tluc     ;
          clear @tlexp    ;
        exsr header;
        form     = '061';

          retocc = %scan('"FifthWheel":':plpaylod);
          if retocc > 0;
              S = retocc + 14;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlfifth = %trim(%subst(plpaylod:S:L));
              @tlfifth = %xlate('"':' ':@tlfifth);
           on-error;
              @tlfifth = *blanks;
           endmon;
          endif;

          retocc = %scan('"ExteriorFrontSide":':plpaylod);
          if retocc > 0;
              S = retocc + 21;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlefs = %trim(%subst(plpaylod:S:L));
              @tlefs = %xlate('"':' ':@tlefs);
           on-error;
              @tlefs = *blanks;
           endmon;
          endif;

          retocc = %scan('"RearBumperDoor":':plpaylod);
          if retocc > 0;
              S = retocc + 18;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlrbd = %trim(%subst(plpaylod:S:L));
              @tlrbd = %xlate('"':' ':@tlrbd);
           on-error;
              @tlrbd = *blanks;
           endmon;
          endif;

          retocc = %scan('"InsideFrontWall":':plpaylod);
          if retocc > 0;
              S = retocc + 19;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlifw = %trim(%subst(plpaylod:S:L));
              @tlifw = %xlate('"':' ':@tlifw);
           on-error;
              @tlifw = *blanks;
           endmon;
          endif;

          retocc = %scan('"InsideLeftRightSides":':plpaylod);
          if retocc > 0;
              S = retocc + 24;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlilrs= %trim(%subst(plpaylod:S:L));
              @tlilrs= %xlate('"':' ':@tlilrs);
           on-error;
              @tlilrs= *blanks;
           endmon;
          endif;

          retocc = %scan('"Floor":':plpaylod);
          if retocc > 0;
              S = retocc +  9;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlfloor= %trim(%subst(plpaylod:S:L));
              @tlfloor= %xlate('"':' ':@tlfloor);
           on-error;
              @tlfloor=*blanks;
           endmon;
          endif;

          retocc = %scan('"CeilingRoof":':plpaylod);
          if retocc > 0;
              S = retocc + 15;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tlcr   = %trim(%subst(plpaylod:S:L));
              @tlcr   = %xlate('"':' ':@tlcr);
           on-error;
              @tlcr   =*blanks;
           endmon;
          endif;

          retocc = %scan('"Undercarriage":':plpaylod);
          if retocc > 0;
              S = retocc + 17;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @tluc   = %trim(%subst(plpaylod:S:L));
              @tluc   = %xlate('"':' ':@tluc);
           on-error;
              @tluc   =*blanks;
           endmon;
          endif;

          retocc = %scan('"Explanation":':plpaylod);
          if retocc > 0;
              S = retocc + 15;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @tlexp  = %trim(%subst(plpaylod:S:L));
              @tlexp  = %xlate('"':' ':@tlexp);
              @tlexp  = %XLATE(lo:up:@tlexp);
           on-error;
              @tlexp  = ' ';
           endmon;
          endif;

        msgbody=@tlfifth + @tlefs + @tlrbd + @tlifw +
        @tlilrs + @tlfloor + @tlcr + @tluc + @tlexp;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr CanToUSTractor;
          clear @trbtr;
          clear @trdc    ;
          clear @trbb    ;
          clear @trab     ;
          clear @trint    ;
          clear @trfr     ;
          clear @trexp    ;
        exsr header;
        form     = '060';

          retocc = %scan('"BumpersTiresRims":':plpaylod);
          if retocc > 0;
              S = retocc + 20;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @trbtr = %trim(%subst(plpaylod:S:L));
              @trbtr = %xlate('"':' ':@trbtr);
           on-error;
              @trbtr = *blanks;
           endmon;
          endif;

          retocc = %scan('"DoorsCompartments":':plpaylod);
          if retocc > 0;
              S = retocc + 21;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @trdc  = %trim(%subst(plpaylod:S:L));
              @trdc  = %xlate('"':' ':@trdc);
           on-error;
              @trdc  = *blanks;
           endmon;
          endif;

          retocc = %scan('"BatteryBox":':plpaylod);
          if retocc > 0;
              S = retocc + 14;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @trbb  = %trim(%subst(plpaylod:S:L));
              @trbb  = %xlate('"':' ':@trbb);
           on-error;
              @trbb  = *blanks;
           endmon;
          endif;

          retocc = %scan('"AirBreather":':plpaylod);
          if retocc > 0;
              S = retocc + 15;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @trab = %trim(%subst(plpaylod:S:L));
              @trab = %xlate('"':' ':@trab);
           on-error;
              @trab  = *blanks;
           endmon;
          endif;

          retocc = %scan('"Interior":':plpaylod);
          if retocc > 0;
              S = retocc + 12;
          E = %scan(',':plpaylod:S);
              L = E - S;
           monitor;
              @trint  = %trim(%subst(plpaylod:S:L));
              @trint  = %xlate('"':' ':@trint);
           on-error;
              @trint = *blanks;
           endmon;
          endif;

          retocc = %scan('"FaringRoof":':plpaylod);
          if retocc > 0;
              S = retocc + 14;
              L = 1;
           monitor;
              @trfr   = %trim(%subst(plpaylod:S:L));
              @trfr   = %xlate('"':' ':@trfr);
           on-error;
              @trfr  = *blanks;
           endmon;
          endif;

          retocc = %scan('"Explanation":':plpaylod);
          if retocc > 0;
              S = retocc + 15;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @trexp  = %trim(%subst(plpaylod:S:L));
              @trexp  = %xlate('"':' ':@trexp);
              @trexp  = %XLATE(lo:up:@trexp);
           on-error;
              @trexp  = ' ';
           endmon;
          endif;

        msgbody=@trbtr + @trdc + @trbb + @trab +
        @trint + @trfr + @trexp;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr RunLate;
        exsr header;
        form     = '049';

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr TankLevel;
          clear @tank;
        exsr header;
        form     = '018';

          retocc = %scan('"TankLevel":':plpaylod);
          if retocc > 0;
              S = retocc + 13;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @tank = %trim(%subst(plpaylod:S:L));
              @tank = %xlate('"':' ':@tank);
           on-error;
              @tank = *blanks;
           endmon;
          endif;


        msgbody=@tank;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr ReqDir;
          clear @type;
          clear @DirOdr;
        exsr header;
        form     = '011';

          retocc = %scan('"Type":':plpaylod);
          if retocc > 0;
              S = retocc +  8;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @type = %trim(%subst(plpaylod:S:L));
              @type = %xlate('"':' ':@type);
              @type   = %XLATE(lo:up:@type);
           on-error;
              @type   = *blanks;
           endmon;
          endif;

          retocc = %scan('"OrderNumber":':plpaylod);
          if retocc > 0;
              S = retocc + 15;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @DirOdr = %trim(%subst(plpaylod:S:L));
              @DirOdr = %xlate('"':' ':@DirOdr);
           on-error;
              @DirOdr = *blanks;
           endmon;
          endif;


        msgbody=@type + @DirOdr;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
       begsr FuelRequest;
          clear @tank;
          clear @rfc;
        exsr header;
        form     = '050';

          retocc = %scan('"CurrentTankLevel":':plpaylod);
          if retocc > 0;
              S = retocc + 20;
          E = %scan('"':plpaylod:S);
              L = E - S;
           monitor;
              @tank = %trim(%subst(plpaylod:S:L));
              @tank = %xlate('"':' ':@tank);
           on-error;
              @tank   = *blanks;
           endmon;
          endif;

          retocc = %scan('"ReasonForChange":':plpaylod);
          if retocc > 0;
              S = retocc + 19;
          E = %scan('"':plpaylod:S);
              L = E - S;
              monitor;
              @rfc    = %trim(%subst(plpaylod:S:L));
              @rfc    = %xlate('"':' ':@rfc);
              @rfc    = %XLATE(lo:up:@rfc);
              on-error;
              @rfc    = *blanks;
              endmon;
          endif;


        msgbody=@tank +@rfc;

        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        exsr senddtaq;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr header;
        truck1 = %trim(plunit);
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
          leave;
          readpe(n) plunit mclocat;
          enddo;
        //msg# = '0}';
        outmsg# = '000000}0';
        chain(n) plunit  units;
        if %found(units) = *on;
        currentorder = unord#;
        currentdisp = undisp;
        endif;
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
