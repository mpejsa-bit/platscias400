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
     Funits     if   e           k disk
     Fpltmhbdp  if   e           k disk
     Fplactdrvp if   e           k disk

         dou %eof(units);
           read units;
           if not %eof(units) And undel <> 'D';
             clear plthtruck;
             plthtruck = %trim(ununit);
             setll plthtruck pltmhbdp;
             if not %equal(pltmhbdp) And undr1 > *blanks;
               setll undr1 plactdrvp;
               if %equal(plactdrvp);
                 iter;
               endif;
             endif;
           endif;
         enddo;

         *inlr = *on;
