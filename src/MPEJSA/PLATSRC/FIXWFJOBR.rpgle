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
      * Send Workflow jobs using message file.                      *
      *
      *  Program Modification Index
      *
      *    Date    Mod    Who    Description
      *  --------  -----  -----  ------------------------------------
      *****************************************************************
     Forder     if   e           k disk
     Fload      if   e           k disk
     Fplactordl2if   e           k disk

     D createJob       PR                  ExtPgm('PLTWFJOBR')
     D  passunit                      6a
     D  passdate                      7s 0
     D  passtime                      6s 0

     D passunit        s              6a
     D passdate        s              7s 0
     D passtime        s              6s 0
     D wkdate          s              7s 0
     D wktime          s              6s 0

         passdate = 2019323;
         passtime = 074500;
         setll (passdate:passtime) plactordl2;
         dou %eof(plactordl2);
            read plactordl2;
            if not %eof(plactordl2) and plmhtime < 100000;
               chain plactord order;
               if %found(order) and orstat = 'D' and ordsp# > '00';
                  chain (orodr#:or#dsp) load;
                  if %found(load);
                     wkdate = plmhdate;
                     wktime = plmhtime;
                     createjob(diunit:wkdate:wktime);
                  endif;
               endif;
            endif;
         enddo;
         *inlr = *on;
