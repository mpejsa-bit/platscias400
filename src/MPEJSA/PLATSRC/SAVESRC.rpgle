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
      * sion of Platform Science.      Copyright 2019-2020.         *
      *                                                               *
      *                                                               *
      *---------------------------------------------------------------*
      *  Program Description                                          *
      * Send Workflow jobs using message file.                      *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  -------------------------------------*
      *  10/31/19  001    JB/PS  Remove autocomplete generation.
      *  11/06/19  002    JB/PS  Implement Driver Teams with config.
      *  11/12/19  003    MP/PS  Remove update of team drivers - update by singl
      *  12/05/19  R004   JB/PS  Add driver code to Cancel Preplan API
      *  12/09/19  R005   JB/PS  Resolve appointment timezone error from
      *                          mismatched customer stopoff records.
      *  12/13/19  R006   MP/PS  Use trailer from load assignment
      *  12/16/19  R007   JB/PS  Sync Stopoff Identifier.
      *  12/17/19  R008   JB/PS  Add dest cust coordinates to routing,
      *                          and removed exclusion of segments.
      *  12/17/19  R009   JB/PS  Read Order Routes in sequence order.
      *  12/18/19  R010   JB/PS  Implement fuel stops with config.
      *  12/27/19  R011   JB/PS  Remove date conversion if no eta.
      *  01/03/20  R012   JB/PS  Removed driver code translations.
      *  01/07/20  R013   JB/PS  Reinitialize order by sequence.
      *  01/07/20  R014   JB/PS  Link message for stopoff drops.
      *  01/09/20  R015   JB/PS  Remove long delay for idsc wait.
      *  01/20/20  R016   JB/PS  Implement fuel stop route segment.
      *  01/21/20  R017   JB/PS  Validate country code if not US.
      *  01/22/20  R018   JB/PS  Verify MC records are read to process.
      *  02/04/20  R019   JB/PS  Softcode server field url links.
      *  02/05/20  R020   JB/PS  Ensure retrieval of outbound messages.
      *  02/08/20  R021   JB/PS  Customize for outbound macro formats.
      *  02/10/20  R022   JB/PS  Augment for standard route check.
      *  02/25/20  R023   JB/PS  Output short route format for each stop.
      *  02/27/20  R024   JB/PS  Split Navigation and Fuel enable flags.
      *****************************************************************
      //
     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTPPS/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)
     Fload      if   e           k disk
     Forder     if   e           k disk
     Funits     if   e           k disk
     Fdrivers   if   e           k disk
DR005F***stopoff   if   e           k disk
     Fcomment   if   e           k disk
     Fmccstllp  if   e           k disk
DR005F***custmast  if   e           k disk
     Fcities    if   e           k disk
     FcitiesL3  if   e           k disk    rename(rcities:cityl3)
AR017Fftstate   if   e           k disk
     Fcustmaspp if   e           k disk    rename(rcustmas:custpp)
     Fplactordp uf a e           k disk
     Fplnavdrvp if   e           k disk
AR010Fplfueldrvpif   e           k disk
     Fmcmsgh    if   e           k disk
     Fmcmsgd    if   e           k disk
     Fef2reql2  if   e           k disk
     Fef2rtepPS if   e           k disk
     Fplscope   if   E           k DISK
A002 Fpltintp   if   E           k DISK    usropn
AR005FrteStopl1 if   e           k disk
AR010Fef2Route  if   e           k disk
AR011Floade     if   e           k disk

      /include yajl_h
      /copy libhttpps/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltwfjobr        PR
     d                                6a
     d                                7s 0
     d                                6s 0

      * This program's Procedure Interface
     Dpltwfjobr        PI
     d mhunit                         6a
     d mhdate                         7s 0
     d mhtime                         6s 0

     D incoming        PR            10I 0
     D                               10I 0 value
     D                             8192A   options(*varsize)
     D                               10I 0 value
       //?procedure prototypes
      *-----------------------------------------------------------
     D cancelPP        PR                  ExtPgm('PLTPPCANR')
     D  PP                            7a
AR004D  drvcde                        6a   options(*nopass)
     D cpylnk          PR                  ExtPgm('PLCPYLNK')
     D  filename                     10a
     D rtvtimz         PR                  ExtPgm('RTVTIMZ')
     D   offset                       2a
     D translate       PR                  ExtPgm('QDCXLATE')
     D   length                       5P 0 const
     D   myJson                   32766A   options(*varsize)
     D   table                       10A   const
     D pltauthr        PR                  ExtPgm('PLTAUTHR')
     D   scope                       30
     D   token                     1224
     d/COPY QSYSINC/QRPGLESRC,qusec
     D  inFmt          s             10A
     D  indate         s             64A
     D  error          s              1A
     D  outFmt         s             10A
     D  outDt          s             64A
     D  APIerror       ds                  LikeDS(QUSEC) INZ
     D QWCCVTDT        PR                  ExtPgm('QWCCVTDT')
     D  inFmt                        10A   Const
     D  inDate                       64A   Const
     D  outFmt                       10A   Const
     D  outDt                        64A   OPTIONS(*VARSIZE)
     D  APIerror                           LikeDS(QUSEC) OPTIONS(*VARSIZE)
     D zdte            S              6A
     D zdter           S              7A

      // Prototype to call DLYJOB
     dDLYJOB           pr                  extpgm('QCMDEXC')
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)
     d dlycmd11        c                   const('DLYJOB (')
     d dlycmd12        c                   const(')')

      * load origing
     D orgline1        DS            40
     D info1                   1     40A
     D orgline2        DS            40
     D orgtrip                 7     13A
     D orgstps                35     36  0
     D orgline3        DS            40
     D orgcust                 9     40A
     D orgline4        DS            40
     D orgaddr                 9     40A
     D orgline5        DS            40
     D orgaddr1                9     40A
     D orgline6        DS            40
     D orgctyst                9     37A
     D orgline7        DS            40
     D orgphone               17     28A
     D orgline8        DS            40
     D orgcont                17     40A
     D orgline9        DS            40
     D orgpudt                14     18A
     D orgpudm                14     15  0
     D orgpudd                17     18  0
     D orgputm                20     24A
     D orgpuh                 20     21  0
     D orgpum                 23     24  0
     D orgpudt1               28     32A
     D orgpudm1               28     29  0
     D orgpudd1               31     32  0
     D orgputm1               34     38A
     D orgpuh1                34     35  0
     D orgpum1                37     38  0
     D orgline10       DS            40
     D orgpu#                 12     40A
     D orgline11       DS            40
     D orgwgt                  9     14A
     D orgpcs                 23     27A
     D orgline12       DS            40
     D orgfrt                 10     40A
     D orgline13       DS            40
     D orgbol#                10     40A
     D orgline14       DS            40
     D info14                  1     40A
     D orgline15       DS            40
     D orgtrl                  8     13A
     D orgline16       DS            40
     D orgtr2                  8     13A
     D orgline17       DS            40
     D orgtr3                  8     13A

      * stops array
     D stpline1        DS            40
     D stpinfo                 1     40
     D stpline2        DS            40
     D stptrip                 7     13A
     D stpla                  28     29  0
     D stpline3        DS            40
     D stptype                16     16A
     D stpline4        DS            40
     D stpcust                11     40A
     D stpline5        DS            40
     D stpaddr                11     40A
     D stpline6        DS            40
     D stpaddr2               11     40A
     D stpline7        DS            40
     D stpctyst               11     39A
     D stpline8        DS            40
     D stpphon                11     22A
     D stpline9        DS            40
     D stppudt                18     22A
     D stppudm                18     19  0
     D stppudd                21     22  0
     D stpputm                30     34A
     D stppuh                 30     31  0
     D stppum                 33     34  0
     D stpline10       DS            40
     D stppu#                 16     40A
     D stpline11       DS            40
     D stpbol#                 6     40A

      * load destination
     D dstline1        DS            40
     D dstcust                11     40A
     D dstline2        DS            40
     D dstaddr                11     40A
     D dstline3        DS            40
     D dstaddr1               11     40A
     D dstline4        DS            40
     D dstctyst               11     39A
     D dstline5        DS            40
     D dstphone               15     26A
     D dstline6        DS            40
     D dstcont                15     40A
     D dstline7        DS            40
     D dstpudt                14     18A
     D dstpudm                14     15  0
     D dstpudd                17     18  0
     D dstputm                20     24A
     D dstpuh                 20     21  0
     D dstpum                 23     24  0
     D dstpudt1               27     31A
     D dstpudm1               27     28  0
     D dstpudd1               30     31  0
     D dstputm1               33     37A
     D dstpuh1                33     34  0
     D dstpum1                36     37  0
     D dstline8        DS            40
     D orgdrv1                12     12A
     D dstdrv1                33     33A
     D dstline9        DS            40
     D orgmlsload             14     18A
     D orgmlsempty            34     38A
     D dstline10       DS            40

      * '2019-06-04-10.06.39.948000'
     D timeUTC         DS
     D ccyy                           4A
     D dash1                          1A   inz('-')
     D mm                             2A
     D dash2                          1A   inz('-')
     D dd                             2A
     D dash3                          1A   inz('-')
     D hh                             2a
     D period1                        1A   inz('.')
     D min                            2a
     D period2                        1A   inz('.')
     D sec                            2a
     D** period3                        1A   inz('.')
     D** milisec                        6a   inz('000000')
     D date8           DS
     d year                           4a
     d month                          2a
     d day                            2a
     d date8full               1      8  0

     D latitude9c      DS             9
     D latwhole                4      5A
     D latdec                  6      9A

     D longitude9c     DS            10
     D lngNeg                  1      2A
     D lngZero                 3      3A
     D lngwhole                3      5A
     D lngdec                  6     10A

AR022d diRout          ds
  |  d diCty                          6    dim(7)
AR022d diLC                           1    dim(6)

     D up              C                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lo              C                   'abcdefghijklmnopqrstuvwxyz'

     D UTCendSys       DS
     D UTCendN                        1a   inz('-')
     D UTCendHH                       2a   inz('06')
     D UTCendNColon                   1a   inz(':')
     D UTCendNM                       2a   inz('00')

     D UTCFormat       s             25a
     D** UTCend          s              6a   inz('-07:00')
     D UTCend          s              6a   inz('-08:00')
     D colon           s              1a   inz(':')
     D T               s              1a   inz('T')
     D TS              s               z
     D len             s             10I 0
     D timestamp       s             26  0
     D timestampChar   s             26a
     D errMsg          s            500a   varying
     D jsonString      s          65535a
     D myJSON          S          65535a   varying
     D offset          S              2a
     D custTZ          S              2a
     D filename        s             10a
     D RC              S             10I 0
     d Server          S            256a
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)
     D Order#          s              7a
     D Disp            s              2a
     D commentsA       s             45    dim(99)
     D comments        s           1500a
     D savemdrec       s              2  0
     D X               s              5  0
     D Y               s              5  0
     D stop#           s              2  0
DR007D***savestop#       s              2  0
     D @endUrl         s             45a
     D dateconv        s              7  0
     D timeconv        s              4a
     D geoarrive       s              1a
     D autocomplete    s              1a
     d orderBy         s              4  0
     d JobId           s             10a
     d PP              s              7a
AR004d drvcde          s              6a
     d JobId1          s             17a
     D   ResultStr     s               a   len(16000000) varying
     D   SendStr       s               a   len(16000000) varying
     D  message        s           5000a
     D  messageA       s             40a   dim(50)
     D  messageB       s             40a   dim(1000)
     D  messageBn      s          40000a
     D  messageA41     s             40a   dim(1000)
     D cust#           s              6a
     D checkname       s             25a
     D checkadr        s             25a
     D checkcty        s             15a
     D checkst         s              2a
AR009D checkla         s              2  0
AR014D checktype       s              1a
     d curmonth        s              2  0
     d curyear         s              4  0
     dsmhunit          s              6a
     dsmhdate          s              7  0
     dsmhtime          s              6  0
     dmarktest         s              1a
     dfuel             s              2  0
     D RETOCC          S              7  0 INZ(*ZEROS)
     DNavOn            S              1    INZ(*off)
     DNavOnDrv         S              1    INZ(*off)
AR024DfuelOn           S               n   INZ(*off)
AR010DfuelOnDrv        S               n   INZ(*off)
AR010DrouteOnDrv       S               n   INZ(*off)
AR010DfirstRouteOnDrv  S               n   INZ(*off)
AR017DfoundFuel        S               n   INZ(*off)
AR010Dretbeg           S              7  0 INZ(*ZEROS)
AR010Dretend           S              7  0 INZ(*ZEROS)
AR010Dw_purGaL         S              4    INZ(*blanks)
     Def2Truck         S             50a
     D latitude        S             10
     D longitude       S             10
     D latitude#       S              9  6
     D longitude#      S              9  6
     DrequestId        S              9  0
     Drtesequence      S              3  0
     Drtestop          S              3  0
     DrteChkOrd#       S             50
     d foundSegment    S              1
     d skipSeg         S              1
     d testscop        S              1a
     dfuelsequence     S              3  0
