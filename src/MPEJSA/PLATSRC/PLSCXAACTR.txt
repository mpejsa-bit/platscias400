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
      *
      *****************************************************************
     FPlmsgqp   iF   e           k disk
     Fplactdrvp if a e           k disk    rename(plactdrvr:l1)
     Fplactdrvp1uf a e           k disk

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

     D up              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'

     D RETOCC          S              7  0 INZ(*ZEROS)
     d E               S              7  0 Inz(*zeros)
     d L               S              7  0 Inz(1)
     d S               S              7  0 Inz(*zeros)
     D appcode         s              2a   inz('HE')
     D @evttyp         s              1a
     D @evtcode        s              1a
     D valid           s              1a
     D count           s              5  0


      /free
        count = 0;

        setll appCode  plmsgqp;
        reade appCode  plmsgqp;
        dow  %eof(plmsgqp) = *off;
          valid = '0';

          retocc = %scan('"event_type":':plpaylod);
          if retocc > 0;
              S = retocc + 13;
              @evttyp = %trim(%subst(plpaylod:S:L));
          endif;

          retocc = %scan('"event_code":':plpaylod);
          if retocc > 0;
              S = retocc + 13;
              @evtcode= %trim(%subst(plpaylod:S:L));
          endif;
          if @evttyp = '5' and @evtcode = '1';
          valid = '1';
          endif;

          if valid = '1';
        chain pldrvcd1 plactdrvp;
        if %found(plactdrvp) = *off;
        chain pldrvcd1 plactdrvp1;
        if %found(plactdrvp1) = *off;
          count = count +1;
          pldrvcode = pldrvcd1;
          write plactdrvr;
          endif;
          endif;
          endif;

        reade appCode  plmsgqp;
        enddo;



        *inlr = *on;
