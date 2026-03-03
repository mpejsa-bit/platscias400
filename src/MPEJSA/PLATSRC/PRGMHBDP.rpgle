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
     Fpltmhbdp  uf   e           k disk

      * This program's Procedure Prototype
     Dpltprghbd        PR
     d                                3s 0 options(*nopass)

      * This program's Procedure Interface
     Dpltprghbd        PI
     d purgeDays                      3s 0 options(*nopass)


     D purgeDate       s               z
     D #Days           s              3  0 inz(93)

       if %parms() = 1;
         #Days = purgeDays;
       endif;
         purgeDate = %timestamp(%date - %days(#Days));
         setll *loval pltmhbdp;
         dou %eof(pltmhbdp);
           read pltmhbdp;
           if not %eof(pltmhbdp) And plthrecv < purgeDate;
             delete pltmhbdr;
           endif;
         enddo;

         *inlr = *on;