AR018dTRec             s              2s 0
AR018dcycleCnt         s              1s 0
AR018dfullRec          s               n
AR016dpltfuelflg       s              1a
AR016dfuelLatd         s             15s 6 dim(10)
AR016dfuelLong         s             15s 6 dim(10)
AR016dfuelName         s            128a   dim(10)
AR016dorgZip           s                   like(zip)
AR016dstpZip           s                   like(zip)
AR016ddstZip           s                   like(zip)
AR016dorgLat           s                   like(lat)
AR016dstpLat           s                   like(lat)
AR016ddstLat           s                   like(lat)
AR016dgeoLat           s                   like(lat)
AR016dorgLon           s                   like(lon)
AR016dstpLon           s                   like(lon)
AR016ddstLon           s                   like(lon)
AR016dgeoLon           s                   like(lon)
AR016dsavCust          s                   like(orgCust)
AR022dstp              s                   like(seq)
AR017dcountry          s              2a
AR021dorgla            s              2  0
AR021ddstla            s              2  0
AR021dorgtype          s             10a
AR021ddsttype          s             10a
AR021dorgdrvl          s              1a
AR021dstpdrvl          s              1a
AR021ddstdrvl          s              1a
AR022drtLeg            s              6a   dim(100)
AR022drtSeq            s              2s 0 dim(100)
AR022dr#               s              3  0
AR022dc#               s              3  0
AR022dv#               s              3  0
AR022d orgcty          s             30a
AR022d orgst           s              2a
AR022d dstcty          s             30a
AR022d dstst           s              2a
AR022d stpcty          s             30a
AR022d stpst           s              2a
AR022d cityst          s             18a
AR022d flagDepart      s               n   inz(*off)
AR023d routePoints     s               n   inz(*off)

TEMP     //mhunit = 'TESTPS';
TEMP     //mhdate = 2020059;
TEMP     //mhtime = 122109;
         rtvtimz(offset);
         UTCEndHH = offset;
         curmonth =  %subdt(%date():*MONTHS);
         curyear  =  %subdt(%date():*YEARS);
DR013    //orderby = 1;
AR013    clear orderby;
         smhunit = mhunit;
         smhdate = mhdate;
         smhtime = mhtime;
         navOnDrv = *off;
AR010    fuelOnDrv = *off;

DR010    //exsr delayjob;
         chain mhunit units;
         if %found(units) = *on;
           chain undr1 plnavdrvp;
           if %found(plnavdrvp) = *on;
DR015        //exsr delayjob2;
             navOnDrv = *on;
           endif;

AR010      //check for driver testing of fuel stops
  |        if pltfuelflg = '0';
  |          chain undr1 plfueldrvp;
  |          if %found(plfueldrvp);
  |            fuelOnDrv = *on;
AR010        endif;
AR025      elseif pltfuelflg = '1';
  |            fuelOnDrv = *on;
AR010      endif;

           // get all T40 information
AR018      clear cycleCnt;
  |        // ensure all MC records are retrieved for processing.
AR018      dou (TRec > 00 And fullRec) Or cycleCnt = 3;
             exsr loadorigin;
AR018      enddo;
           // get T41 information one for each stop
AR018      clear cycleCnt;
  |        // ensure all MC records are retrieved for processing.
AR018      dou (TRec = 90 And fullRec) Or cycleCnt = 3;
             exsr loadstops;
AR018      enddo;

           exsr BuildWfJob;
           myJSON = jsonString;

           //Once you have it in a string, you can send it to the HTTP server.
           //Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF- (CCSID 1
           //and then use HTTPAPI's http_post() routine to do the POST operation:
           http_setCCSIDs( 1208: 0 );
           HTTP_debug(*on);
           HTTP_SetFileCCSID(1208);

           // Also need code here to set up 'additional headers'
           http_xproc( HTTP_POINT_ADDL_HEADER
                      : %paddr(add_headers) );

DR012      //if undr1 = 'QUEC';
  |        //  undr1 = 'QUEC1';
  |        //endif;
  |        //if undr1 = 'OZEG';
  |        //  undr1 = 'OZEGA';
  |        //endif;
  |        //if undr1 = 'RIOA';
  |        //  undr1 = 'RIOA1';
  |        //endif;
  |        //if undr1 = 'VIDP';
  |        //  undr1 = 'VIDP1';
