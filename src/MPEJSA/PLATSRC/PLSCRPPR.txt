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
      *  10/28/19  A001   JB/PS  Increased size of select db fields.
      *  11/10/19  A002   JB/PS  Send alerts for stale heartbeats.
      *  12/11/19   R003  JB/PS  Add gmt offset function call.
      *  07/20/20   R004  JB/PS  Resolve null fuel level
      *
      *****************************************************************
     FPlmsgql1  uF   e           k disk
     FPLTMHBDP  o    e           k disk
     Funits     iF   e           k disk
     Fpltintp   iF   E           k DISK    usropn

AR003d rtvtimz         pr                  extpgm('RTVTIMZ')
AR003d   offset                       2a

      * Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      * Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd
      *
      *
      *
     D MACQUE          DS
     D  seq                    1      3
     D  notused1               4      4
     D  notused2               5      5
     D  trantype               6      8                                         1ack2msg3pos
     D  truck1                 9     16
     D  notused3              17     31
     D  dateTime              32     45  0
     D  lAT7                  46     52  0
     D  lON7                  56     62  0

     D VDS             DS
     D  VA                     1      6
     D                                     DIM(6)
     D  vehl6                  1      6
     D
     D IDS             DS
     D  TA                     1      6
     D                                     DIM(6)
     D  ICTRAC                 1      6
     D up              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'

     d exampleTS       s             20a   inz(*blanks)                         example timestamp
     d body            s           1900a   varying
     D  datetimeChar   s             20
     D timestamp6      s               z
     D RETOCC          S              7  0 INZ(*ZEROS)
     d E               S              7  0 Inz(*zeros)
     d L               S              7  0 Inz(*zeros)
     d S               S              7  0 Inz(*zeros)
     D appcode         s              2a   inz('TH')
     d process         s              1a
     d currentorder    s              7a
     d currentdisp     s              2a
     d @lat            s             10a
     d @lon            s             11a
     d #lat            s              9  6
     d #lon            s              9  6
     d @speed          s              7a
D001 d*@odo            s             11a
A001 d @odo            s             13a
D001 d*@engh           s              8a
A001 d @engh           s             13a
     d @fuel           s              5a
D001 d*@fuelu          s              9a
A001 d @fuelu          s             13a
     d @loga           s             26a
     d timefix         s               z
     d countPos        s              5  0
A002 d time_diff       s             15p 0
AR003d offset          S              2a

      /free
        countPos = 0;
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
          dlycmd = %trim(dlycmd11) + %trim(pltdftdly3) + dlycmd12;

          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
          countPos = countPos + 1;
          if countPos = 30;
     C                   CALL      'PLERRPOC'
          endif;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr main;

        setll appCode plmsgql1;
        reade appCode plmsgql1;
        dow  %eof(plmsgql1) = *off;
        timefix = plquets;
        //timefix = %timestamp(timefix) - %Hours(7);
AR003   timefix = %timestamp(timefix) - %Hours(%Int(offset));
        timestamp6 = %timestamp(timefix);
     c                   movel     plunit        vehl6
     C                   EXSR      VRIGHT
        select;
        when plmsgtyp = 'TelematicHeartbeat';
        Clear MacQue;
        tranType = '003';
        countPos = 0;
        exsr processPosition;


        endsl;

      //plproc = 'Y';
      //update plmsgqr;
        delete plmsgqr;
        reade appCode plmsgql1;
        enddo;
        endsr;

        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr processPosition;
        if plpaylod <> 'null';
        exsr header;
          plthtruck = plunit;
          plthrecv  = timefix;
          //plthrecv  = plrects;

          retocc = %scan('"event":':plpaylod);
          if retocc > 0;
              S = retocc + 9;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthtype = %trim(%subst(plpaylod:S:L));
           plthtype = %xlate('"':' ':plthtype);
          endif;

          retocc = %scan('"logged_at":':plpaylod);
          if retocc > 0;
              S = retocc +13;
          E = %scan(',':plpaylod:S);
              L = E - S;
           @loga    =%trim(%subst(plpaylod:S:L));
           @loga    = %xlate('"':' ':@loga);
           plthloga = %trim(@loga);
          endif;

          retocc = %scan('"heartbeat_id":':plpaylod);
          if retocc > 0;
              S = retocc +16;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthhbid = %trim(%subst(plpaylod:S:L));
           plthhbid = %xlate('"':' ':plthhbid);
          endif;

          retocc = %scan('"speed":':plpaylod);
          if retocc > 0;
              S = retocc + 8;
          E = %scan(',':plpaylod:S);
              L = E - S;
           @speed = %trim(%subst(plpaylod:S:L));
           plthspeed= %dec(@speed:5:2);
          endif;

          retocc = %scan('"odometer":':plpaylod);
          if retocc > 0;
              S = retocc +11;
          E = %scan(',':plpaylod:S);
              L = E - S;
           @odo   = %trim(%subst(plpaylod:S:L));
