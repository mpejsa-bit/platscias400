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
     Fpldltordp if   e           k disk

     D cancelPP        PR                  ExtPgm('PLTPPCANR')
     D  passload                      7a

         setll *loval pldltordp;
         dou %eof(pldltordp);
           read pldltordp;
           if not %eof(pldltordp);
             cancelPP(cnord#);
           endif;
         enddo;

         *inlr = *on;