DR012      //endif;

           chain (unord#:undisp:undr1) plactordp;
           if %found(plactordp) = *on;

A002         //Execute Team Drivers only if interface enabled.
A003         //if pltteamflg = '1' and undr2 <> *blanks;
A003         //Team driver
A003         //   Server = %trim('https://wie-int.pltsci.com/api/jobs/');
A019         //   Server = %trim(pltinturl) + %trim(pltitjobep);
A003         // else;
D019         //   @endUrl = undr1 + '/jobs/'+ JobId;
A019              @endUrl = %trim(undr1) + '/jobs/'+ JobId;
D019         //   Server = %trim('https://wie-int.pltsci.com +
D019         //                      /api/drivers/'+@Endurl);
A019              Server = %trim(%trim(pltinturl) +
A019                       %trim(pltitwfep) + @endUrl);
A003         // endif;

             //this is an update/do a put not a post
             SendStr = %trim(myJson);
             rc=http_req( 'PUT'
                        : %trim(Server)
                        : *omit
                        : ResultStr
                        : *omit
                        : SendStr
                        : 'application/json' );

             //On error, call api to generate hard error.
             if rc = -1;
     C                   CALL      'PLERRORC'
             endif;

             //if no error, Convert the data to EBCDIC
             if rc <> 1;
               //Translate(retlen: retdata: 'QTCPEBC');
               filename = %trim(unord#) + 'WFU';
               monitor;
                 cpylnk(filename);
                 on-error;
               endmon;
             endif;
           else;
A002         //Execute Team Drivers only if interface enabled.
A002         if pltteamflg = '1' and undr2 <> *blanks;
A002           //Team driver
A002           //Server = %trim('https://wie.pltsci.com/api/jobs/');
A019           Server = %trim(pltinturl) + %trim(pltitjobep);
A002         else;
               @endUrl = undr1 + '/jobs';
D019           //Server = %trim('https://wie.pltsci.com/api/drivers/'+@endUrl);
A019           Server = %trim(pltinturl) + %trim(pltitwfep)
A019                          + %trim(@endUrl);
A002         endif;

             //Send web service request to PlatForm Science
             rc=http_url_post_raw(%trim(Server)
                      : %addr( myJSON : *data )
                      : %len( myJSON )
                      : 1
                      : %paddr('INCOMING')
                      : HTTP_TIMEOUT
                      : HTTP_USERAGENT
                      : 'application/json' );

             if rc =  201;
               plactord = unord#;
               plactdisp = undisp;
               pldrvcode = undr1;
               plmhdate  = mhdate;
               plmhtime  = mhtime;
               write plactordr;
             endif;

             //if no error, Convert the data to EBCDIC
             if rc <> 201;
               filename = %trim(unord#) + 'WFC';
               monitor;
                 cpylnk(filename);
               on-error;
               endmon;
               //yajl_saveBuf('/platsci/'+JobId: errMsg);
               //Translate(retlen: retdata: 'QTCPEBC');
             endif;
           endif;
         yajl_genClose();
       endif;

       *inlr = *on;

        //-------------------------------------------------------------------
        //in here we are building a json for WF job      -----------------
        //-------------------------------------------------------------------
        begsr buildWfJob;

          chain unord# order;
          chain (unord#:undisp) load;

          JobId = unord# +'-'+undisp;
          PP = unord#;
AR004     //for dispatch, remove all outdstanding driver preplans
          cancelPP(PP);

          rteChkOrd# = unord# + ' ' + undisp;
          exsr findRouteId;

          yajl_genOpen(*ON);  // use *ON for easier to read JSON
                              // use *OFF for more compact JSON
          yajl_beginObj();

A002        // Execute Team Drivers only if interface enabled.
            //if undr1 = 'KELMI1';
            //  undr1 = 'kelmi1';
            //endif;

A002        if pltteamflg = '1' and undr2 <> *blanks;
A002          yajl_beginArray('drivers');
A002          yajl_addChar(%trim(undr1));
A002          yajl_addChar(%trim(undr2));
A002          yajl_endArray();
A002        endif;

            yajl_addChar('job');

            yajl_beginObj();
              //yajl_addChar('id':JobId);
              yajl_addChar('external_id':JobId);
              yajl_addChar('status':'active');
              //yajl_addChar('status':'pre_assign');
              yajl_addChar('sequence':'0');

              yajl_beginObj();
                yajl_addChar('shipment_details');

                yajl_beginObj();
                  if orhazm = 'Y';
                    yajl_addBool('hazmat':'1');
                  else;
                    yajl_addBool('hazmat':'0');
                  endif;

                  if orjit = 'Y';
                    yajl_addBool('high_value':'1');
                  else;
                    yajl_addBool('high_value':'0');
                  endif;

                  if ortmpl > 0;
                    yajl_addBool('temperature_controlled':'1');
                  else;
                    yajl_addBool('temperature_controlled':'0');
                  endif;

                  yajl_beginObj('total_distance');
                    yajl_addChar('value':%char(ditmil));
                    yajl_addChar('uom':'mi');
                  yajl_endObj();

                  yajl_addChar('line_of_business':'dry');
                  yajl_addChar('prompt_for_fuel':'0');
                  //yajl_addChar('BillOfLading':orcsh#);
                  yajl_addChar('shipping_documents');

                  yajl_beginArray();
                    //yajl_beginObj();
                      //yajl_addChar('type':'seal');
                      //if orsel1 > *blanks;
                         //yajl_addChar('value':orsel1);
                      //else;
                         //yajl_addChar('value':'1');
                      //endif;
                    //yajl_endObj();

                    if orcsh# > *blanks;
                      yajl_beginObj();
                        yajl_addChar('type':'bill of lading');
                        yajl_addChar('value':orcsh#);
                      yajl_endObj();
                    endif;

                    if orwgt > *zeros;
                      yajl_beginObj();
                        yajl_addChar('type':'weight');
                        yajl_addNum('value':%char(orwgt));
                      yajl_endObj();
                    endif;

                    if orpiec > *blanks;
                      yajl_beginObj();
                        yajl_addChar('type':'pieces');
                        yajl_addChar('value':%trim(orpiec));
                      yajl_endObj();
                    endif;

                    if ditrlr <> *blanks;
                      yajl_beginObj();
                        yajl_addChar('type':'Trailer');
                        yajl_addChar('value':%trim(ditrlr));
                      yajl_endObj();
                    endif;

                    if ditrlr = *blanks;
                      if orgtrl <> *blanks;
                        yajl_beginObj();
                          yajl_addChar('type':'Trailer');
                          yajl_addChar('value':%trim(orgtrl));
                        yajl_endObj();
                      endif;
                    endif;
                  yajl_endArray();
                yajl_endObj();

                yajl_addChar('received_at':'');
                yajl_addChar('reviewed_at':'');

                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;

                yajl_beginObj('created_at');
                  yajl_addChar('date':UTCFormat);
                  exsr timezone;
                yajl_endObj();

                yajl_beginObj('updated_at');
                  yajl_addChar('date':UTCFormat);
                  exsr timezone;
                yajl_endObj();

                yajl_addChar('remarks');
                yajl_beginArray();
                  if dismnf > *zeros;
                    yajl_beginObj();
                       yajl_addChar('label':'Loaded Miles');
                       yajl_addChar('value':%char(dismnf));
                       yajl_addChar('order':'1');
                    yajl_endObj();
                  endif;

                  if diemil > *zeros;
                    yajl_beginObj();
                      yajl_addChar('label':'Empty Miles');
                      yajl_addChar('value':%char(diemil));
                      yajl_addChar('order':'2');
                    yajl_endObj();
                  endif;

                  if orcsh# > *blanks;
                    yajl_beginObj();
                      yajl_addChar('label':'Bill of Lading');
                      yajl_addChar('value':%trim(orcsh#));
                      yajl_addChar('order':'3');
                    yajl_endObj();
                  endif;

                  if orcns# > *blanks;
                    yajl_beginObj();
                      yajl_addChar('label':'PO Number');
                      yajl_addChar('value':%trim(orcns#));
                      yajl_addChar('order':'4');
                    yajl_endObj();
                  endif;

                  if ditrlr > *blanks;
                    yajl_beginObj();
                      yajl_addChar('label':'Trailer ');
                    //yajl_addChar('value':%trim(ditrlr)+'_');
                      yajl_addChar('value':%trim(ditrlr));
                      yajl_addChar('order':'5');
                    yajl_endObj();
                  endif;

                  exsr findffdisp;
                  if messageB(1) > *blanks;
                    yajl_beginObj();
                      yajl_addChar('label':'Dispatch Info');
     C                   movea     messageB      MessageBn
                      yajl_addChar('value':%trim(messageBn));
                      yajl_addChar('order':'6');
                     yajl_endObj();
                  endif;

                  exsr getcomments;
                  yajl_beginObj();
                    yajl_addChar('label':'Trip Comments');
     C                   movea     commentsA     comments
                    yajl_addChar('value':%trim(comments));
                    yajl_addChar('order':'7');
                  yajl_endObj();
                yajl_endArray();

AR016           exsr locations;
AR016           exsr steps;

                if NavOn = *on;
                  exsr routeSegments;
                endif;

DR016           //exsr locations;
DR016           //exsr steps;

                yajl_beginArray('driver_alerts');
                  chain (unord#:undisp:undr1) plactordp;
                  if %found(plactordp) = *on;
                    //yajl_beginObj('updated_at');
                    //yajl_addChar('date':UTCFormat);
                    //yajl_endObj();
                  endif;
                yajl_endArray();
              yajl_endObj();

              yajl_addChar('id_type':'external');
            yajl_endObj();

          jsonString = yajl_copyBufStr();
          //yajl_saveBuf('/tmp/example.json': errMsg);
        endsr;

        //-------------------------------------------------------------------
        //go and get free form messages associated with the dispatch
        //-------------------------------------------------------------------
        begsr  findffdisp;

          clear messageB;
          clear messageBn;
          x = 1;
          y = 25;
          dow %subst(messagea(y):1:14) <> '***COMMENTS***'
              And y < 50;
            y +=1;
          enddo;
          dow y < 1000 And messagea(y) > *blanks
                       And x < 50;
            messageB(x) = messagea(y);
            x +=1;
            y +=1;
          enddo;

          setll (smhunit:smhdate:smhtime) mcmsgh;
          reade (smhunit:smhdate) mcmsgh;
          dow %eof(mcmsgh) = *off;
            if mhpmid = '000';
              setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
              reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
              dow %eof(mcmsgd) = *off And x <= 1000;
                retocc = %scan(unord#:mdmsgs);
                if retocc = 0;
                  messageb(x) = mdmsgs;
                  x +=1;
                endif;
              reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
              enddo;
            leave;
            endif;
          reade (smhunit:smhdate) mcmsgh;
          enddo;
        endsr;

        //-------------------------------------------------------------------
        //get load origin information from message file
        //-------------------------------------------------------------------
        begsr loadorigin;

AR018     TRec = *loval;
AR018     fullRec = *off;
          clear messageA;
DR020     //chain (mhunit:mhdate:mhtime) mcmsgh;
AR020     chain (mhunit:mhdate:mhtime:'O') mcmsgh;
          if %found(mcmsgh) = *on;
            if mhpmid = '040';
              setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
              reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
              dow %eof(mcmsgd) = *off;
AR018           if mdrec# = 2;
  |               //TRec = %int(%subst(mdmsgs:4:2));
  |               TRec = 1;
  |               orgtype = 'PICK UP';
  |               orgdrvl = 'N';
  |               dsttype = 'DELIVERY';
  |               dstdrvl = 'N';
  |             elseif mdrec# >= 25;
  |               fullRec = *on;
AR018           endif;
                messageA(mdrec#) = mdmsgs;
                reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
              enddo;
            endif;
          endif;

          orgline1 = messagea(1);
          orgline2 = messagea(2);
          orgline3 = messagea(3);
          orgline4 = messagea(4);
          if %subst(messagea(6):1:13) = 'LOAD AT PHONE';
            orgline5 = *blanks;
            orgline6 = messagea(5);
            orgline7 = messagea(6);
            orgline8 = messagea(7);
            orgline9 = messagea(8);
            orgline10= messagea(9);
            orgline11= messagea(10);
            orgline12= messagea(11);
            orgline13= messagea(12);
            orgline14= messagea(13);
            orgline15= messagea(14);
            orgline16= messagea(15);
            orgline17= messagea(16);
            dstline1 = messagea(17);
            dstline2 = messagea(18);
            if %subst(messagea(20):1:10) = 'CONS PHONE';
              dstline3  = *blanks;
              dstline4  = messagea(19);
              dstline5  = messagea(20);
              dstline6  = messagea(21);
              dstline7  = messagea(22);
              dstline8  = messagea(23);
              dstline9  = messagea(24);
              dstline10 = messagea(25);
            else;
              dstline3  = messagea(19);
              dstline4  = messagea(20);
              dstline5  = messagea(21);
              dstline6  = messagea(22);
              dstline7  = messagea(23);
              dstline8  = messagea(24);
              dstline9  = messagea(25);
            endif;
          else;
            orgline5 = messagea(5);
            orgline6 = messagea(6);
            orgline7 = messagea(7);
            orgline8 = messagea(8);
            orgline9 = messagea(9);
            orgline10= messagea(10);
            orgline11= messagea(11);
            orgline12= messagea(12);
            orgline13= messagea(13);
            orgline14= messagea(14);
            orgline15= messagea(15);
            orgline16= messagea(16);
            orgline17= messagea(17);
            dstline1 = messagea(18);
            dstline2 = messagea(19);
            if %subst(messagea(21):1:10) = 'CONS PHONE';
              dstline3  = *blanks;
              dstline4  = messagea(20);
              dstline5  = messagea(21);
              dstline6  = messagea(22);
              dstline7  = messagea(23);
              dstline8  = messagea(24);
              dstline9  = messagea(25);
              dstline10 = messagea(26);
            else;
              dstline3  = messagea(20);
              dstline4  = messagea(21);
              dstline5  = messagea(22);
              dstline6  = messagea(23);
              dstline7  = messagea(24);
              dstline8  = messagea(25);
              dstline9  = messagea(26);
            endif;
          endif;

AR018     if %eof(mcmsgd) And (TRec < 00 Or not fullRec);
  |         exsr delayjob;
  |       endif;
AR018     cycleCnt += 1;

        endsr;

        //-------------------------------------------------------------------
        //get all stop information from message file
        //-------------------------------------------------------------------
        begsr loadstops;

AR018    clear messageA41;
  |      TRec = 90;
AR018    fullRec = *on;
         x = 0;
         y = 0;
         clear savemdrec;

DR020    //setll (mhunit:mhdate:mhtime) mcmsgh;
AR020    setll (mhunit:mhdate:mhtime:'O') mcmsgh;
         reade (mhunit:mhdate) mcmsgh;
         dow %eof(mcmsgh) = *off;
           if mhpmid = '041';
           setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
           reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
DR027        //dow %eof(mcmsgd) = *off;
AR027        dow %eof(mcmsgd) = *off And mdrec# < 12;
               if mhpmid = '041';
                 //account for an additional address line
                 //if mdrec# = 8 and savemdrec = 6;
                 //  x = x +1;
                 //endif;
                 x = x +1;
                 messageA41(X) = mdmsgs;
               endif;

AR018          if mdrec# = 2;
  |              //TRec = %int(%subst(mdmsgs:4:2));
  |              TRec = 90;
  |              stpdrvl = 'N';
  |            elseif mdrec# >= 9;
  |              fullRec = *on;
AR018          endif;

               savemdrec = mdrec#;
               reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
             enddo;
             if mhunit <> mdunit;
               leave;
             endif;
           endif;
           reade (mhunit:mhdate) mcmsgh;
         enddo;

AR018    if %eof(mcmsgd) And (TRec <> 90 Or not fullRec);
  |        exsr delayjob;
  |      endif;
AR018    cycleCnt += 1;

         endsr;

        //-------------------------------------------------------------------
        //get delivery    information from message file
        //-------------------------------------------------------------------
        begsr loaddelv;

         stpdrvl = 'N';
         stpline1 = messagea41(x);
         x = x +1;
         stpline2 = messagea41(x);
         x = x +1;
         stpline3 = messagea41(x);
         x = x +1;
         stpline4 = messagea41(x);
         x = x +1;
         stpline5 = messagea41(x);
         x = x +1;
         if %subst(messagea41(x+1):1:7) = 'PHONE #';
           stpline6 = *blanks;
         else;
           stpline6 = messagea41(x);
           x = x +1;
         endif;
         stpline7 = messagea41(x);
         x = x +1;
         stpline8 = messagea41(x);
         x = x +1;
         stpline9 = messagea41(x);
         x = x +1;
         stpline10= messagea41(x);
         x = x +1;
         stpline11= messagea41(x);
         x = x +1;
         endsr;

        //-------------------------------------------------------------------
        //get pickup  information from message file
        //-------------------------------------------------------------------
        begsr loadpick;

         stpdrvl = 'N';
         stpline1 = messagea41(x);
         x = x +1;
         stpline2 = messagea41(x);
         x = x +1;
         stpline3 = messagea41(x);
         x = x +1;
         stpline4 = messagea41(x);
         x = x +1;
         stpline5 = messagea41(x);
         x = x +1;
         if %subst(messagea41(x+1):1:7) = 'PHONE #';
           stpline6 = *blanks;
         else;
           stpline6 = messagea41(x);
           x = x +1;
         endif;
         stpline7 = messagea41(x);
         x = x +1;
         stpline8 = messagea41(x);
         x = x +1;
         stpline9 = messagea41(x);
         x = x +1;
         stpline10= messagea41(x);
         x = x +1;
         stpline11= messagea41(x);
         x = x +1;
         endsr;

        //-----------------------------------------------------
        //--get comments for WF job ---------------------------
        //-----------------------------------------------------
        begsr getComments;

        x = 0;
        setll unord# comment;
        reade unord# comment;
      //dow %eof(comment) = *off;
        dow %eof(comment) = *off and x < 99;
        if octyp =  'C';
        x = x + 1;
          retocc = %scan('VOIDED':ocdesc);
          if retocc = 0;
        commentsA(x) = %trim(ocdesc);
          endif;
        endif;
        reade unord# comment;
        enddo;
        endsr;

        //-----------------------------------------------------
        //--build locations ---------------------------
        //-----------------------------------------------------
        begsr Locations;

AR010     routeOnDrv = *off;
  |       clear fuelSequence;
  |       //if Fuel Stops enabled.
  |       if fuelOnDrv;
  |         //verify Load Stops exist for dispatched route.
  |         setll unord# rteStopl1;
  |         if %equal(rteStopl1);
  |           //check for EF fuel & route
  |           chain (requestID:unord#:undisp) ef2Route;
  |           if %found(ef2Route) And seq > *zero;
  |             routeOnDrv = *on;
  |             firstRouteOnDrv = *on;
  |           endif;
  |         endif;
AR010     endif;

AR010     //process existing Load Route.
  |       if routeOnDrv;
AR022       //this section to prep for stop routes/identifiers, and is
  |         //needed if ICC Route Sync is not populated (ORDROUTEP).
  |         clear rtLeg;
  |         clear rtSeq;
  |         r# =1;
  |         //retrieve the ICC load route/stop identifiers.
  |         for v# = 1 to 6;
  |           if diLC(v#) = 'L';
  |             if r# =1;
  |               rtLeg(r#) = diCty(v#);
  |               if undisp > '01';
  |                 rtSeq(r#) = *zero;
  |               else;
  |                 reade unord# rteStopl1;
  |                 if not %eof(rteStopl1) And
  |                    soCtyc + soSt  = rtLeg(r#);
  |                   rtSeq(r#) = soStp#;
  |                 else;
  |                   readpe unord# rteStopl1;
  |                 endif;
  |               endif;
  |               r# +=1;
  |             endif;
  |             rtLeg(r#) = diCty(v# +1);
  |           //rtSeq(r#) = v# +1;
  |             reade unord# rteStopl1;
  |             if not %eof(rteStopl1) And
  |                soCtyc + soSt  = rtLeg(r#);
  |                rtSeq(r#) = soStp#;
  |             else;
  |               readpe unord# rteStopl1;
  |             endif;
  |             r# +=1;
  |           elseif diLC(v#) = *blank;
  |             leave;
  |           endif;
  |         endfor;
  |         //retrieve any route extensions.
  |         if diLC(v#) <> *blank;
  |           c# = 1;
  |           setll (unord#:undisp) loade;
  |           dou %eof(loade);
  |           reade (unord#:undisp) loade;
  |             if not %eof(loade);
  |               for v# = 1 to 6;
  |                 if diLC(v#) = 'L';
  |                   rtLeg(r#) = diCty(v# +1);
  |                 //rtSeq(r#) = v# + 1 + (c# * 6);
  |                   reade unord# rteStopl1;
  |                   if not %eof(rteStopl1) And
  |                     soCtyc + soSt  = rtLeg(r#);
  |                     rtSeq(r#) = soStp#;
  |                   else;
  |                     readpe unord# rteStopl1;
  |                   endif;
  |                   r# +=1;
  |                 elseif diLC(v#) = *blank;
  |                   leave;
  |                 endif;
  |               endfor;
  |             endif;
  |           enddo;
  |         endif;
AR022
  |         //check for EF fuel & route
  |         setll (requestID:unord#:undisp) ef2Route;
  |         if %equal(ef2Route);
  |           yajl_beginArray('locations');
  |             x = 1;
AR022           r# = 1;
  |             dou %eof(ef2Route);
  |               reade (requestId:unord#:undisp) ef2Route;
  |               //only process stop and fuel locations
  |               if not %eof(ef2Route);
  |                 //process pickup & drop stopoffs
  |                 if stoptype = 'S';
AR026                 dow rtleg(r#) <> cicty + cist;
  |                     r# +=1;
  |                     if rtseq(r#) = 00 And rtleg(r#) = *blanks;
  |                       leave;
  |                     endif;
AR026                 enddo;
AR022                 stp = rtSeq(r#);
  |                   select;
  |                   //write corresponding location
  |                   when stp = 01 Or (stp = 00 and r# = 1);
  |                     seq = 01;
  |                     exsr locationStopO;
  |                   when stp > 01 and stp < 90;
  |                     if messageA41(x) > *blanks And soType = 'P';
  |                       exsr loadPick;
  |                       exsr locationStop;
  |                     elseif messageA41(x) > *blanks And soType = 'D';
  |                       exsr loadDelv;
  |                       exsr locationStop;
  |                     endif;
  |                   when stp = 90;
  |                     seq = 90;
  |                     exsr locationStopD;
  |                   endsl;
  |                   r# +=1;
  |                 //write fuel stop locations
  |                 elseif stoptype = 'F';
  |                   stp = 00;
  |                   exsr locationFuel;
  |                 endif;
  |               endif;
  |             enddo;
  |           yajl_endArray();
  |           exsr loadHeaderInfo;
  |         endif;
  |       endif;
  |
  |       //if Driver Fuel Stops disabled,
  |       //  Or either EF Fuel Route or Load Route missing.
  |       if not(fuelOnDrv) Or not(routeOnDrv)
AR010        Or (routeOnDrv and not %equal(ef2Route));

            yajl_beginArray('locations');
  |           seq = 01;
AR010         exsr locationStopO;

              x = 1;
              dow messageA41(x) <> *blanks And x<=989;
                if %subst(messageA41(x+2):16:1) = 'P';
                  exsr loadPick;
                  exsr locationStop;
                elseif %subst(messageA41(x+2):16:1) = 'D';
                  exsr loadDelv;
                  exsr locationStop;
                else;
                  x +=11;
                endif;
              enddo;

              seq = 90;
AR010         exsr locationStopD;

            yajl_endArray();
            exsr loadheaderinfo;
AR010     endif;
        endsr;

        //-----------------------------------------------------
        //--external create update data  --------------
        //-----------------------------------------------------
        begsr externalcrtupd;

          yajl_addChar('external_data':'');

          yajl_beginObj('created_at');
            yajl_addChar('date':UTCFormat);
            exsr timezone;
          yajl_endObj();

          yajl_beginObj('updated_at');
            yajl_addChar('date':UTCFormat);
            exsr timezone;
          yajl_endObj();
        endsr;

        //-----------------------------------------------------
        //--build route segments-----------------------
        //-----------------------------------------------------
        begsr routeSegments;

AR023     //output short points formt: one coordinate for each stop.
AR023     routePoints = *off;

AR023     //process existing Load Route.
  |       if routeOnDrv;
  |         setll unord# rteStopl1;
  |         //check for EF fuel & route
  |         setll (requestID:unord#:undisp) ef2Route;
  |         if %equal(ef2Route);
  |           yajl_beginArray('route_legs');
  |             x = 1;
  |             r# = 1;
  |             dou %eof(ef2Route);
  |               reade (requestId:unord#:undisp) ef2Route;
  |               //only process stop and fuel locations
  |               if not %eof(ef2Route);
  |                 //process pickup & drop stopoffs
  |                 if stoptype = 'S';
AR026                 dow rtleg(r#) <> cicty + cist;
  |                     r# +=1;
  |                     if rtseq(r#) = 00 And rtleg(r#) = *blanks;
  |                       leave;
  |                     endif;
AR026                 enddo;
  |                   stp = rtSeq(r#);
  |                   select;
  |                   //write corresponding location
  |                   when stp = 01 Or (stp = 00 and r# = 1);
  |                     seq = 01;
  |                     exsr addOriginRoute;
  |                   when stp > 01 and stp < 90;
  |                     if messageA41(x) > *blanks And soType = 'P';
  |                       exsr loadPick;
  |                       exsr locationsRoute;
  |                     elseif messageA41(x) > *blanks And soType = 'D';
  |                       exsr loadDelv;
  |                       exsr locationsRoute;
  |                     endif;
  |                   when stp = 90;
  |                     seq = 90;
  |                     exsr locationsRouteD;
  |                   endsl;
  |                   r# +=1;
  |                 //write fuel stop locations
  |                 elseif stoptype = 'F';
  |                   exsr locationsRouteF;
  |                 endif;
  |               endif;
  |             enddo;
  |           yajl_endArray();
  |         endif;
  |       endif;
  |
  |       //if Driver Fuel Stops disabled,
  |       //  Or either EF Fuel Route or Load Route is missing.
  |       if not(fuelOnDrv) Or not(routeOnDrv)
AR023        Or (routeOnDrv and not %equal(ef2Route));
AR016       fuelSequence =1;
            if requestId <> *zeros;
              yajl_beginArray('route_legs');

                rteStop += 1;
AR016           foundFuel = *off;
  |             if fuelOnDrv = *on;
  |               setll (requestId:rteStop) ef2rtepPS;
  |               dou %eof(ef2rtepPS);
  |                 reade (requestId:rteStop) ef2rtepPS;
  |                 if not %eof(ef2rtepPS) and rteFuelnow = 'Y';
  |                   foundFuel = *on;
  |                   leave;
  |                 endif;
  |               enddo;
AR016           endif;

AR023           clear foundFuel;
                exsr addOriginRoute;
                x = 1;
                dow messageA41(x) <> *blanks And x<=989;
                  if %subst(messageA41(x+2):16:1) = 'P';
                    exsr loadPick;
                    exsr locationsRoute;
                  elseif %subst(messageA41(x+2):16:1) = 'D';
                    exsr loadDelv;
                    exsr locationsRoute;
                  else;
                  x +=11;
                  endif;
                enddo;
                exsr locationsRouteD;
              yajl_endArray();
            endif;
          endif;
        endsr;

        //-----------------------------------------------------
        //--add origin route segments   ------------
        //-----------------------------------------------------
        begsr addoriginroute;

          yajl_beginObj();

AR016      if foundFuel;
  |          yajl_addChar('external_id':%trim(JobID) +
  |                       '-'+ %trim(fuelName(fuelSequence)));
  |          savCust = orgCust;
AR016      else;
             yajl_addChar('external_id':%trim(JobID) +
                          '-'+ %trim(orgcust));
AR016      endif;

          clear rteSequence;
            yajl_beginArray('segments');
            exsr findRouteSegments;
              if foundSegment = *off;
                clear checkname;
                clear checkadr;
                clear checkcty;
                clear checkst;
                checkname = orgcust;

                checkadr  = orgaddr;
                checkcty  = orgcty;
                checkst   = orgst;
                exsr getcust#;
                //if no segments found in the route file use stop location
                chain cust#  mccstllp;
                if %found(mccstllp) And
                     (c#declatd > *zero and c#declond < *zero);
                  yajl_beginObj();
                    rteSequence += 1;
                    yajl_addNum('latitude':%char(C#DECLATD));
                    yajl_addNum('longitude':%char(C#DECLOND));
                    yajl_addChar('sequence':%char(rteSequence));
                  yajl_endObj();
                else;
                  chain (orgst:orgcty) citiesl3;
                  if %found(citiesl3);
                    yajl_beginObj();
                      rteSequence += 1;
                      orgLat = (CiLat/3600);
                      orgLon = (CiLong/3600);
                      yajl_addNum('latitude':%char(orgLat));
                      yajl_addNum('longitude':'-' + %char(orgLon));
                      yajl_addChar('sequence':%char(rteSequence));
                    yajl_endObj();
                  endif;
                endif;
              endif;
            yajl_endArray();
         yajl_endObj();
        endsr;

        //-----------------------------------------------------
        //--add location route segments   ------------
        //-----------------------------------------------------
        begsr locationsRoute;

          yajl_beginObj();

AR016       if foundFuel;
  |           yajl_addChar('external_id':%trim(JobID) +
  |                        '-'+ %trim(fuelName(fuelSequence)));
  |           savCust = stpCust;
  |         else;
  |           yajl_addChar('external_id':%trim(JobID) +
  |                        '-'+ %trim(stpcust));
AR016       endif;

            yajl_beginArray('segments');
            exsr findRouteSegments;
            if foundSegment = *off;
                clear checkname;
                clear checkadr;
                clear checkcty;
                clear checkst;
                checkname = stpcust;
                checkadr  = stpaddr;
                checkcty  = stpcty;
                checkst   = stpst;
                exsr getcust#;
                //if no segments found in the route file use stop location
                  chain cust#  mccstllp;
                  if %found(mccstllp) = *on;
                      yajl_beginObj();
                        rteSequence += 1;
                        yajl_addNum('latitude':%char(C#DECLATD));
                        yajl_addNum('longitude':%char(C#DECLOND));
                        yajl_addChar('sequence':%char(rteSequence));
                      yajl_endObj();
                  endif;
              endif;
            yajl_endArray();
          yajl_endObj();
        endsr;

        //-----------------------------------------------------
        //--add location route segments   ------------
        //-----------------------------------------------------
        begsr locationsRouteD;

          yajl_beginObj();

AR016       if foundFuel;
  |           yajl_addChar('external_id':%trim(JobID) +
  |                        '-'+ %trim(fuelName(fuelSequence)));
  |           savCust = dstCust;
  |         else;
  |           yajl_addChar('external_id':%trim(JobID) +
  |                        '-'+ %trim(dstcust));
AR016       endif;

            yajl_beginArray('segments');

            exsr findRouteSegments;
            if foundSegment = *off;
                clear checkname;
                clear checkadr;
                clear checkcty;
                clear checkst;
                checkname = dstcust;
                checkadr  = dstaddr;
                checkcty  = dstcty;
                checkst   = dstst;

                exsr getcust#;
                //if no segments found in the route file use stop location
                  chain cust#  mccstllp;
                  if %found(mccstllp) = *on;
                    yajl_beginObj();
                      rteSequence += 1;
                      yajl_addNum('latitude':%char(C#DECLATD));
                      yajl_addNum('longitude':%char(C#DECLOND));
                      yajl_addChar('sequence':%char(rteSequence));
                    yajl_endObj();
                  endif;
              endif;
            yajl_endArray();
          yajl_endObj();
        endsr;

        //-----------------------------------------------------
        //--add location fuel/via segments  ----------
        //-----------------------------------------------------
AR023   begsr locationsRouteF;
  |
  |       yajl_beginObj();
  |         yajl_addChar('external_id':%trim(JobID)
  |                       +'-'+ %trim(name));
  |         yajl_beginArray('segments');
  |           yajl_beginObj();
  |             rteSequence += 1;
  |             latitude#  = lat * .0001;
  |             longitude# = lon * .0001;
  |             yajl_addNum('latitude':%char(latitude#));
  |             yajl_addNum('longitude':'-' + %char(longitude#));
  |             yajl_addChar('sequence':%char(rteSequence));
  |           yajl_endObj();
  |         yajl_endArray();
  |       yajl_endObj();
AR023   endsr;

AR010   //-----------------------------------------------------
  |     //--add fuel locations  ------------
  |     //-----------------------------------------------------
  |     begsr locationFuel;
  |
  |       addr= %XLATE(lo:up:addr);
  |       city= %XLATE(lo:up:city);
  |
  |       yajl_beginObj();
  |         yajl_addNum('id':%char(seq));
  |       //yajl_addChar('external_id':%trim(JobID)
  |       //              +'-'+ %trim(provider) +'/'+ name);
  |         yajl_addChar('external_id':%trim(JobID)
  |                       +'-'+ %trim(name));
  |         yajl_addChar('type':'job');
  |       //yajl_addChar('name':%trim(provider) +'/'+ name);
  |         yajl_addChar('name':%trim(name));
  |
  |         fuelSequence += 1;
  |         if addr = *blanks;
  |           addr = 'NO ADDRESS PROVIDED';
  |         endif;
  |
  |         clear country;
  |         if state > *blanks;
  |           chain state ftstate;
  |           if %found(ftstate);
  |             select;
  |             when fscnty = 'CAN';
  |               country = 'CN';
  |             when fscnty = 'MEX';
  |               country = 'MX';
  |             when fscnty = 'USA';
  |               country = 'US';
  |             endsl;
  |           endif;
  |         endif;
  |
  |         yajl_addChar('address':%trim(addr));
  |         yajl_addChar('city':%trim(city));
  |         yajl_addChar('state':%trim(state));
  |         yajl_addChar('postal_code':%trim(zip));
  |         yajl_addChar('country_code':%trim(country));
  |         yajl_addChar('time_zone':'');
  |
  |         latitude#  = lat * .0001;
  |         longitude# = lon * .0001;
  |         yajl_addNum('latitude':%char(latitude#));
  |         yajl_addNum('longitude':'-' + %char(longitude#));
  |         fuelLatd(fuelSequence) = latitude#;
  |         fuelLong(fuelSequence) = longitude#;
  |       //fuelName(fuelSequence) = %trim(provider) +'/'+ name;
  |         fuelName(fuelSequence) = %trim(provider);
  |         fuelSequence += 1;
  |
  |         //exsr hours;
  |         TS = %timestamp();
  |         timestampChar = %char(%timestamp(TS):*ISO);
  |         exsr timeSr;
  |         exsr externalCrtUpd;
  |       yajl_endObj();
AR010   endsr;

        //-----------------------------------------------------
        //--find route from Expert Fuel  ------------
        //-----------------------------------------------------
        begsr findRouteId;

          navon  = *off;
          ef2truck = mhunit;
DR010     //if navOnDrv = *on;
CR024     if navOnDrv = *on Or fuelOnDrv;
AR027     chain (smhunit:smhdate:smhtime:'O') mcmsgh;
CR024     if %found(mcmsgh);
            setgt ef2truck ef2reql2;
            //must be made after current dispatch time
AR027       dou %eof(ef2reql2) Or (rteChkOrd# = reqload
AR027          And %char(reqdate) >= mh_wtims);
              readpe ef2truck ef2reql2;
AR027         if %char(reqdate) < mh_wtims;
AR027           leave;
AR027         endif;
AR027       enddo;
AR027       if not %eof(ef2reql2) And (rteChkOrd# = reqload
AR027          And %char(reqdate) >= mh_wtims);
              if navOnDrv = *on;
                navOn = *on;
AR023           requestId = reqId#;
              endif;
AR024         if fuelOnDrv = *on;
  |             requestId = reqId#;
  |           endif;
  |         else;
AR024         fuelOnDrv = *off;
            endif;
          endif;
          endif;
        endsr;

        //-----------------------------------------------------
        //--find route segments Expert Fuel  ------------
        //-----------------------------------------------------
        begsr findRouteSegments;

           foundSegment = *off;
DR016      //rteSequence = 0;
AR023      //process long route for all job points.
AR023      if routePoints = *on;

           setll (requestId:rteStop) ef2rtepPS;
           reade (requestId:rteStop) ef2rtepPS;
           dow %eof(ef2rtepPS) = *off;
DR016      //rteSequence = rteSequence + 1;
DR016      //foundSegment = *on;
             skipSeg = *off;

RD008        //retocc = %scan('*':RTEHWY);
  |          //if retocc = 1;
  |          //skipSeg = *on;
RD008        //endif;

RD008        //retocc = %scan('Exit':RTEINTCHG);
  |          //if retocc = 1;
  |          //skipSeg = *on;
RD008        //endif;

RD008        //if rtemiles < 1;
  |          //skipSeg = *on;
RD008        //endif;

RD008        //if skipSeg= *off;
RA016          rteSequence += 1;
RA016          foundSegment = *on;
               yajl_beginObj();
  |              latitude#  = rtebeglat * .0001;
  |              longitude# = rtebeglon * .0001;
                 yajl_addNum('latitude':%char(latitude#));
  |              yajl_addNum('longitude':'-' + %char(longitude#));
                 yajl_addChar('sequence':%char(rteSequence));
               yajl_endObj();

RA016        if rteFuelnow = 'Y' And foundFuel;
  |            latitude# = fuelLatd(fuelSequence);
  |            longitude# = fuelLong(fuelSequence);
  |            if latitude# > *zero and longitude# > *zero;
  |              rteSequence += 1;
  |              yajl_beginObj();
  |                yajl_addNum('latitude':%char(latitude#));
  |                yajl_addNum('longitude':'-' + %char(longitude#));
  |                yajl_addChar('sequence':%char(rteSequence));
  |                fuelSequence += 1;
  |              yajl_endObj();
  |              yajl_endArray();
  |              yajl_endObj();
  |                yajl_beginObj();
  |                  yajl_addChar('external_id':%trim(JobID) +
  |                             '-'+ %trim(savCust));
  |                    yajl_beginArray('segments');
  |                foundFuel = *off;
  |            endif;
RA016        endif;

RA016          rteSequence += 1;
               yajl_beginObj();
  |              latitude#  = rteendlat * .0001;
  |              longitude# = rteendlon * .0001;
                 yajl_addNum('latitude':%char(latitude#));
  |              yajl_addNum('longitude':'-' + %char(longitude#));
                 yajl_addChar('sequence':%char(rteSequence));
               yajl_endObj();
RD010        //endif;
           reade (requestId:rteStop) ef2rtepPS;
          enddo;
AR023     endif;
        endsr;

        //-----------------------------------------------------
        //--add location stops deliveries ------------
        //-----------------------------------------------------
        begsr locationstopD;
AR010
  |       clear dstZip;
  |       clear dstLat;
  |       clear dstLon;
  |       //if Load Route exists, use route stop sequence.
  |       dstla = seq;
  |       if routeOnDrv;
  |         dstZip = zip;
  |         dstLat = lat;
  |         dstLon = lon;
  |         sostp# = stp;
  |       endif;
AR022
  |         retocc = %scan(',':dstctyst);
  |         if retocc > 0;
  |           dstcty = %subst(dstctyst:1:retocc-1);
  |           dstst  = %subst(dstctyst:retocc+1:2);
  |         else;
  |           retocc = %scan('  ':dstctyst);
  |           if retocc > 0;
  |             dstcty = %subst(dstctyst:1:retocc-4);
  |             dstst  = %subst(dstctyst:retocc-2:2);
AR022         endif;
AR022       endif;
  |
  |         clear country;
  |         if dstst > *blanks;
  |           chain dstst ftstate;
  |           if %found(ftstate);
  |             select;
  |             when fsCnty = 'CAN';
  |               country = 'CN';
  |             when fsCnty = 'MEX';
  |               country = 'MX';
  |             when fsCnty = 'USA';
  |               country = 'US';
  |             endsl;
  |           endif;
  |         endif;
  |
          yajl_beginObj();
AR014       if dstla < 90;
              yajl_addNum('id':%char(dstla));
AR014       else;
AR014         yajl_addNum('id':%char(dstla));
AR014       endif;
            yajl_addChar('external_id':%trim(JobID) +
                         '-'+ %trim(dstcust));
            yajl_addChar('type':'job');
            yajl_addChar('name':%trim(dstcust));
            yajl_addChar('address':%trim(dstaddr));
            yajl_addChar('city':%trim(dstcty));
            yajl_addChar('state':%trim(dstst));
            yajl_addChar('postal_code':%trim(dstzip));
            yajl_addChar('country_code':%trim(country));
            yajl_addChar('time_zone':'');

            if dstLat = *zeros and dstLon = *zeros;
            clear checkname;
            clear checkadr;
            clear checkcty;
            clear checkst;
            checkname = dstcust;
            checkadr  = dstaddr;
            checkcty  = dstcty;
            checkst   = dstst;
            exsr getcust#;

            chain cust#  mccstllp;
            if %found(mccstllp) = *on And
                     (c#declatd > *zero and c#declond < *zero);
              yajl_addNum('latitude':%char(C#DECLATD));
              yajl_addNum('longitude':%char(C#DECLOND));
            else;
              chain (dstst:dstcty) citiesl3;
              if %found(citiesl3);
                dstLat = (CiLat/3600);
                dstLon = (CiLong/3600);
                yajl_addNum('latitude':%char(dstLat));
                yajl_addNum('longitude':'-' + %char(dstLon));
              endif;
            endif;
  |
  |         else;
  |           latitude#  = dstLat * .0001;
  |           longitude# = dstLon * .0001;
  |           yajl_addNum('latitude':%char(latitude#));
  |           yajl_addNum('longitude':'-' + %char(longitude#));
  |         endif;

            //exsr hours;
            exsr externalcrtupd;
          yajl_endObj();
        endsr;

        //-----------------------------------------------------
        //--write load origin location  --------------
        //-----------------------------------------------------
AR010   begsr locationStopO;
  |
  |       clear orgZip;
  |       clear orgLat;
  |       clear orgLon;
  |       //if Load Route exists, use route stop sequence.
  |       orgla = seq;
  |       if routeOnDrv;
  |         orgZip = zip;
  |         orgLat = lat;
  |         orgLon = lon;
  |         sostp# = stp;
  |       endif;
  |
AR010     yajl_beginObj();
  |         yajl_addNum('id':%char(orgla));
  |         yajl_addChar('external_id':%trim(JobID) +
  |                      '-'+ %trim(orgcust));
  |         yajl_addChar('type':'job');
  |         yajl_addChar('name':%trim(orgcust));
  |
  |         if orgaddr = *blanks;
  |           orgaddr = 'NO ADDRESS PROVIDED';
  |         endif;
AR022
  |         if orgctyst > *blanks;
  |         retocc = %scan(',':orgctyst);
  |         if retocc > 0;
  |           orgcty = %subst(orgctyst:1:retocc-1);
  |           orgst  = %subst(orgctyst:retocc+1:2);
  |         else;
  |           retocc = %scan('  ':orgctyst);
  |           if retocc > 0;
  |             orgcty = %subst(orgctyst:1:retocc-4);
  |             orgst  = %subst(orgctyst:retocc-2:2);
AR022         endif;
AR022       endif;
AR022       endif;
  |
  |         clear country;
  |         if orgst > *blanks;
  |           chain orgst ftstate;
  |           if %found(ftstate);
  |             select;
  |             when fsCnty = 'CAN';
  |               country = 'CN';
  |             when fsCnty = 'MEX';
  |               country = 'MX';
  |             when fsCnty = 'USA';
  |               country = 'US';
  |             endsl;
  |           endif;
  |         endif;
  |
  |         yajl_addChar('address':%trim(orgaddr));
  |         yajl_addChar('city':%trim(orgcty));
  |         yajl_addChar('state':%trim(orgst));
  |         yajl_addChar('postal_code':%trim(orgzip));
  |         yajl_addChar('country_code':%trim(country));
  |         yajl_addChar('time_zone':'');
  |
  |         if orgLat = *zeros and orgLon = *zeros;
  |         clear checkname;
  |         clear checkadr;
  |         clear checkcty;
  |         clear checkst;
  |         checkname = orgcust;
  |         checkadr  = orgaddr;
  |         checkcty  = orgcty;
  |         checkst   = orgst;
  |
  |         exsr getCust#;
  |         chain cust#  mccstllp;
  |         if %found(mccstllp) = *on And
  |                  (c#declatd > *zero and c#declond < *zero);
  |           yajl_addNum('latitude':%char(C#DECLATD));
  |           yajl_addNum('longitude':%char(C#DECLOND));
  |         else;
              chain (orgst:orgcty) citiesl3;
              if %found(citiesl3);
                orgLat = (CiLat/3600);
                orgLon = (CiLong/3600);
  |             yajl_addNum('latitude':%char(orgLat));
                yajl_addNum('longitude':'-' + %char(orgLon));
              endif;
  |         endif;
  |
  |         else;
  |           latitude#  = orgLat * .0001;
  |           longitude# = orgLon * .0001;
  |           yajl_addNum('latitude':%char(latitude#));
  |           yajl_addNum('longitude':'-' + %char(longitude#));
  |         endif;
  |
  |         //exsr hours;
  |         TS = %timestamp();
  |         timestampChar = %char(%timestamp(TS):*ISO);
  |         exsr timeSr;
  |         exsr externalCrtUpd;
  |       yajl_endObj();
AR010   endsr;

        //-----------------------------------------------------
        //--add location stops pickups ------------
        //-----------------------------------------------------
        begsr locationstop;
AR010
  |       clear stpZip;
  |       clear stpLat;
  |       clear stpLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         stpla = seq;
  |         stpZip = zip;
  |         stpLat = lat;
  |         stpLon = lon;
  |         sostp# = stp;
  |       else;
  |         stpla = seq +1;
  |       endif;
AR010
AR002       retocc = %scan(',':stpctyst);
  |         if retocc > 0;
  |           stpcty = %subst(stpctyst:1:retocc-1);
  |           stpst  = %subst(stpctyst:retocc+2:2);
  |         else;
  |           retocc = %scan('  ':stpctyst);
  |           if retocc > 0;
  |             stpcty = %subst(stpctyst:1:retocc-4);
  |             stpst  = %subst(stpctyst:retocc-2:2);
AR022         endif;
AR022       endif;
  |
  |         clear country;
  |         if stpst > *blanks;
  |           chain stpst ftstate;
  |           if %found(ftstate);
  |             select;
  |             when fsCnty = 'CAN';
  |               country = 'CN';
  |             when fsCnty = 'MEX';
  |               country = 'MX';
  |             when fsCnty = 'USA';
  |               country = 'US';
  |             endsl;
  |           endif;
  |         endif;

          yajl_beginObj();
            yajl_addNum('id':%char(stpla));
            yajl_addChar('external_id':%trim(JobID) +
                         '-'+ %trim(stpcust));
            yajl_addChar('type':'job');
            yajl_addChar('name':%trim(stpcust));
            yajl_addChar('address':%trim(stpaddr));
            yajl_addChar('city':%trim(stpcty));
            yajl_addChar('state':%trim(stpst));
            yajl_addChar('postal_code':%trim(stpZip));
            yajl_addChar('country_code':%trim(country));
            yajl_addChar('time_zone':'');

            if stpLat = *zeros and stpLon = *zeros;
            clear checkname;
            clear checkadr;
            clear checkcty;
            clear checkst;
            checkname = stpcust;
            checkadr  = stpaddr;
            checkcty  = stpcty;
            checkst   = stpst;
            exsr getcust#;

            chain cust#  mccstllp;
            if %found(mccstllp) = *on And
  |                  (c#declatd > *zero and c#declond < *zero);
              yajl_addNum('latitude':%char(C#DECLATD));
              yajl_addNum('longitude':%char(C#DECLOND));
            else;
              chain (stpst:stpcty) citiesl3;
              if %found(citiesl3);
                stpLat = (CiLat/3600);
                stpLon = (CiLong/3600);
                yajl_addNum('latitude':%char(stpLat));
                yajl_addNum('longitude':'-' + %char(stpLon));
              endif;
            endif;

            else;
              latitude#  = stpLat * .0001;
              longitude# = stpLon * .0001;
              yajl_addNum('latitude':%char(latitude#));
              yajl_addNum('longitude':'-' + %char(longitude#));
            endif;

            //exsr hours;
            exsr externalcrtupd;
          yajl_endObj();
        endsr;

         //-----------------------------------------------------
         //--load header information to display to driver----
         //-----------------------------------------------------
         begsr loadheaderinfo;

          yajl_beginArray('customers');
          yajl_endArray();

          yajl_beginArray('external_data');

            yajl_beginObj();
              yajl_addChar('label':'TRAILERS');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Trailer');
              yajl_addChar('value':%trim(ditrlr));
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Shipping Documents');
              yajl_addChar('value':'');
              yajl_addNum('order':'30');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Bill Of Lading');
              if orcsh# <> *blanks;
                yajl_addChar('value':%trim(orcsh#));
              else;
                yajl_addChar('value':'NA');
              endif;
              yajl_addNum('order':'40');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Seal #');
              if orsel1 <> *blanks;
                yajl_addChar('value':%trim(orsel1));
              else;
                yajl_addChar('value':'NA');
              endif;
              yajl_addNum('order':'50');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Load Details');
              yajl_addChar('value':'');
              yajl_addNum('order':'100');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Live Load/PreLoad');
              if ordld = 'Y';
                yajl_addChar('value':'Live Load');
              else;
                yajl_addChar('value':'No');
              endif;
              yajl_addNum('order':'110');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Live UnLoad/Drop');
              if orduld = 'Y';
                yajl_addChar('value':'Live Unload');
              else;
                yajl_addChar('value':'Drop');
              endif;
              yajl_addNum('order':'120');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

          yajl_EndArray();
        endsr;

        //-----------------------------------------------------
        //--hours add open to close hours if they exist -------
        //-----------------------------------------------------
        begsr hours;

          yajl_beginArray('open_hours');
            yajl_beginObj();
              yajl_addChar('day_of_week':'Monday-Sunday');
              yajl_addChar('opens_at':'12:05');
              yajl_addChar('closes_at':'23:59');
            yajl_endObj();
           yajl_endArray();
        endsr;

        //-----------------------------------------------------
        //
        //-----------------------------------------------------
        begsr Steps;

AR010     //process existing Load Route.
  |       if routeOnDrv;
  |         setll unord# rteStopl1;
  |         //check for EF fuel & route
  |         setll (requestID:unord#:undisp) ef2Route;
  |         if %equal(ef2Route);
  |           yajl_beginArray('steps');
  |             x = 1;
AR022           r# = 1;
  |             dou %eof(ef2Route);
  |               reade (requestId:unord#:undisp) ef2Route;
  |               //only process stop and fuel locations
  |               if not %eof(ef2Route);
  |                 //process pickup & drop stopoffs
  |                 if stoptype = 'S';
AR026                 dow rtleg(r#) <> cicty + cist;
  |                     r# +=1;
  |                     if rtseq(r#) = 00 And rtleg(r#) = *blanks;
  |                       leave;
  |                     endif;
AR026                 enddo;
  |                   stp = rtSeq(r#);
  |                   select;
  |                   //write corresponding location
  |                   when stp = 01 Or (stp = 00 and r# = 1);
  |                     seq = 01;
  |                     exsr addOrigin;
  |                   when stp > 01 and stp < 90;
  |                     if messageA41(x) > *blanks And soType = 'P';
  |                       exsr loadPick;
  |                       exsr addStop;
  |                     elseif messageA41(x) > *blanks And soType = 'D';
  |                       exsr loadDelv;
  |                       exsr addStop;
  |                     endif;
  |                   when stp = 90;
  |                     seq = 90;
  |                     exsr addStopD;
  |                   endsl;
  |                   r# +=1;
  |                 //write fuel stop locations
  |                 elseif stoptype = 'F';
  |                   stp = 00;
  |                   exsr addFuelStop;
  |                 endif;
  |               endif;
  |             enddo;
  |           yajl_endArray();
  |         endif;
  |       endif;
  |
  |       //if Driver Fuel Stops disabled,
  |       //  Or either EF Fuel Route or Load Route is missing.
  |       if not(fuelOnDrv) Or not(routeOnDrv)
AR010        Or (routeOnDrv and not %equal(ef2Route));

            yajl_beginArray('steps');
              seq = 01;
              exsr addOrigin;
              x = 1;
              dow messageA41(x) <> *blanks And x<=989;
                if %subst(messageA41(x+2):16:1) = 'P';
                  exsr loadPick;
                  exsr addStop;
                elseif %subst(messageA41(x+2):16:1) = 'D';
                  exsr loadDelv;
                  exsr addStop;
                else;
                  x +=11;
                endif;
              enddo;
              seq = 90;
              exsr addStopD;
            yajl_endArray();
AR010     endif;
        endsr;

        //-----------------------------------------------
        //      findorigin;
        //-----------------------------------------------
AR005   begsr findStopoff;

AR009     //if missing Load Route or no corresponding stop record.
  |       if not(routeOnDrv) Or %eof(rteStopl1);
  |         if %eof(rteStopl1) Or not(firstRouteOnDrv);
  |           setll unord# rteStopl1;
  |           firstRouteOnDrv = *on;
AR009       endif;

AR005       dou %eof(rteStopl1);
  |           reade unord# rteStopl1;
  |           if not %eof(rteStopl1) and sostp# > *zero
AR014            and socust = cust# and sotype = checktype;
  |             leave;
  |           endif;
AR005       enddo;

AR005       if %eof(rteStopl1);
  |           clear soeda;
AR005         clear soeta;
              clear sostp#;
DR014         //sostp# = checkla;
AR014         if checkla < 90;
  |             sostp# = checkla+1;
  |           else;
  |             sostp# = checkla;
AR014         endif;
AR005       endif;
AR009     endif;
        endsr;

        //-----------------------------------------------
        //
        //-----------------------------------------------
        begsr addgeofence;

          yajl_beginObj('geofence');
            yajl_beginObj('circle');
              yajl_beginObj('center');

                if geoLat = *zeros and geoLon = *zeros;
                chain cust#  mccstllp;
                if %found(mccstllp) = *on;
                  yajl_addNum('latitude':%char(C#DECLATD));

                  if c#declond < 0;
                    c#declond =  c#declond * -1;
                  endif;
                  yajl_addNum('longitude':'-' + %char(C#DECLOND));
                endif;

                else;
  |               latitude#  = geoLat * .0001;
  |               longitude# = geoLon * .0001;
  |               yajl_addNum('latitude':%char(latitude#));
  |               yajl_addNum('longitude':'-' + %char(longitude#));
                endif;
              yajl_endObj();

              yajl_addNum('radius':'250');
            yajl_endObj();

            yajl_addNum('delay':'300');

            if autocomplete= *on;
              yajl_addBool('auto_complete':'1');
            else;
              yajl_addBool('auto_complete':'0');
            endif;

            if geoarrive = *on;
              yajl_addChar('trigger_by':'entry');
              yajl_addChar('message':'You have Arrived!');
            else;
              yajl_addChar('trigger_by':'exit');
              yajl_addChar('message':'You have Departed!');
            endif;
          yajl_endObj();
        endsr;

AR010   //-----------------------------------------------
  |     //
  |     //-----------------------------------------------
  |     begsr addFuelGeofence;
  |
  |       yajl_beginObj('geofence');
  |         yajl_beginObj('circle');
  |           yajl_beginObj('center');
  |             latitude#  = lat * .0001;
  |             longitude# = lon * .0001;
  |             yajl_addNum('latitude':%char(latitude#));
  |             yajl_addNum('longitude':'-' + %char(longitude#));
  |           yajl_endObj();
TEMP        //yajl_addNum('radius':'250');
TEMP          yajl_addNum('radius':'500');
  |         yajl_endObj();
  |         yajl_addNum('delay':'300');
  |         if autocomplete= *on;
  |           yajl_addBool('auto_complete':'1');
  |         else;
  |           yajl_addBool('auto_complete':'0');
  |         endif;
  |         if geoarrive = *on;
  |           yajl_addChar('trigger_by':'entry');
  |           yajl_addChar('message':'You have Arrived!');
  |         else;
  |           yajl_addChar('trigger_by':'exit');
  |            yajl_addChar('message':'You have Departed!');
  |          endif;
  |       yajl_endObj();
AR010   endsr;

        //-----------------------------------------------
        //      addorigin;
        //-----------------------------------------------
        begsr addorigin;
AR010
  |       clear orgZip;
  |       clear orgLat;
  |       clear orgLon;
  |       //if Load Route exists, use route stop sequence.
  |       orgla = seq;
  |       if routeOnDrv;
  |         orgZip = zip;
  |         orgLat = lat;
  |         orgLon = lon;
  |         sostp# = stp;
  |       endif;
AR010
          yajl_beginObj();
            yajl_addChar('id':%char(orgla));
            yajl_addChar('external_id':%trim(JobId) +
                         '-'+ %char(orgla));
            yajl_addChar('name':%trim(orgcust));
            yajl_addBool('completed':'0');
            yajl_addChar('completed_at':'');
            yajl_addChar('type':%trim(orgtype));
            yajl_addNum('order':%char(orgla));
            yajl_addChar('location_external_id':%trim(JobId) +
                         '-'+ %trim(orgcust));
            yajl_addChar('customer_external_id':%trim(JobId) +
                         '-'+ %trim(orgcust));
            if NavOn = *on;
              yajl_addChar('route_leg_external_id':%trim(JobID) +
                           '-'+ %trim(orgcust));
            endif;

            yajl_beginObj('appointment');
              clear checkname;
              clear checkadr;
              clear checkcty;
              clear checkst;
AR009         clear checkla;
AR014         clear checktype;
              checkname = orgcust;
              checkadr  = orgaddr;
              checkcty  = orgcty;
              checkst   = orgst;
AR009         checkla   = orgla;
              exsr getcust#;
AR014         checktype = 'P';
AR005         exsr findStopoff;

              if orgpudt <> *blanks;
                if orgpudm < curmonth;
                  curyear = curyear +1;
                endif;
                ccyy = %char(curyear);
                mm   = %editc(orgpudm:'X');
                dd   = %editc(orgpudd:'X');
                hh   = %editc(orgpuh:'X');
                min  = %editc(orgpum:'X');
                UTCEndHH = custTZ;
                sec = '00';
                timestampChar = timeUTC;
                     exsr timeSrNoUTC1;
                UTCEndHH = offset;
              else;
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                     exsr timeSrNoUTC;
              endif;
              yajl_addChar('start_time':UTCFormat);
              yajl_addChar('ready_time':UTCFormat);

             if orgpudt1<> *blanks;
                if orgpudm1< curmonth;
                  curyear = curyear +1;
                endif;
                ccyy = %char(curyear);
                mm   = %editc(orgpudm1:'X');
                dd   = %editc(orgpudd1:'X');
                hh   = %editc(orgpuh1:'X');
                min  = %editc(orgpum1:'X');
                UTCEndHH = custTZ;
                sec = '00';
                timestampChar = timeUTC;
                      exsr timeSrNoUTC1;
                UTCEndHH = offset;
              else;
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
              endif;
              yajl_addChar('end_time':UTCFormat);
              yajl_addChar('late_time':'');
            yajl_endObj();

AR011           if soeda > *zero And soeta > *zero;
                  dateconv = soeda;
                  timeconv = soeta;
                  exsr Convert_Dt;
                  exsr timeSr;
                  yajl_addChar('eta':UTCFormat);
AR011           endif;

            TS = %timestamp();
            timestampChar = %char(%timestamp(TS):*ISO);
            exsr timeSr;
            yajl_addChar('created_at':UTCFormat);
            yajl_addChar('updated_at':UTCFormat);

            exsr externalorigin;     // load details

            yajl_beginArray('tasks');
              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobId) +
                             '-'+ %char(orderby));
                yajl_addChar('name':'Arrival At Origin');
                yajl_addChar('type':'arrivedShipper');
                yajl_addChar('order':%char(orderby));
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  geoarrive = *on;
                  autocomplete = *on;
                  geoLat = orgLat;
                  geoLon = orgLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobId) +
                             '-'+ %char(orderBy));
                yajl_addChar('name':'Loaded Call');
                yajl_addChar('order':%char(orderBy));
                yajl_addChar('type':'loadedCall');
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  //geoarrive = *off;
                  //autocomplete = *on;
                  //exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              if flagDepart = *on;
              //new depart task
              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobId) +
                             '-'+ %char(orderBy));
                yajl_addChar('name':'Loaded Call Departure');
                yajl_addChar('order':%char(orderBy));
                yajl_addChar('type':'loadedCallDeparture');
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  geoarrive = *off;
A001              autocomplete = *off;
C001              //autocomplete = *on;
                  geoLat = orgLat;
                  geoLon = orgLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();
              endif;

            yajl_endArray();
          yajl_endObj();
        endsr;

        //-----------------------------------------------
        //--use stop customer code to match name on stop
        //-----------------------------------------------
        begsr getcust#;

          clear cust#;
          chain (checkname:checkadr:checkcty:checkst) custpp;
          if %found(custmaspp) = *on;
            cust# = cucode;
            chain (cubst:cubctc) cities;
            if %found(cities);
              select;
              when citime = '01';
                custTZ = '11';
              when citime = '02';
                custTZ = '10';
              when citime = '03';
                custTZ = '09';
              when citime = '04';
                custTZ = '08';
              when citime = '05';
                custTZ = '07';
              when citime = '06';
                custTZ = '06';
              when citime = '07';
                custTZ = '05';
              when citime = '08';
                custTZ = '04';
              when citime = '09';
                custTZ = '03';
              other;
AR005           //default to NASHTN offset on mismatch
AR005           custTZ = '05';
              endsl;
AR005       else;
AR005        //default to NASHTN offset on error.
AR005        custTZ = '05';
            endif;
          endif;

          if cust# = *blanks;
            //need to get t-call location
            cust# = 'WENA  ';
AR005       custTZ = '05';
          endif;
        endsr;

        //-----------------------------------------------
        //      addStop;
        //-----------------------------------------------
        begsr addStop;
AR010
  |       clear stpZip;
  |       clear stpLat;
  |       clear stpLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         stpla = seq;
  |         stpZip = zip;
  |         stpLat = lat;
  |         stpLon = lon;
  |         sostp# = stp;
  |       else;
  |         stpla = seq +1;
  |       endif;
AR010
          yajl_beginObj();
            yajl_addNum('id':%char(stpla));
            yajl_addChar('external_id':%trim(JobId) +
                         '-'+ %char(stpla));
            yajl_addChar('name':%trim(stpcust));
            yajl_addBool('completed':'0');
            yajl_addChar('completed_at':'');
            if stpType = 'P';
              yajl_addChar('type':'PICK UP');
            elseif stpType = 'D';
              yajl_addChar('type':'DROPOFF');
            endif;
            yajl_addNum('order':%char(stpla));
            yajl_addChar('location_external_id':%trim(JobId) +
                         '-'+ %trim(stpcust));
            yajl_addChar('customer_external_id':%trim(JobId) +
                         '-'+ %trim(stpcust));
            if NavOn = *on;
              yajl_addChar('route_leg_external_id':%trim(JobID) +
                           '-'+ %trim(stpcust));
            endif;

            yajl_beginObj('appointment');
              clear checkname;
              clear checkadr;
              clear checkcty;
              clear checkst;
AR009         clear checkla;
AR014         clear checktype;
              checkname = stpcust;
              checkadr  = stpaddr;
              checkcty  = stpcty;
              checkst   = stpst;
AR009         checkla   = stpla;
              exsr getcust#;
  |           checktype = stpType;
AR005         exsr findStopoff;

              if stppudt <> *blanks;
                if stppudm < curmonth;
                  curyear = curyear +1;
                endif;
                ccyy = %char(curyear);
                mm   = %editc(stppudm:'X');
                dd   = %editc(stppudd:'X');
                hh   = %editc(stppuh:'X');
                min  = %editc(stppum:'X');
                UTCEndHH = custTZ;
                sec = '00';
                timestampChar = timeUTC;
                exsr timeSrNoUTC1;
                UTCEndHH = offset;
              else;
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSrNoUTC;
              endif;
              yajl_addChar('start_time':UTCFormat);
              yajl_addChar('ready_time':UTCFormat);
              yajl_addChar('end_time':UTCFormat);
              yajl_addChar('late_time':'');
            yajl_endObj();

DR011       //if soeta <> *zeros;
AR011       if soeda > *zero And soeta > *zero;
              dateconv = soeda;
              timeconv = soeta;
              exsr Convert_Dt;
              exsr timeSr;
              yajl_addChar('eta':UTCFormat);
            endif;

            TS = %timestamp();
            timestampChar = %char(%timestamp(TS):*ISO);
            exsr timeSr;
            yajl_addChar('created_at':UTCFormat);
            yajl_addChar('updated_at':UTCFormat);

            exsr externalstop;  // load details tab

            yajl_beginArray('tasks');
              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addNum('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobID) +
                             '-'+ %char(orderBy));
                yajl_addChar('name':'Arrival At Stop');
                yajl_addChar('order':%char(orderBy));
                yajl_addChar('type':'arrivedStop');
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  geoarrive = *on ;
                  autocomplete = *on;
                  geoLat = stpLat;
                  geoLon = stpLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobId) +
                             '-'+ %char(orderBy));
                yajl_addChar('name':'Depart Stop');
                yajl_addChar('order':%char(orderBy));
                yajl_addChar('type':'departStop');
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  //geoarrive = *off;
                  //autocomplete = *on;
                  //exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              if flagDepart = *on;
              //new depart task
              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobId) +
                             '-'+ %char(orderBy));
                yajl_addChar('name':'Depart Stop Departure');
                yajl_addChar('order':%char(orderBy));
                yajl_addChar('type':'departStopDeparture');
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  geoarrive = *off;
D001              //autocomplete = *on;
A001              autocomplete = *off;
                  geoLat = stpLat;
                  geoLon = stpLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();
              endif;

            yajl_endArray();
          yajl_endObj();
        endsr;

        //-----------------------------------------------
        // add fuel stop location   ---------------------
        //-----------------------------------------------
AR010   begsr addFuelStop;
  |
  |       yajl_beginObj();
  |         yajl_addNum('id':%char(seq));
  |         yajl_addChar('external_id':%trim(JobId) +
  |                      '-'+ %char(seq));
  |         //yajl_addChar('name':%trim(provider) +'/'+ name);
  |         yajl_addChar('name':%trim(name));
  |         yajl_addBool('completed':'0');
  |         yajl_addChar('completed_at':'');
  |         yajl_addChar('type':'FUEL');
  |         yajl_addNum('order':%char(seq));
  |         yajl_addChar('location_external_id':%trim(JobId)
  |                       +'-'+ %trim(name));
  |         //yajl_addChar('customer_external_id':%trim(JobId)
  |         //              +'-'+ %trim(provider) +'/'+ name);
  |         yajl_addChar('customer_external_id':%trim(JobId)
  |                       +'-'+ %trim(name));
  |         if NavOn = *on;
  |         //yajl_addChar('route_leg_external_id':%trim(JobID)
  |         //          +'-'+ %trim(provider) +'/'+ name);
  |           yajl_addChar('route_leg_external_id':%trim(JobID)
  |                     +'-'+ %trim(name));
  |         endif;
  |
  |         TS = %timestamp();
  |         timestampChar = %char(%timestamp(TS):*ISO);
  |         exsr timeSr;
  |         yajl_addChar('created_at':UTCFormat);
  |         yajl_addChar('updated_at':UTCFormat);
  |
  |         yajl_beginArray('external_data');
  |           yajl_beginObj();
  |            //orderBy = orderBy + 1;
  |              yajl_addChar('label':'Fuel Stop Information');
  |              yajl_addChar('value':'');
  |              yajl_addNum('order':'150');
  |              yajl_addBool('isLabel':'1');
  |           yajl_EndObj();
  |
  |           citySt = %trim(city) + ',' + state;
  |           clear w_purGal;
  |           setgt (mhunit) mcmsgh;
  |           dou %eof(mcmsgh) Or mhpmid = '040'
  |                            Or mhpmid = '051';
  |             readpe (mhunit) mcmsgh;
  |           enddo;
  |             if not %eof(mcmsgh) And mhpmid = '051';
  |               setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |               dou %eof(mcmsgd) Or %subst(mdmsgs:1:18)=citySt;
  |                 reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |                 if not %eof(mcmsgd) And
  |                    %subst(mdmsgs:30:4)='QTY:';
  |                   w_purGal = %subst(mdmsgs:35:4);
  |                 endif;
  |               enddo;
  |               if w_purGal <> *blanks;
  |                 yajl_beginObj();
  |                 //orderBy = orderBy + 1;
  |                   yajl_addChar('label':'Purchase Gallons');
  |                   yajl_addChar('value':%char(w_purGal));
  |                   yajl_addNum('order':'160');
  |                   yajl_addBool('isLabel':'0');
  |                 yajl_EndObj();
  |               endif;
  |             endif;
  |         yajl_EndArray();
  |
  |         yajl_beginArray('tasks');
  |           yajl_beginObj();
  |             orderBy = orderBy + 1;
  |             yajl_addNum('id':%char(orderBy));
  |             yajl_addChar('external_id':%trim(JobID)
  |                           +'-'+ %char(orderBy));
TEMP            yajl_addChar('name':'Fuel Stop Gallons: '
TEMP                                + %char(w_purGal));
  |             yajl_addChar('order':%char(orderBy));
  |             yajl_addChar('type':'fuelStop');
  |             yajl_addBool('completed':'0');
  |             TS = %timestamp();
  |             timestampChar = %char(%timestamp(TS):*ISO);
  |             exsr timeSr;
  |             yajl_addChar('created_at':UTCFormat);
  |             yajl_addChar('updated_at':UTCFormat);
  |
  |             yajl_beginObj('external_data');
  |               yajl_addBool('is_prompt_repeats':'0');
  |               yajl_addBool('is_allow_repeats':'0');
  |               yajl_addBool('is_required':'0');
TEMP              //geoarrive = *on ;
TEMP              geoarrive = *off;
  |               autocomplete = *on;
  |               exsr addFuelGeofence;
  |             yajl_endObj();
  |
  |             yajl_beginObj('fields');
  |               sostp# = *zeros;
  |               exsr addInfo;
  |             yajl_endObj();
  |           yajl_endObj();
  |
  |         //yajl_beginObj();
  |         //  orderBy = orderBy + 1;
  |         //  yajl_addChar('id':%char(orderBy));
  |         //  yajl_addChar('external_id':%trim(JobId) +
  |         //               '-'+ %char(orderBy));
  |         //  yajl_addChar('name':'Depart Fuel Stop');
  |         //  yajl_addChar('order':%char(orderBy));
  |         //  yajl_addChar('type':'fuelStop');
  |         //  yajl_addBool('completed':'0');
  |         //  TS = %timestamp();
  |         //  timestampChar = %char(%timestamp(TS):*ISO);
  |         //  exsr timeSr;
  |         //  yajl_addChar('created_at':UTCFormat);
  |         //  yajl_addChar('updated_at':UTCFormat);
  |         //
  |         //  yajl_beginObj('external_data');
  |         //    yajl_addBool('is_prompt_repeats':'0');
  |         //    yajl_addBool('is_allow_repeats':'0');
  |         //    yajl_addBool('is_required':'0');
  |         //    geoarrive = *off;
  |         //    autocomplete = *on;
  |         //    exsr addFuelGeofence;
  |         //  yajl_endObj();
  |
  |         //  yajl_beginObj('fields');
  |         //    sostp# = *zeros;
  |         //    exsr addInfo;
  |         //  yajl_endObj();
  |         //yajl_endObj();
  |         yajl_endArray();
  |       yajl_endObj();
AR010   endsr;

        //-----------------------------------------------
        //gsr addStopD;
        //-----------------------------------------------
        begsr addStopD;
AR010
  |       clear dstZip;
  |       clear dstLat;
  |       clear dstLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         dstla = seq;
  |         dstZip = zip;
  |         dstLat = lat;
  |         dstLon = lon;
  |         sostp# = stp;
  |       endif;
AR010
          yajl_beginObj();
AR014       if dstla < 90;
              yajl_addNum('id':%char(dstla));
              yajl_addChar('external_id':%trim(JobId) +
                           '-'+ %char(dstla));
AR014       else;
AR014         yajl_addNum('id':%char(dstla));
AR014         yajl_addChar('external_id':%trim(JobId) +
AR014                      '-'+ %char(dstla));
AR014       endif;
            yajl_addChar('name':%trim(dstcust));
            yajl_addBool('completed':'0');
            yajl_addChar('completed_at':'');
            if dstla < 90;
              yajl_addChar('type':'DROPOFF');
            else;
              yajl_addChar('type':'FINAL DELIVERY');
            endif;
AR014       if dstla < 90;
              yajl_addNum('order':%char(dstla));
AR014       else;
AR014         yajl_addNum('order':%char(dstla));
AR014       endif;
            yajl_addChar('location_external_id':%trim(JobId) +
                         '-'+ %trim(dstcust));
            yajl_addChar('customer_external_id':%trim(JobId) +
                         '-'+ %trim(dstcust));
            if NavOn = *on;
              yajl_addChar('route_leg_external_id':%trim(JobID) +
                           '-'+ %trim(dstcust));
            endif;

            yajl_beginObj('appointment');
              clear checkname;
              clear checkadr;
              clear checkcty;
              clear checkst;
AR009         clear checkla;
AR014         clear checktype;
              checkname = dstcust;
              checkadr  = dstaddr;
              checkcty  = dstcty;
              checkst   = dstst;
AR009         checkla   = dstla;
              exsr getcust#;
AR014         checktype = 'D';
AR005         exsr findStopoff;

              if dstpudt <> *blanks;
                if dstpudm < curmonth;
                  curyear = curyear +1;
                endif;
                ccyy = %char(curyear);
                mm   = %editc(dstpudm:'X');
                dd   = %editc(dstpudd:'X');
                hh   = %editc(dstpuh:'X');
                min  = %editc(dstpum:'X');
                UTCEndHH = custTZ;
                sec = '00';
                timestampChar = timeUTC;
                exsr timeSrNoUTC1;
                UTCEndHH = offset;
              else;
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSrNoUTC;
              endif;
              yajl_addChar('start_time':UTCFormat);
              yajl_addChar('ready_time':UTCFormat);

              if dstpudt1<> *blanks;
                if dstpudm1< curmonth;
                  curyear = curyear +1;
                endif;
                ccyy = %char(curyear);
                mm   = %editc(dstpudm1:'X');
                dd   = %editc(dstpudd1:'X');
                hh   = %editc(dstpuh1:'X');
                min  = %editc(dstpum1:'X');
                UTCEndHH = custTZ;
                sec = '00';
                timestampChar = timeUTC;
                exsr timeSrNoUTC1;
                UTCEndHH = offset;
              else;
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
              endif;
              yajl_addChar('end_time':UTCFormat);
              yajl_addChar('late_time':'');
            yajl_endObj();

DR011       //if soeta <> *zeros;
AR011       if soeda > *zero And soeta > *zero;
              dateconv = soeda;
              timeconv = soeta;
              exsr Convert_Dt;
              exsr timeSr;
              yajl_addChar('eta':UTCFormat);
            endif;

            TS = %timestamp();
            timestampChar = %char(%timestamp(TS):*ISO);
            exsr timeSr;
            yajl_addChar('created_at':UTCFormat);
            yajl_addChar('updated_at':UTCFormat);

            exsr externalstopd;  // load details tab

            yajl_beginArray('tasks');
              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addNum('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobID) +
                             '-'+ %char(orderBy));
                yajl_addChar('order':%char(orderBy));
                if dstla = 90;
                  yajl_addChar('name':'Arrival At Final Destination');
                  yajl_addChar('type':'arrivedConsignee');
                else;
                  yajl_addChar('name':'Arrival At Stop');
                  yajl_addChar('type':'arrivedStop');
                endif;

                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  geoarrive = *on ;
                  autocomplete = *on;
                  geoLat = dstLat;
                  geoLon = dstLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(jobId) +
                             '-'+ %char(orderBy));
                yajl_addChar('order':%char(orderBy));
                if dstla = 90;
                  yajl_addChar('name':'Empty Call');
                  yajl_addChar('type':'emptyCall');
                else;
                  yajl_addChar('name':'Depart Stop');
                  yajl_addChar('type':'departStop');
                endif;
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  //geoarrive = *off;
                  //autocomplete = *on;
                  //exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              if flagDepart = *on;
              //new departure task
              yajl_beginObj();
                orderBy = orderBy + 1;
                yajl_addChar('id':%char(orderBy));
                yajl_addChar('external_id':%trim(JobId) +
                             '-'+ %char(orderBy));
                yajl_addChar('order':%char(orderBy));
                if dstla = 90;
                  yajl_addChar('name':'Empty Call Departure');
                  yajl_addChar('type':'emptyCallDeparture');
                else;
                  yajl_addChar('name':'Depart Stop Departure');
                  yajl_addChar('type':'departStopDeparture');
                endif;
                yajl_addBool('completed':'0');
                TS = %timestamp();
                timestampChar = %char(%timestamp(TS):*ISO);
                exsr timeSr;
                yajl_addChar('created_at':UTCFormat);
                yajl_addChar('updated_at':UTCFormat);

                yajl_beginObj('external_data');
                  yajl_addBool('is_prompt_repeats':'0');
                  yajl_addBool('is_allow_repeats':'0');
                  yajl_addBool('is_required':'1');
                  geoarrive = *off;
A001              autocomplete = *off;
C001              //autocomplete = *on;
                  geoLat = dstLat;
                  geoLon = dstLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();
              endif;

            yajl_endArray();
          yajl_endObj();
        endsr;

        //---------------------------------------------------------------------
        //egsr addinfo;
        //-----------------------------------------------
        begsr addinfo;

          yajl_addChar('Unit':%trim(ununit));
          yajl_addChar('Driver1':%trim(undr1));
          yajl_addChar('Driver2':%trim(undr2));
          yajl_addChar('StopOffId':%char(sostp#));
        endsr;

        //------------------------------------------------------------ --------
        //     externalorigin;
        //-----------------------------------------------
        begsr externalorigin;

          yajl_beginArray('external_data');
            yajl_beginObj();
              yajl_addChar('label':'Stop Information');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Appointment Type');
              yajl_addChar('value':'APPT');
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Load');
              yajl_addChar('value':%trim(orgdrvl));
              yajl_addNum('order':'50');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();
          yajl_EndArray();
        endsr;

        //---------------------------------------------------------------------
        //        externalstop;
        //---------------------------------------------------------------------
        begsr externalstop;

          yajl_beginArray('external_data');
            yajl_beginObj();
              yajl_addChar('label':'Stop Information');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Appointment Type');
              yajl_addChar('value':'APPT');
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
               if stptype = 'P';
                 yajl_addChar('label':'Load');
               elseif stptype = 'D';
                 yajl_addChar('label':'Unload');
               else;
                 yajl_addChar('label':'Other');
               endif;
               yajl_addChar('value':%trim(stpdrvl));
               yajl_addNum('order':'50');
               yajl_addBool('isLabel':'0');
            yajl_EndObj();
          yajl_EndArray();
        endsr;

        //---------------------------------------------------------------------
        //        externalstopD;
        //---------------------------------------------------------------------
        begsr externalstopD;

          yajl_beginArray('external_data');
            yajl_beginObj();
              yajl_addChar('label':'Stop Information');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Appointment Type');
              yajl_addChar('value':'APPT');
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Unload');
              yajl_addChar('value':%trim(dstdrvl));
              yajl_addNum('order':'50');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();
          yajl_EndArray();
        endsr;

        //-------------------------------------------------------------
        //        externaldest;
        //-------------------------------------------------------------
        begsr externaldest;

          yajl_beginArray('external_data');
            yajl_beginObj();
              yajl_addChar('label':'Stop Information');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Appointment Type');
              yajl_addChar('value':'APPT');
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Distance From Previous');
              yajl_addChar('value':'0');
              yajl_addNum('order':'30');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Overnight Parking');
              yajl_addChar('value':'TRUE');
              yajl_addNum('order':'40');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Unload');
              yajl_addChar('value':'TRUE');
              yajl_addNum('order':'50');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Drop Trailer');
              yajl_addChar('value':'TRUE');
              yajl_addNum('order':'60');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();
          yajl_EndArray();
        endsr;

        //-------------------------------------------------------------
        //  Convert date to Display format
        //-------------------------------------------------------------
        begsr convert_Dt;

         Infmt = '*LONGJUL';
         Outfmt = '*YYMD';
         Error = 'N';
         zdter = '00000000';
         Indate = %char(dateconv) + '000000000';
         Reset Apierror;
         Outdt = *blanks;
         callp(e) QWCCVTDT(InFmt:Indate:OutFmt:OutDt:ApiError);
         if %Error;
           Error = 'Y';
         else;
           ccyy  = %subst(OutDt:1:4);
           mm    = %subst(OutDt:5:2);
           dd    = %subst(OutDt:7:2);
           hh = %subst(timeconv:1:2);
           min = %subst(timeconv:3:2);
           sec = '00';
           //milisec  = ('000000');
           timestampChar = timeUTC;
         endif;
       endsr;

        //-------------------------------------------------------------------
        //take input time into TS and convert to UTC  -----------------
        //-------------------------------------------------------------------
        begsr timeSr;

          timeUTC = timestampChar;
          period1 = colon;
          period2 = colon;
          dash3   = T;
          UTCformat = timeUTC + UTCend;
        endsr;

        //-------------------------------------------------------------------
        //take input time into TS and convert to UTC  -----------------
        //-------------------------------------------------------------------
        begsr timeSrNoUTC;

          timeUTC = timestampChar;
          period1 = colon;
          period2 = colon;
          dash3   = T;
          UTCformat = timeUTC + UTCendSys;
        endsr;

        //-------------------------------------------------------------------
        //take input time into TS and convert to UTC  -----------------
        //-------------------------------------------------------------------
        begsr timeSrNoUTC1;

          timeUTC = timestampChar;
          period1 = colon;
          period2 = colon;
          dash3   = T;
          UTCformat = timeUTC + UTCendSys;
        endsr;

        //-------------------------------------------------------------------
        //set time zone
        //-------------------------------------------------------------------
        begsr timezone;

          yajl_addNum('timezone_type':'3');
          yajl_addChar('timezone':'UTC');
        endsr;

        //---------------------------------------------------------------------
        //     delayjob;
        //---------------------------------------------------------------------
        begsr delayjob;

          //"DLYJOB(" + variable from file + ")"
DR018     //dlycmd = %trim(dlycmd11) + ('1') + dlycmd12;
AR018     dlycmd = %trim(dlycmd11) + ('3') + dlycmd12;

          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

        //---------------------------------------------------------------------
        //     delayjob2;
        //---------------------------------------------------------------------
        begsr delayjob2;

          // "DLYJOB(" + variable from file + ")"
          dlycmd = %trim(dlycmd11) + ('45') + dlycmd12;

          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

        //---------------------------------------------------------------------
        //     *inzsr;
        //---------------------------------------------------------------------
A002    begsr *inzsr;
A002      monitor;
A002      open pltintp;
A002      read pltintp;
A002      on-error;
A002      // disable driver team interface
A002      pltteamflg = '0';
AR010     // disable fuel stops interface
AR010     pltfuelflg = '0';
A002      close pltintp;
A002      endmon;
A002    endsr;

       //----------------------------------------------------------------------
     P add_headers     B
     D                 PI
     D   headers                  32767a   varying
     D CRLF            C                   x'0d25'
     D token           s           1224
     D scope           s             30
        /free
          // code to calculate 'token' should go here.
           scope = '"workflow"';

           chain(n) scope plscope;
           if %found(plscope) = *on;
           token = plttoken;
           else;
           pltauthr(scope: token);
           endif;

            headers = 'api-version: 2.0' + CRLF
                    + 'Authorization: Bearer ' + token + CRLF;
        /end-free
     P                 E
       //
       //Incoming   - receives the raw data returned in the web service request
       //
       //This procedure is called from within the 'black box' of the 'http_url_
       //Notice the pointer address of the 5th input parameter on the call of '
       //This procedure must be available to the 'black box', but not included
       //therefore it is found here.
       //
       //----------------------------------------------------------------------
     P incoming        B

       //?procedure parameters
     D incoming        PI            10I 0
     D   descriptor                  10I 0 value
     D   myJson                    8192A   options(*varsize)
     D   datalen                     10I 0 value


       //?Make sure we don't overflow the string:
      /FREE
          retlen = (nextpos + datalen) - 1;
          if retlen > %size(retdata);
                  datalen=datalen-(%size(retdata)-retlen);
          endif;

         //  If there is nothing to write, return THAT...
          if datalen < 1;
                  return 0;
          endif;

         //  Here we add any data sent to the end of our 'retdata' string:
          %subst(retdata: nextpos) =
            %subst(myJson:1:datalen);
          nextpos = nextpos + datalen;

          return datalen;
     P                 E
      /END-FREE
