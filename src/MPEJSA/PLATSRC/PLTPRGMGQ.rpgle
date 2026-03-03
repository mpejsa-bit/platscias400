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
     H DftActGrp(*No) ActGrp(*New)
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     Fplmsgql3  uf   e           k disk

      * This program's Procedure Prototype
     Dpltprgmgq        PR
     D                                3  0 options(*nopass)

      * This program's Procedure Interface
     Dpltprgmgq        PI
     D purgeDays                      3  0 options(*nopass)

     D purgeDate       s               z
     D #Days           s              3  0 inz(93)

       if %parms() = 1;
         #Days = purgeDays;
       endif;

         purgeDate = %timestamp(%date - %days(#Days));
         setll *loval plmsgql3;

         dou %eof(plmsgql3);
           read plmsgql3;
           if not %eof(plmsgql3) And plrects < purgeDate;
             delete plmsgqr;

           elseif not %eof(plmsgql3) And plrects >= purgeDate;
             setgt plapp plmsgql3;
           endif;
         enddo;

         *inlr = *on;
