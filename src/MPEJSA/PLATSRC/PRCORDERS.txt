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
      *  02/03/20   R001  JB/PS  Allow pgm call for single order.
      *****************************************************************
     h DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     h FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     h BNDDIR('YAJL') DECEDIT('0.')
     h alwnull(*USRCTL)

     fmcmsgd    if   e           k disk
     fmcmsghlp  if   e           k disk
     forder     if   e           k disk
     Forderc    if   e           k disk    rename(rorder:cancelord)
     fload      if   e           k disk
     fplactdrvp if   e           k disk
     fplactordp uf   e           k disk
     fpldltordp o    e           k disk

AR001 * This program's Procedure Prototype
  |  dprcorders        pr
  |  d                                7a   options(*nopass)
  |
  |   * This program's Procedure Interface
  |  dprcorders        pi
AR001d inpOrder                       7a   options(*nopass)

     d cancelJob       pr                  extpgm('PLTWFCANR')
     d                               28a

     d sendLoad        pr                  extpgm('MC0047')
     d                                6a
     d                                1a
     d                                1a
     d                                7a
     d                                2a
     d                                4  0
     d                                4  0

     d dlyJob          pr                  extpgm('QCMDEXC')
     d                             3000a   const options(*varsize)
     d                               15p 5 const

     d datCon          pr                  extpgm('DATCON')
     d                                7  0
     d                                6a

     d lcinfo          pr                  extpgm('LCINFO')

     d jobid           s             28a
     d unit#           s              6a
     d mode            s              1a
     d pplan           s              1a
     d order#          s              7a
     d disp#           s              2a
     d ldmil           s              4  0
     d mtmil           s              4  0
     d dlycmd          s             50a   inz(*blanks)
     d w_time          s              4a
     d w_juldat        s              7  0
     d w_grgDat        s              6a
     d w_order         s              7a
     d p_order         s              7a

     d dlycmd11        c                   const('DLYJOB (')
     d dlycmd12        c                   const(')')

       lcinfo();