D001  */   plthodo  = %dec(@odo:9:2);
A001       plthodo  = %dec(@odo:11:2);
          endif;

          retocc = %scan('"odometer_jump":':plpaylod);
          if retocc > 0;
              S = retocc +17;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthodoj  = %trim(%subst(plpaylod:S:L));
           plthodoj = %xlate('"':' ':plthodoj);
          endif;

          retocc = %scan('"heading":':plpaylod);
          if retocc > 0;
            S = retocc +10;
            E = %scan(',':plpaylod:S);
            L = E - S;
            monitor;
              plthhead = %int(%trim(%subst(plpaylod:S:L)));
            on-error;
              plthhead = 0;
            endmon;
          endif;

          retocc = %scan('"ignition":':plpaylod);
          if retocc > 0;
              S = retocc +11;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthigns = %trim(%subst(plpaylod:S:L));
           plthigns = %xlate('"':' ':plthigns);
          endif;

          retocc = %scan('"rpm":':plpaylod);
          if retocc > 0;
              S = retocc + 7;
          E = %scan(',':plpaylod:S);
              L = E - S;
          monitor;
           plthrpm  = %int(%trim(%subst(plpaylod:S:L)));
          on-error;
           plthrpm  = 0;
          endmon;
          endif;

          retocc = %scan('"engine_hours":':plpaylod);
          if retocc > 0;
              S = retocc +15;
          E = %scan(',':plpaylod:S);
              L = E - S;
           @engh  = %trim(%subst(plpaylod:S:L));
           monitor;
D001  */   plthengh = %dec(@engh:8:2);
A001       plthengh = %dec(@engh:11:2);
           on-error;
           plthengh = 0;
           endmon;
          endif;

          retocc = %scan('"engine_hours_jump":':plpaylod);
          if retocc > 0;
              S = retocc +21;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthenghj = %trim(%subst(plpaylod:S:L));
           plthenghj= %xlate('"':' ':plthenghj);
          endif;

          retocc = %scan('"wheels_in_motion":':plpaylod);
          if retocc > 0;
              S = retocc +19;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthwinm  = %trim(%subst(plpaylod:S:L));
           plthwinm = %xlate('"':' ':plthwinm);
          endif;

          retocc = %scan('"accuracy":':plpaylod);
          if retocc > 0;
              S = retocc +12;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthacu   = %trim(%subst(plpaylod:S:L));
           plthacu  = %xlate('"':' ':plthacu);
          endif;

          retocc = %scan('"satellites":':plpaylod);
          if retocc > 0;
              S = retocc +13;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthsat  = %int(%trim(%subst(plpaylod:S:L)));
          endif;

          retocc = %scan('"gps_valid":':plpaylod);
          if retocc > 0;
              S = retocc +12;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthgpsv  = %trim(%subst(plpaylod:S:L));
           plthgpsv = %xlate('"':' ':plthgpsv);
          endif;

          retocc = %scan('"hdop":':plpaylod);
          if retocc > 0;
              S = retocc + 8;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthhdop  = %trim(%subst(plpaylod:S:L));
           plthhdop = %xlate('"':' ':plthhdop);
          endif;

          retocc = %scan('"fuel_level":':plpaylod);
          if retocc > 0;
              S = retocc +13;
          E = %scan(',':plpaylod:S);
              L = E - S;
AR004     monitor;
            @fuel = %trim(%subst(plpaylod:S:L));
AR004       @fuel = %xlate('"':' ':@fuel);
AR004     on-error;
AR004        @fuel= '0000';
AR004     endmon;
AR004       if @fuel <> 'null' and @fuel <> 'ull';
              plthfuel = %dec(@fuel:4:1);
AR003       endif;
          endif;

          retocc = %scan('"total_fuel_used":':plpaylod);
          if retocc > 0;
              S = retocc +18;
          E = %scan(',':plpaylod:S);
              L = E - S;
           @fuelu = %trim(%subst(plpaylod:S:L));
           monitor;
