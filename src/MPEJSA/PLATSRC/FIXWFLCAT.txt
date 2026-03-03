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
     Fmclocatl1 uf   e           k disk

         setll *loval mclocatl1;
         dou %eof(mclocatl1);
           read(e) mclocatl1;
           if %eof(mclocatl1);
             leave;
           endif;
           if %error();
             read(n) mclocatl1;
             iter;
           endif;
           if not %eof(mclocatl1) and (ullatdd = 0.0 or ullondd = 0.0);
             if ullat > 0 and ullong > 0;
               //convert address lat whole seconds to decimal degrees
               eval(h) ullatdd = ullat / 3600;
               //convert address lon whole seconds to decimal degrees
               eval(h) ullondd = ullong / 3600 * -1;
               update rmclocat;
             endif;
           endif;
         enddo;

         *inlr = *on;
