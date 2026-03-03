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
     FPlmsgql2  iF   e           k disk
     Fplactdrvp UF   e           k disk

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
        setll *loval  plactdrvp;
        read plactdrvp;
        dow  %eof(plactdrvp) = *off;

        if pldrvcode <> 'kelmi1' and
           pldrvcode <> 'PSTST1' and
           pldrvcode <> 'PSTST2' and
           pldrvcode <> 'PSTST3' and
           pldrvcode <> 'EVIL1 ' and
           pldrvcode <> 'BARST ' and
           pldrvcode <> 'GITZAR' ;
          valid = '0';
        setll (pldrvcode:appCode) plmsgql2;
        reade (pldrvcode:appCode) plmsgql2;
        dow  %eof(plmsgql2) = *off;

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
          leave;
          endif;

        reade (pldrvcode:appCode) plmsgql2;
        enddo;
          if valid = '1';
          else;
        count = count +1;
          valid = '0';
       // delete plactdrvr;
          endif;


          endif;
        read plactdrvp;
        enddo;

        *inlr = *on;