D001  */   plthfuelu = %dec(@fuelu:7:2);
A001       plthfuelu = %dec(@fuelu:11:2);
           on-error;
D001  */   plthfuelu = 1  ;
A001       plthfuelu = 0;
           endmon;
          endif;

          retocc = %scan('"latitude":':plpaylod);
          if retocc > 0;
              S = retocc +11;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @lat  = %trim(%subst(plpaylod:S:L));
              #lat = %dec(@lat:9:6);
           plthlat = %dec(@lat:9:6);
              lat7 = (#lat *3600);
          endif;

          retocc = %scan('"longitude":':plpaylod);
          if retocc > 0;
              S = retocc +12;
          E = %scan(',':plpaylod:S);
              L = E - S;
              @lon  = %trim(%subst(plpaylod:S:L));
              #lon = %dec(@lon:9:6);
           plthlon = %dec(@lon:9:6);
              lon7 = (#lon *3600)*-1;
          endif;

          retocc = %scan('"description":':plpaylod);
          if retocc > 0;
              S = retocc +15;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthlocd  = %trim(%subst(plpaylod:S:L));
           plthlocd = %xlate('"':' ':plthlocd);
          endif;

          retocc = %scan('"distance":':plpaylod);
          if retocc > 0;
              S = retocc +11;
          E = %scan('",':plpaylod:S);
              L = E - S;
       //  plthrpd  = %int(%trim(%subst(plpaylod:S:L)));
          endif;

          retocc = %scan('"unit_of_measure":':plpaylod);
          if retocc > 0;
              S = retocc +19;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthrum   = %trim(%subst(plpaylod:S:L));
           plthrum  = %xlate('"':' ':plthrum);
          endif;

          retocc = %scan('"direction":':plpaylod);
          if retocc > 0;
              S = retocc +13;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthrdir  = %trim(%subst(plpaylod:S:L));
           plthrdir = %xlate('"':' ':plthrdir);
          endif;

          retocc = %scan('"city":':plpaylod);
          if retocc > 0;
              S = retocc + 8;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthrcity = %trim(%subst(plpaylod:S:L));
           plthrcity= %xlate('"':' ':plthrcity);
          endif;

          retocc = %scan('"state_code":':plpaylod);
          if retocc > 0;
              S = retocc +14;
          E = %scan(',':plpaylod:S);
              L = E - S;
           plthrstate = %trim(%subst(plpaylod:S:L));
           plthrstate= %xlate('"':' ':plthrstate);
          endif;

          retocc = %scan('"country_code":':plpaylod);
          if retocc > 0;
              S = retocc +16;
       //   E = %scan(',':plpaylod:S);
              L = E +1;
           plthrcuntr  = %trim(%subst(plpaylod:S:L));
           plthrcuntr= %xlate('"':' ':plthrcuntr);
          endif;


        write PLTMHBDR;

A002    //check for stale heartbeat and send alert notification
A002    time_diff = %diff(timefix:plrects:*minutes);
A002    if time_diff > 10;
A002 C                   CALL      'PLERRPOC'
A002    endif;


        //if     plthtype = 'periodic_update';
        DQFLD = MacQue;
        DQ    = 'PEOPLEINQ';
        monitor;
        exsr senddtaq;
        on-error;
        exsr delayjob;
        exsr senddtaq;
        endmon;
        //endif;
        endif;
        endsr;
        //------------------------------------------------
        //------------------------------------------------
        //------------------------------------------------
        begsr header;
        truck1 = %trim(plunit);
        chain(n) ICTRAC  units;
        if %found(units) = *on;
        currentorder = unord#;
        currentdisp = undisp;
        endif;
        datetimeChar = %CHAR(timestamp6 : *iso0);
     c                   movel     datetimeChar  datetime
        endsr;
       //-------------------------------------------------------------------------------------------
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
     C*----------------------------------------------------------------
     C     VRIGHT        BEGSR
     C                   MOVE      *Blanks       ICTRAC
     C                   Z-ADD     6             V                 2 0
     C                   DoW       V > 0
     C                             And VA(V) = *Blanks
     C                   SUB       1             V
     C                   END
     C                   Z-ADD     6             T                 2 0
     C                   DoW       V > 0
     C                             And T > 0
     C                   MOVE      VA(V)         TA(T)
     C                   SUB       1             T
     C                   SUB       1             V
     C                   END
     C                   ENDSR