AR001  if %parms() = 1;
         //process completed or available ICC Orders
         chain inpOrder plactordp;
         if %found(plactordp);
           chain plactord order;
           if %found(order) and (orstat = 'E' or
              (orstat = 'D' and ordsp# = '00' and
               or#dsp > '00') or orstat = 'A' or
              (orstat = 'D' and ordsp# > '00' and
               or#dsp > plactdisp));
             cnord# = plactord ;
             cndisp = plactdisp;
             cncode = 'Z';
             cndate = plmhdate ;
     C                   movel     plmhtime      w_time
             cntime = w_time;
             write  pldltordr;
             delete plactordr;
             jobid = plactord +'-'+ plactdisp +'/?id_type=external';
             canceljob(jobid);
           else;
             chain (plactord:plactdisp) load;
             if %found(load) And didr1 <> pldrvcode;
               cnord# = plactord;
               cndisp = plactdisp;
               cncode = 'Z';
               cndate = plmhdate;
     C                   movel     plmhtime      w_time
               cntime = w_time;
               write  pldltordr;
               delete plactordr;
                 jobid = plactord +'-'+ plactdisp +'/?id_type=external';
                 canceljob(jobid);
             endif;
           endif;
         endif;

AR001  else;
         //retrieve julian date to cover last 10 days.
         w_juldat = *zeros;
         w_grgdat = %char(udate);
         //convert to julian format
         datCon(w_juldat:w_grgdat);

         //process canceled ICC Orders
         orpdat = w_juldat - 10;
         orptim = *loval;
         setll (orpdat:orptim) orderc;
         dou %eof(orderc);
           read orderc;
           if not %eof(orderc);
             setll orodr# plactordp;
             dou %eof(plactordp);
               reade orodr# plactordp;
               if not %eof(plactordp);
                 cnord# = orodr#;
                 cndisp = plactdisp;
                 cncode = 'Z';
                 cndate = orpdat;
                 cntime = orptim;
                 write  pldltordr;
                 delete plactordr;
                 jobid = orodr# +'-'+ or#dsp +'/?id_type=external';
                 canceljob(jobid);
               endif;
             enddo;
           endif;
         enddo;

         //process completed or available ICC Orders
         setll *loval plactordp;
         dou %eof(plactordp);
           read plactordp;
           if not %eof(plactordp);
             chain plactord order;
             if %found(order) and (orstat = 'E' or
                (orstat = 'D' and ordsp# = '00' and
                 or#dsp > '00') or orstat = 'A' or
                (orstat = 'D' and ordsp# > '00' and
                 or#dsp > plactdisp));
               cnord# = plactord ;
               cndisp = plactdisp;
               cncode = 'Z';
               cndate = plmhdate ;
     C                   movel     plmhtime      w_time
               cntime = w_time;
               write  pldltordr;
               delete plactordr;
               jobid = plactord +'-'+ plactdisp +'/?id_type=external';
               canceljob(jobid);
             else;
               chain (plactord:plactdisp) load;
               if %found(load) And didr1 <> pldrvcode;
                 cnord# = plactord;
                 cndisp = plactdisp;
                 cncode = 'Z';
                 cndate = plmhdate;
     C                   movel     plmhtime      w_time
                 cntime = w_time;
                 write  pldltordr;
                 delete plactordr;
                   jobid = plactord +'-'+ plactdisp +'/?id_type=external';
                   canceljob(jobid);
               endif;
             endif;
           endif;
         enddo;

         //retrieve current julian date.
         w_juldat = *zeros;
         w_grgdat = %char(udate);
         //convert to julian format
         datCon(w_juldat:w_grgdat);

         clear p_order;
         //send mc dispatch messages
         mhdate = w_juldat;
         mhtime = *zeros;
         setll (mhdate:mhtime) mcmsghlp;
         dou %eof(mcmsghlp);
           reade mhdate mcmsghlp;
           if not %eof(mcmsghlp) and mhdir = 'O'
                  and (mhpmid = 'T40' or mhpmid = 'T41' or
                       mhpmid = 'T45' or mhpmid = 'T46');
             clear w_order;
             setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
             dou %eof(mcmsgd);
             reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
               if not %eof(mcmsgd);
                 select;
                 when mhpmid = 'T45' and mdrec# = 03;
                   w_order = %subst(mdmsgs:9:7);
                   leave;
                 when mhpmid = 'T46' and mdrec# = 02;
                   w_order = %subst(mdmsgs:20:7);
                   leave;
                 when (mhpmid = 'T40' and mdrec# = 02 or
                       mhpmid = 'T41' and mdrec# = 02)
                  and (%subst(mdmsgs:7:4) = 'LA00' or
                       %subst(mdmsgs:7:4) = 'LA90');
                   w_order = %subst(mdmsgs:20:7);
                   leave;
                 endsl;
               endif;
             enddo;

             //skip processing of duplicates
             if w_order <> p_order;
             chain w_order order;
               //process if still active load
               if %found(order) and orstat = 'D'
                 and ordsp# > '00';
                 //send mc message if not previously sent
                 setll w_order plactordp;
                 if not %equal(plactordp);
                   //ensure driver valid for PS processes
                   setll pldrvcode plactdrvp;
                   if %equal(plactdrvp);
                     unit#  = mhunit;
                     mode   = '1';
                     pplan  = 'N';
                     order# = *blanks;
                     disp#  = *blanks;
                     ldmil  = 0;
                     mtmil  = 0;
                   //sendLoad(unit#:mode:Pplan:order#:disp#:ldmil:mtmil);
                     //delay 10 seconds to process active workflow order.
                     dlycmd = %trim(dlycmd11) + ('10') + dlycmd12;
                     //callp DLYJOB(dlycmd:%size(dlycmd));
                     p_order = w_order;
                   endif;
                 endif;
               endif;
             endif;
           endif;
         enddo;
AR001  endif;

         *inlr = *on;
