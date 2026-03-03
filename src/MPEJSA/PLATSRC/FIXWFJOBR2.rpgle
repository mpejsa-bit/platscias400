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
     Fdrivers   if   e           k disk
     Fplfueldrvpif   e           k disk

     D createJob       PR                  ExtPgm('PLTWFJOBR')
     D  passunit                      6a
     D  passdate                      7s 0 options(*nopass)
     D  passtime                      6s 0 options(*nopass)

     D passunit        s              6a
     D passdate        s              7s 0
     D passtime        s              6s 0

         setll *loval plfueldrvp;
         dou %eof(plfueldrvp);
            read plfueldrvp;
            if not %eof(plfueldrvp);
               chain plfuelcde drivers;
               if %found(drivers) And drstat = 'D';
                 createjob(drunit);
               endif;
            endif;
         enddo;
         *inlr = *on;
