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
      *  02/04/20  R019   JB/PS  Ensure read of outbound messages.
      *  02/18/20  R020   JB/PS  Remove arrival task requirements.
      *  02/25/20  R021   JB/PS  Resolve pickup/current trailers.
      *  03/02/20  R022   JB/PS  Augment fuel stop gallons/tasks.
      *  03/03/20  R023   JB/PS  Default no cust coordinate to city.
      *  03/03/20  R024   JB/PS  Process previous/current db orders.
      *  03/04/20  R025   JB/PS  Account for missing customer lat/lon.
      *  03/13/20  R026   JB/PS  Populate for missing dest/stop address.
      *  03/19/20  R027   JB/PS  Parse destination info for variable lines.
      *  03/24/20  R028   JB/PS  Patched dst for variable time zones.
      *  03/26/20  R029   JB/PS  Ensure numeric for MC dispatch id.
      *  04/06/20  R030   JB/PS  Add driver alert for date update.
      *  04/07/20  R031   JB/PS  Remove stopoff id from fuel stops.
      *  04/08/20  R032   JB/PS  Resync fuel locations for routing.
      *  04/10/20  R033   JB/PS  Leave seq# at 90 for final delivery.
      *  04/10/20  R034   JB/PS  Insert Fuel Stop as route leg midpoint.
      *  04/15/20  R035   JB/PS  Eliminate duplicate route legs.
      *  04/16/20  R036   JB/PS  Configure Owner/Ops for fuel stops.
      *  04/21/20  R037   JB/PS  Check for required Fuel Stops to POST,
      *                          and install retry queue as failsafe.
      *  04/23/20  R038   JB/PS  Resolve date/time saved to Order POST.
      *  04/23/20  R039   JB/PS  Route sequence can begin with Fuel.
      *  05/04/20  R040   JB/PS  Replace urls with config links.
      *  05/05/20  R041   JB/PS  Get last EF request after dispatch.
      *  05/06/20  R042   JB/PS  Format fuel stop headings on workflow.
      *  05/06/20  R043   JB/PS  Replace IDSC route legs with base ICC.
      *  05/07/20  R044   JB/PS  Add new stops into message arrays.
      *  05/19/20  R045   JB/PS  Parse Appt Macro into messages.
      *  05/31/20  R050   JB/PS  Output to new PS Stops table.
      *  07/06/20  R051   JB/PS  Output High-Value information.
      *  07/14/20  R052   JB/PS  Resolve external_id of Locations.
      *  07/28/20  R053   JB/PS  Output trigger of lost fueld continuity.
      *  08/05/20  R054   JB/PS  Add relays for t-call execution.
      *  08/06/20  R055   JB/PS  Resolve for time zones not on DST.
      *  08/16/20  R056   JB/PS  Resolve stopoff sequence on addInfo.
      *  08/17/20  R057   JB/PS  Allow for missing deadhead routing.
      *  08/18/20  R058   JB/PS  Correct relay pickup time conversion.
      *  08/19/20  R059   JB/PS  Resolve Pickup StopId of dropped load.
      *  08/20/20  R060   JB/PS  Adjust for relay prior to final delv.
      *  08/20/20  R061   JB/PS  Trimmed driver code for server url.
      *  08/24/20  R062   JB/PS  Set array limit to T48 messages.
      *  08/25/20  R064   JB/PS  Pass Tcall Customer to Relay form.
      *  08/25/20  R063   JB/PS  Correct trailer imports to forms.
      *  08/25/20  R064   JB/PS  Pass Tcall Customer to Relay form.
      *  08/25/20  R065   JB/PS  Compare route to EF solution points.
      *  08/26/20  R066   JB/PS  Add Shipper/Consignee to Ship Details.
      *  08/27/20  R068   JB/PS  Catch customer name misspellings.
      *  08/27/20  R069   JB/PS  Set missing coordinates to Barrow, AK.
      *  08/31/20  R070   JB/PS  Condition T-call on NAV setting.
      *  08/31/20  R071   JB/PS  Condition T-call on NAV setting.
      *****************************************************************
      //
     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)
     Fload      if   e           k disk
     Forder     if   e           k disk
     Funits     if   e           k disk
     Fdrivers   if   e           k disk
     Fstopoff   if   e           k disk
     Fcomment   if   e           k disk
     Fmccstllp  if   e           k disk
     Fcustmast  if   e           k disk
AR054Fcities    if   e           k disk
AR026Fcitypsl0  if   e           k disk    rename(rcities:cityl0)
AR026Fcitypsl1  if   e           k disk    rename(rcities:cityl1)
AR017Fftstate   if   e           k disk
     Fcustmaspp if   e           k disk    rename(rcustmas:custpp)
     Fplactordp uf a e           k disk
AR050Fplwrkstpp uf a e           k disk
     Fplnavdrvp if   e           k disk
AR010Fplfueldrvpif   e           k disk
     Fmcmsgh    if   e           k disk
     Fmcmsgd    if   e           k disk
     Fef2reql2  if   e           k disk
     Fef2rtepPS if   e           k disk
     Fplscope   if   E           k DISK
A002 Fpltintp   if   E           k DISK    usropn
AR005FrteStopl1 if   e           k disk    rename(joinrec:rtestopl)
AR010Fef2Route  if   e           k disk
AR043Floade     if   e           k disk
AR046Fcontactps if   e           k disk
AR037FplRetryQl1uf a e           k disk
NEW  FordRoutep if   e           k disk
AR051Fplthivalp if   e           k disk
AR053Fplfuelcntpo    e           k disk
AR054Foptplanp  if   e           k disk

      /include yajl_h
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltwfjobr        PR
     d                                6a
     d                                7s 0 options(*nopass)
     d                                6s 0 options(*nopass)

      * This program's Procedure Interface
     Dpltwfjobr        PI
     d imhunit                        6a
     d imhdate                        7s 0 options(*nopass)
     d imhtime                        6s 0 options(*nopass)

     D incoming        PR            10I 0
     D                               10I 0 value
     D                             8192A   options(*varsize)
     D                               10I 0 value
       //?procedure prototypes
      *-----------------------------------------------------------
AR024D prcOrders       PR                  ExtPgm('PRCORDERS')
AR024D  prvOrder                      7a   options(*nopass)
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

AR041d datCon          pr                  extpgm('DATCON')
  |  d                                7  0
AR041d                                6a

AR054d tCallMiles      pr                  extpgm('ZZTCALLMIL')
AR054d  todr#                              like(tpodr#)
AR054d  tmile                              like(ormile)
AR054d  tseq#                              like(tpseq#)
AR054d  tflag                         1

AR054d rtMiles         pr                  extpgm('MILEITS')
AR054d  rtmilesds                          like(mileds)

AR054d lcinfo        e ds
AR054d mileds        e ds

AR043d diRout          ds
  |  d diCty                          6    dim(7)
AR043d diLC                           1    dim(6)

      // Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)
     d dlycmd11        c                   const('DLYJOB (')
     d dlycmd12        c                   const(')')

      * load origing
     D orgline1        DS            40
     D info                    1     40A
     D orgline2        DS            40
     D orgla                   4      5  0
     D orgtrip                20     26A
     D orgline3        DS            40
     D orgtype                 7     16A
     D orgtemplow             23     25A
     D orgtemphi              32     34A
     D orgline4        DS            40
     D orgtrl                  7     12A
     D orgline5        DS            40
     D orgpudd                18     19  0
     D orgpudm                15     16  0
     D orgpudt                15     19A
     D orgputm                21     25A
     D orgpuh                 21     22  0
     D orgpum                 24     25  0
     D orgpudt1               28     32A
     D orgpudd1               31     32  0
     D orgpudm1               28     29  0
     D orgputm1               34     38A
     D orgpuh1                34     35  0
     D orgpum1                37     38  0
     D orgline6        DS            40
     D orgcust                10     40A
     D orgline7        DS            40
     D orgaddr                10     40A
     D orgline8        DS            40
     D orgaddr1               10     40A
     D orgline9        DS            40
     D orgcty                  7     22A
     D orgst                  27     28A
     D orgline10       DS            40
     D orgphone                8     19A
     D orgline11       DS            40
     D orgdrvl                15     15A
     D orgplts                28     29A
     D orgline12       DS            40
     D orgmlsload             15     19A
     D orgmlsempty            29     33A
     D orgline13       DS            40
     D orgpaco                 1     40A

      * stops array
     D stpline1        DS            40
     D stpinfo                 1     40
     D stpline2        DS            40
     D stpla                   4      5  0
     D stptrip                20     26A
     D stpline3        DS            40
     D stptype                 7     16A
     D stpline4        DS            40
     D stpcust                11     40A
     D stpline5        DS            40
     D stpaddr                11     40A
     D stpline6        DS            40
     D stpaddr2               11     40A
     D stpline7        DS            40
     D stpcty                  7     22A
     D stpst                  27     28A
AR022d cityst          s             18a
     D stpline8        DS            40
     D stpphon                11     22A
     D stpdrvl                38     38A
     D stpline9        DS            40
     D stppudd                18     19  0
     D stppudm                15     16  0
     D stppudt                15     19A
     D stpputm                21     25A
     D stppuh                 21     22  0
     D stppum                 24     25  0
     D stppudt1               28     32A
     D stppudd1               31     32  0
     D stppudm1               28     29  0
     D stpputm1               34     38A
     D stppuh1                34     35  0
     D stppum1                37     38  0
     D stpline10       DS            40
     D stppaco                 1     40A

      * load destination
     D dstline1        DS            40
     D dstinfo                 1     40A
     D dstline2        DS            40
     D dstla                   4      5  0
     D dsttrip                20     26A
     D dstline3        DS            40
     D dsttype                 7     16A
     D dstline4        DS            40
     D dstpudd                18     19  0
     D dstpudm                15     16  0
     D dstpudt                15     19A
     D dstputm                21     25A
     D dstpuh                 21     22  0
     D dstpum                 24     25  0
     D dstpudt1               28     32A
     D dstpudd1               31     32  0
     D dstpudm1               28     29  0
     D dstputm1               34     38A
     D dstpuh1                34     35  0
     D dstpum1                37     38  0
     D dstline5        DS            40
     D dstcust                13     40A
     D dstline6        DS            40
     D dstaddr                13     40A
     D dstline7        DS            40
     D dstaddr1               13     40A
     D dstline8        DS            40
     D dstcty                  7     22A
     D dstst                  27     28A
     D dstline9        DS            40
     D dstphone                8     19A
     D dstline10       DS            40
     D dstdrvl                22     22A
     D dstline11       DS            40
     D dstpaco                 1     40A

AR041D dispUTC         DS
  |  D diccyy                         4a
  |  D dash4                          1a   inz('-')
  |  D dimm                           2a
  |  D dash5                          1a   inz('-')
  |  D didd                           2a
  |  D dash6                          1a   inz('-')
  |  D dihh                           2a
  |  D period4                        1a   inz('.')
  |  D dimin                          2a
  |  D period5                        1a   inz('.')
  |  D disec                          2a   inz('00')
  |  D period6                        1a   inz('.')
AR041D dimill                         6a   inz('000000')


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
     D*** period3                        1a   inz('.')
     D*** milisec                        6a   inz('000000')

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
AR041D dispDate        s               z

     D upper           c                   'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
     D lower           c                   'abcdefghijklmnopqrstuvwxyz'

AR054D rtMls           s              4s 0 dim(100)
AR043D rtCty           s              6a   dim(100)
AR043D rtLeg           s              1a   dim(100)
AR043D rtZip           s              5a   dim(100)
AR043D rtSeq           s              2s 0 dim(100)
AR044D rtTyp           s              1a   dim(100)
  |  D r#              s              3  0
  |  D c#              s              3  0
  |  D v#              s              3  0
AR043D flagDepart      s               n   inz(*off)
     D firstPick       s               n   inz(*off)
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
AR051D highValueA      s             90    dim(16)
AR051D highValue       s           1440a
     D savemdrec       s              2  0
     D X               s              5  0
     D Y               s              5  0
AR044D z               s              5  0
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
     D  messageB       s             40a   dim(50)
     D  messageBn      s           2000a
     D  messageA41     s             40a   dim(1000)
     D  messageA42     s             40a   dim(50)
AR044D  messageA48     s             40a   dim(50)
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
AR010DfuelOnDrv        S               n   INZ(*off)
AR010DrouteOnDrv       S               n   INZ(*off)
AR010DfirstRouteOnDrv  S               n   INZ(*off)
AR017DfoundFuel        S               n   INZ(*off)
AR010Dretbeg           S              7  0 INZ(*ZEROS)
AR010Dretend           S              7  0 INZ(*ZEROS)
AR010Dw_purGal         S              6    INZ(*blanks)
AR042Dw_intChg         S             18    INZ(*blanks)
     Def2Truck         S             50a
     D latitude        S             10
     D longitude       S             10
     D latitude#       S              9  6
     D longitude#      S              9  6
     DrequestId        S              9  0
     Drtesequence      S              3  0
     Drtestop          S              3  0
     Drtestopf         S              3  0
     DrteChkOrd#       S             50
     d foundSegment    S              1
     d skipSeg         S              1
     d testscop        S              1a
     dfuelsequence     S              3  0
AR018d TRec            s              2s 0
AR018d cycleCnt        s              1s 0
AR018d fullRec         s               n
AR016d orgZip          s                   like(zip)
AR016d stpZip          s                   like(zip)
AR016d dstZip          s                   like(zip)
AR016d orgLat          s                   like(lat)
AR016d stpLat          s                   like(lat)
AR016d dstLat          s                   like(lat)
AR016d geoLat          s                   like(lat)
AR016d orgLon          s                   like(lon)
AR016d stpLon          s                   like(lon)
AR016d dstLon          s                   like(lon)
AR016d geoLon          s                   like(lon)
AR016d savCust         s                   like(orgCust)
AR066d shipName        s             40a   inz(*blanks)
AR066d shipLocn        s             40a   inz(*blanks)
AR066d consName        s             40a   inz(*blanks)
AR066d consLocn        s             40a   inz(*blanks)
AR017d country         s              2a
CR069d pltsci          s              6a   inz('PLTSCI')
AR034d savLatitude     s                   like(rteendlat)
AR034d savLongitude    s                   like(rteendlon)
AR034d bgn             s              7  0 Inz(*zeros)
AR041d w_grgDat        s              6a
AR046d ixdate          s                   like(didate)
AR046d ixtime          s                   like(ditime)
AR046d svstp#          s                   like(sostp#)
AR046d svr#            s                   like(r#)
AR053d fuelStop        s               n   inz(*off)
AR054d rlyla           s                   like(orgla)
AR054d planToRelay     s               n   inz(*off)
AR054d plannedRelay    s               n   inz(*off)
AR054d isDisabled      s               n   inz(*off)
AR054d plannedStp#     s                   like(sostp#) inz(*zeros)
AR054d tmile           s                   like(ormile) inz(*zeros)
AR054d tflag           s              1a   inz('Y')
AR054d wkcity          s             15a   inz(*blanks)
     d ZipH            s              5a
     d ZipL            s              5a
     d chgStop         s              2a
     d fstpudt         s              5A
     d fstputm         s              5A
     d fstpudt1        s              5A
     d fstputm1        s              5A
     d fnlpudt         s              5A
     d fnlputm         s              5A
     d fnlpudt1        s              5A
     d fnlputm1        s              5A
TEMP d pltfuelflg      s              1a
TEMP d pltfuelreq      s              1a
TEMP d pltretrymn      s              2a

TEMP     pltfuelflg = '1';
TEMP     pltfuelreq = '0';
TEMP     pltretrymn = '05';

         rtvtimz(offset);
         UTCEndHH = offset;
         curmonth =  %subdt(%date():*MONTHS);
         curyear  =  %subdt(%date():*YEARS);
DR013    //orderby = 1;
AR013    clear orderby;
         navOnDrv = *off;
AR010    fuelOnDrv = *off;

DR010    //exsr delayjob;
         chain imhunit units;
         if %found(units) = *on;
           chain undr1 plnavdrvp;
           if %found(plnavdrvp) = *on;
DR015        //exsr delayjob2;
             navOnDrv = *on;
           endif;

           if undr1 = 'KELMI1';
             undr1 = 'kelmi1';
           endif;

           smhunit = imhunit;
           clear smhdate;
           clear smhtime;
           if %parms() = 1;
             chain(n) (unord#:undisp:undr1) plactordp;
             if %found(plactordp);
               smhdate = plmhdate;
               smhtime = plmhtime;
             endif;
           else;
             smhdate = imhdate;
             smhtime = imhtime;
           endif;

           if smhdate = *zeros Or smhtime = *zeros;
             *inlr = *on;
             return;
           endif;

AR010      //check for driver testing of fuel stop integration.
  |        if pltfuelflg = '1';
  |          chain undr1 plfueldrvp;
  |          if %found(plfueldrvp);
  |            fuelOnDrv = *on;
  |          endif;
AR010      endif;

           // get all T40 information
AR018      clear cycleCnt;
  |        // ensure all MC records are retrieved for processing.
AR018      dou (TRec >= 00 And fullRec) Or cycleCnt = 3;
             exsr loadorigin;
AR018      enddo;
           // get all T42 and T41 information one for each stop
AR018      clear cycleCnt;
  |        // ensure all MC records are retrieved for processing.
AR018      dou (TRec = 90 And fullRec) Or cycleCnt = 3;
             exsr loadstops;
AR018      enddo;

           exsr BuildWfJob;
           myJSON = jsonString;

           //Once you have it in a string, you can send it to the HTTP server.
           //Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF- (CCSID 1
           //and then use HTTPAPI's http_post() routine to do the POST operation
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

AR037      //write to workflow retry queue on request.
  |        setll (smhunit:smhdate:smhtime) plRetryQl1;
  |        if not %equal(plRetryQl1);
  |          clear rplRetryQ;
  |          plqtype = 'WFJOB';
  |          plcrwju = smhunit;
  |          plcrwjd = smhdate;
  |          plcrwjt = smhtime;
  |          plqsend = %char(%timestamp(ts):*ISO);
  |          write rplRetryQ;
AR037      endif;

           chain(n) (unord#:undisp:undr1) plactordp;
           if %found(plactordp) = *on;

A002         //Execute Team Drivers only if interface enabled.
A003         //if pltteamflg = '1' and undr2 <> *blanks;
A003           //Team driver
A003         //  Server = %trim('https://mvt.pltsci.com/api/jobs/');
AR040        //  Server = %trim(pltinturl) + %trim(pltitjobep);
A003         //else;
CR061        //  @endUrl = %trim(undr1) + '/jobs/'+ JobId;
DR040        //  Server = %trim('https://mvt.pltsci.com/api/drivers/'+@endUrl);
CR040            @endUrl = %trim(undr1) + '/jobs/' + JobId;
AR040            Server = %trim(pltinturl) + %trim(pltitwfep) + @endUrl;
A003         //endif;

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
AR037        else;
  |            //remove from workflow retry queue on success request.
  |            chain (smhunit:smhdate:smhtime) plRetryQl1;
  |            if %found(plRetryQl1);
  |              delete rplRetryQ;
AR037          endif;
             endif;

             //if error, Convert the data to EBCDIC
TEMP         if rc <> 1 Or ununit = ' ABAG1' Or ununit = ' TBAG1';
               //Translate(retlen: retdata: 'QTCPEBC');
               filename = %trim(unord#) + 'WFU';
               monitor;
                 cpylnk(filename);
                 on-error;
               endmon;
             endif;

           else;
             //process previous order for truck.
AR024        prcOrders(unprvo);
             //process current order for truck.
AR024        prcOrders(unord#);

A002         //Execute Team Drivers only if interface enabled.
A002         if pltteamflg = '1' and undr2 <> *blanks;
A002           //Team driver
DR040          //Server = %trim('https://mvt.pltsci.com/api/jobs/');
AR040          Server = %trim(pltinturl) + %trim(pltitjobep);
A002         else;
CR061          //@endUrl = %trim(undr1) + '/jobs';
DR040          //Server = %trim('https://mvt.pltsci.com/api/drivers/'+@endUrl);
CR040          @endUrl = %trim(undr1) + '/jobs';
AR040          Server = %trim(pltinturl) + %trim(pltitwfep) + @endurl;
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

AR037        //On error, call api to generate hard error.
  |          if rc = -1;
  |  C                   CALL      'PLERRORC'
  |          else;
  |            //remove from workflow retry queue on success request.
  |            chain (smhunit:smhdate:smhtime) plRetryQl1;
  |            if %found(plRetryQl1);
  |              delete rplRetryQ;
  |            endif;
AR037        endif;

             if rc =  201;
               //write Active Order record to control any future PUT.
               plactord = unord#;
               plactdisp = undisp;
               pldrvcode = undr1;
DR038          //plmhdate  = mhdate;
AR038          plmhdate  = smhdate;
DR038          //plmhtime  = mhtime;
AR038          plmhtime  = smhtime;
               write plactordr;
AR050        endif;

             //if no error, Convert the data to EBCDIC
TEMP         if rc <> 201 Or ununit = ' ABAG1' Or ununit = ' TBAG1';
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

AR066     chain orldat custmast;
  |       if %found(custmast);
  |         shipName = cuName;
  |         shipLocn = %trim(cubcty) +', '+ cubSt;
  |       endif;
  |       chain orcons custmast;
  |       if %found(custmast);
  |         consName = cuName;
  |         consLocn = %trim(cubCty) +', '+ cubSt;
AR066     endif;

          //link preplan to wf to cancel;
          JobId = unord# +'-'+undisp;
          PP = unord#;
AR004     //for dispatch, remove all outdstanding driver preplans
          cancelPP(PP);

          rteChkOrd# = unord# + ' ' + undisp;
          exsr findRouteId;

AR070     if NavOn = *on;
AR054       clear tpCust;
AR054       setll unord# optplanp;
AR054       dou %eof(optplanp);
AR054         reade unord# optplanp;
AR054         if not %eof(optplanp);
AR054           if tpCity = unDCty And tpSt = unDSt;
AR054             plannedRelay = *on;
AR054           else;
AR054             planToRelay = *on;
AR054             callp tCallMiles(tpodr#:tmile:tpseq#:tflag);
AR054             if tmile > *zero;
AR054               ditmil = tmile;
AR054             endif;
AR054           endif;
AR054           leave;
AR054         endif;
AR054       enddo;
AR070     endif;

          yajl_genOpen(*ON);  // use *ON for easier to read JSON
                              // use *OFF for more compact JSON
          yajl_beginObj();

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

DR051             //if orjit = 'Y';
AR051             if orten = 'Y';
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
                    if orsel1 > *blanks;
                      yajl_beginObj();
                        yajl_addChar('type':'seal');
                        yajl_addChar('value':orsel1);
                      yajl_endObj();
                    endif;

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

                    if ditrlr > *blanks;
                      yajl_beginObj();
CR063                   yajl_addChar('type':'Current Trailer');
                        yajl_addChar('value':%trim(ditrlr));
                      yajl_endObj();
                    endif;

CR063               if orgtrl > *blanks and orgtrl <> ditrlr;
CR063                 yajl_beginObj();
CR063                   yajl_addChar('type':'Pickup Trailer');
CR063                   yajl_addChar('value':%trim(orgtrl));
CR063                 yajl_endObj();
CR063               endif;

AR064               if tpCust > *blanks;
  |                   yajl_beginObj();
  |                     yajl_addChar('type':'tCall Cust');
  |                     yajl_addChar('value':tpcust);
  |                   yajl_endObj();
AR064               endif;
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

AR066             yajl_beginObj();
  |                 yajl_addChar('label':'Shipper');
  |                 yajl_addChar('value':shipName + shipLocn);
  |                 yajl_addChar('order':'1');
  |               yajl_endObj();
  |
  |               yajl_beginObj();
  |                 yajl_addChar('label':'Consignee');
  |                 yajl_addChar('value':consName + consLocn);
  |                 yajl_addChar('order':'2');
AR066             yajl_endObj();

                  if dismnf > *zeros;
                    yajl_beginObj();
                       yajl_addChar('label':'Loaded Miles');
                       yajl_addChar('value':%char(dismnf));
                       yajl_addChar('order':'3');
                    yajl_endObj();
                  endif;

                  if diemil > *zeros;
                    yajl_beginObj();
                      yajl_addChar('label':'Empty Miles');
                      yajl_addChar('value':%char(diemil));
                      yajl_addChar('order':'4');
                    yajl_endObj();
                  endif;

DR066           //if orcsh# > *blanks;
  |             //  yajl_beginObj();
  |             //    yajl_addChar('label':'Bill of Lading');
  |             //    yajl_addChar('value':%trim(orcsh#));
  |             //    yajl_addChar('order':'3');
  |             //  yajl_endObj();
DR066           //endif;

                  if orcns# > *blanks;
                    yajl_beginObj();
                      yajl_addChar('label':'PO Number');
                      yajl_addChar('value':%trim(orcns#));
                      yajl_addChar('order':'5');
                    yajl_endObj();
                  endif;

                  if ditrlr > *blanks;
                    yajl_beginObj();
AR021                 yajl_addChar('label':'Current Trailer');
DR021                 //yajl_addChar('label':'Trailer ');
                      yajl_addChar('value':%trim(ditrlr));
                      yajl_addChar('order':'6');
                    yajl_endObj();
                  endif;

                  exsr findffdisp;
                  if messageB(1) > *blanks;
                    yajl_beginObj();
                      yajl_addChar('label':'Dispatch Info');
     C                   movea     messageB      MessageBn
                      yajl_addChar('value':%trim(messageBn));
                      yajl_addChar('order':'7');
                     yajl_endObj();
                  endif;

                  exsr getcomments;
                  yajl_beginObj();
                    yajl_addChar('label':'Trip Comments');
     C                   movea     commentsA     comments
                    yajl_addChar('value':%trim(comments));
                    yajl_addChar('order':'8');
                  yajl_endObj();

AR051             if orten = 'Y';
  |                 exsr getHighValue;
  |                 if highValueA(1) > *blanks;
  |             yajl_beginObj();
  |               yajl_addChar('label':'High-Value Info');
  |               yajl_addChar('value':' ');
  |               yajl_addChar('order':'16');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(1)));
  |               yajl_addNum('order':'17');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(2)));
  |               yajl_addNum('order':'18');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(3)) +' '
  |                                    +%trim(highValueA(4)));
  |               yajl_addNum('order':'19');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(5)) +' '
  |                                    +%trim(highValueA(6)));
  |               yajl_addNum('order':'20');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(7)) +' '
  |                                    +%trim(highValueA(8)));
  |               yajl_addNum('order':'21');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(9)));
  |               yajl_addNum('order':'22');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(10)));
  |               yajl_addNum('order':'23');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(11)));
  |               yajl_addNum('order':'24');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(12)) +' '
  |                                    +%trim(highValueA(13)) +' '
  |                                    +%trim(highValueA(14)));
  |               yajl_addNum('order':'25');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(15)) +' '
  |                                    +%trim(highValueA(16)));
  |               yajl_addNum('order':'26');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |                 //yajl_beginObj();
  |                   //yajl_addChar('label':'High-Value Info');
  |  C                   movea     highValueA    highValue
  |                   //yajl_addChar('value':%trim(highValue));
  |                   //yajl_addChar('order':'1');
  |                 //yajl_endObj();
  |                 endif;
AR051             endif;
                yajl_endArray();

AR016           exsr locations;
AR016           exsr steps;

                if NavOn = *on;
                  exsr routeSegments;
                endif;

DR016           //exsr locations;
DR016           //exsr steps;

                yajl_beginArray('driver_alerts');
AR030           //setll undr1 plfueldrvp;
  |             //if %equal(plfueldrvp);
  |             //  chain (unord#:undisp:undr1) plactordp;
  |             //  if %found(plactordp);
  |             //    yajl_beginObj();
  |             //      yajl_addChar('alerted_at':UTCFormat);
AR016           //      fuelSequence =50;
  |             //      yajl_addNum('alert_level':%char(fuelSequence));
  |             //      yajl_addChar('alert_title':'Fuel Stops Added');
  |             //        yajl_beginArray('driver_alert_items');
  |             //        yajl_endArray();
  |             //    yajl_endObj();
  |             //  endif;
AR030           //endif;
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
          setll (smhunit:smhdate:smhtime) mcmsgh;
          reade (smhunit:smhdate) mcmsgh;
          dow %eof(mcmsgh) = *off;
            if mhpmid = 'T00';
              setll (mhunit
                    :mhdate
                    :mhtime
                    :mhdir) mcmsgd;
              reade (mhunit
                    :mhdate
                    :mhtime
                    :mhdir) mcmsgd;
              dow %eof(mcmsgd) = *off;
                messageb(mdrec#) = mdmsgs;
                reade (mhunit
                      :mhdate
                      :mhtime
                      :mhdir) mcmsgd;
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
DR019     //chain (mhunit:mhdate:mhtime) mcmsgh;
AR019     //DR038chain (mhunit:mhdate:mhtime:'O') mcmsgh;
AR038     chain (smhunit:smhdate:smhtime:'O') mcmsgh;
          if %found(mcmsgh) = *on;
            if mhpmid = 'T40';
              setll (mhunit
                    :mhdate
                    :mhtime
                    :mhdir) mcmsgd;
              reade (mhunit
                    :mhdate
                    :mhtime
                    :mhdir) mcmsgd;
              dow %eof(mcmsgd) = *off;

AR018     if mdrec# = 2;
  |         TRec = %int(%subst(mdmsgs:4:2));
  |       elseif mdrec# >= 9;
  |         fullRec = *on;
AR018     endif;

                 messageA(mdrec#) = mdmsgs;
                 reade (mhunit
                       :mhdate
                       :mhtime
                       :mhdir) mcmsgd;
              enddo;
            endif;
          endif;

          orgline1 = messagea(1);
          orgline2 = messagea(2);
          orgline3 = messagea(3);
          orgline4 = messagea(4);
          orgline5 = messagea(5);
          orgline6 = messagea(6);
          orgline7 = messagea(7);
          if %subst(messagea(8):1:4) = 'CITY';
            orgline8 = *blanks;
            orgline9 = messagea(8);
            orgline10= messagea(9);
            orgline11= messagea(10);
            orgline12= messagea(11);
            orgline13= messagea(12);
          else;
            orgline8 = messagea(8);
            orgline9 = messagea(9);
            orgline10= messagea(10);
            orgline11= messagea(11);
            orgline12= messagea(12);
            orgline13= messagea(13);
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

AR044    clear fstpudt;
AR044    clear fstputm;
AR044    clear fstpudt1;
AR044    clear fstputm1;
AR044    clear fnlpudt;
AR044    clear fnlputm;
AR044    clear fnlpudt1;
AR044    clear fnlputm1;
AR018    clear messageA41;
  |      clear messageA42;
AR044    clear messageA48;
  |      TRec = *hival;
AR018    fullRec = *off;
         x = 0;
         y = 0;
AR044    clear z;
         clear savemdrec;
DR019    //setll (mhunit:mhdate:mhtime) mcmsgh;
AR019    //DR038setll (mhunit:mhdate:mhtime:'O') mcmsgh;
AR038    setll (smhunit:smhdate:smhtime:'O') mcmsgh;
DR038    //reade (mhunit:mhdate) mcmsgh;
AR038    //DR044 reade (smhunit:smhdate) mcmsgh;
AR044    reade smhunit mcmsgh;
         dow %eof(mcmsgh) = *off;
         clear chgStop;
DR044    //if mhpmid = 'T42' or mhpmid = 'T41';
AR044    if mhpmid = 'T42' or mhpmid = 'T41' or mhpmid = 'T48';
         setll (mhunit
               :mhdate
               :mhtime
               :mhdir) mcmsgd;
         reade (mhunit
               :mhdate
               :mhtime
               :mhdir) mcmsgd;
         //dow %eof(mcmsgd) = *off;
NEW      dow %eof(mcmsgd) = *off And x < 999;
         if mhpmid = 'T41';
         if mdrec# = 8 and savemdrec = 6;
         //make sure we account for an additional address line
         x = x +1;
         endif;
         x = x +1;
         messageA41(X) = mdmsgs;
         endif;
         //if mhpmid = 'T42';
         if mhpmid = 'T42' And y < 50;
         if mdrec# = 7 and savemdrec = 5;
         //make sure we account for an additional address line
         y = y +1;
         endif;
         y = Y +1;
         messageA42(Y) = mdmsgs;
         endif;

AR062    if mhpmid = 'T48' And z < 50;
AR044    //DR062  if mhpmid = 'T48';
  |        select;
  |        when mdrec# = 2;
  |          clear sotype;
  |          chgStop = %subst(mdmsgs:25:2);
AR045        if chgStop >= '01' And chgStop <= '88';
  |            chain (%subst(mdmsgs:10:7):%int(chgStop)+1) stopoff;
  |            if %found(stopoff);
  |              chain socust custmast;
  |              if sotype = 'P';
  |                stptype = 'PICK UP';
  |                stpla   = %int(%subst(mdmsgs:25:2));
  |                stptrip = %subst(mdmsgs:10:7);
  |                if %found(custmast);
  |                  stpaddr = cubad1;
  |                  stpphon = %char(cusphn);
  |                  stpdrvl  = 'N';
  |                endif;
  |              elseif sotype = 'D';
  |                dsttype = 'DROPOFF';
  |                dstla   = %int(%subst(mdmsgs:25:2));
  |                dsttrip = %subst(mdmsgs:10:7);
  |                if %found(custmast);
  |                  dstaddr  = cubad1;
  |                  dstphone = %char(cusphn);
  |                  dstdrvl  = 'N';
  |                endif;
  |              endif;
  |            endif;
AR045        endif;
  |        when mdrec# = 3 And chgStop >= '01' And chgStop <= '88';
  |          if sotype = 'P';
  |            stpcust = %subst(mdmsgs:11:30);
  |          elseif sotype = 'D';
  |            dstcust = %subst(mdmsgs:11:30);
  |          endif;
  |        when mdrec# = 4 And chgStop >= '01' And chgStop <= '88';
  |          if sotype = 'P';
  |            stpcty = %subst(mdmsgs:14:16);
  |            stpst  = %subst(mdmsgs:30:2);
  |          elseif sotype = 'D';
  |            dstcty = %subst(mdmsgs:14:16);
  |            dstst  = %subst(mdmsgs:30:2);
  |          endif;
  |        when mdrec# = 5;
  |          if ChgStop = 'S ';
  |            fstpudt = %subst(mdmsgs:13:5);
  |            fstputm = %subst(mdmsgs:26:5);
  |          elseif ChgStop = 'C ';
  |            fnlpudt = %subst(mdmsgs:13:5);
  |            fnlputm = %subst(mdmsgs:26:5);
AR045        elseif chgStop >= '01' And chgStop <= '88';
  |            if sotype = 'P';
  |              stppudt = %subst(mdmsgs:13:5);
  |              stpputm = %subst(mdmsgs:26:5);
  |            elseif sotype = 'D';
  |              dstpudt = %subst(mdmsgs:13:5);
  |              dstputm = %subst(mdmsgs:26:5);
  |            endif;
  |          endif;
  |        when mdrec# = 6;
  |          if ChgStop = 'S ';
  |            fstpudt1 = %subst(mdmsgs:13:5);
  |            fstputm1 = %subst(mdmsgs:26:5);
  |          elseif ChgStop = 'C ';
  |            fnlpudt1 = %subst(mdmsgs:13:5);
  |            fnlputm1 = %subst(mdmsgs:26:5);
AR045        elseif chgStop >= '01' And chgStop <= '88';
  |            if sotype = 'P';
  |              stppudt1 = %subst(mdmsgs:13:5);
  |              stpputm1 = %subst(mdmsgs:26:5);
  |                z +=1;
  |                messageA48(z) = stpline1;
  |                z +=1;
  |                messageA48(z) = stpline2;
  |                z +=1;
  |                messageA48(z) = stpline3;
  |                z +=1;
  |                messageA48(z) = stpline4;
  |                z +=1;
  |                messageA48(z) = stpline5;
  |                z +=1;
  |                messageA48(z) = stpline6;
  |                z +=1;
  |                messageA48(z) = stpline7;
  |                z +=1;
  |                messageA48(z) = stpline8;
  |                z +=1;
  |                messageA48(z) = stpline9;
  |                z +=1;
  |                messageA48(z) = stpline10;
  |              elseif sotype = 'D';
  |                dstpudt1 = %subst(mdmsgs:13:5);
  |                dstputm1 = %subst(mdmsgs:26:5);
  |                z +=1;
  |                messageA48(z) = dstline1;
  |                z +=1;
  |                messageA48(z) = dstline2;
  |                z +=1;
  |                messageA48(z) = dstline3;
  |                z +=1;
  |                messageA48(z) = dstline4;
  |                z +=1;
  |                messageA48(z) = dstline5;
  |                z +=1;
  |                messageA48(z) = dstline6;
  |                z +=1;
  |                messageA48(z) = dstline7;
  |                z +=1;
  |                messageA48(z) = dstline8;
  |                z +=1;
  |                messageA48(z) = dstline9;
  |                z +=1;
  |                messageA48(z) = dstline10;
  |                z +=1;
  |                messageA48(z) = dstline11;
  |            endif;
  |          endif;
  |        endsl;
AR044    endif;

AR018    if mdrec# = 2 And mhpmid <> 'T48';
AR029      if %subst(mdmsgs:4:2) = '  ';
AR029        TRec = 00;
AR029      else;
AR018        TRec = %int(%subst(mdmsgs:4:2));
AR029      endif;
AR018    elseif mdrec# >= 9;
AR018      fullRec = *on;
AR018    endif;

         savemdrec = mdrec#;
         reade (mhunit
               :mhdate
               :mhtime
               :mhdir) mcmsgd;
         enddo;
         if mhunit <> mdunit;
         leave;
         endif;
         endif;
DR038    //reade (mhunit:mhdate) mcmsgh;
AR038    //DR044 reade (smhunit:smhdate) mcmsgh;
AR044    reade smhunit mcmsgh;
         enddo;

AR018    if %eof(mcmsgd) And (TRec <> 90 Or not fullRec);
  |        exsr delayjob;
  |      endif;
AR018    cycleCnt += 1;

         endsr;

        //-------------------------------------------------------------------
        //get delivery    information from message file
        //-------------------------------------------------------------------
        begsr loaddest;

          dstline1 = messagea41(x);
          x = x +1;
          dstline2 = messagea41(x);
          x = x +1;
          dstline3 = messagea41(x);
          x = x +1;
          dstline4 = messagea41(x);
          x = x +1;
          dstline5 = messagea41(x);
          x = x +1;
          dstline6 = messagea41(x);
          x = x +1;
          dstline7 = messagea41(x);
          x = x +1;
          dstline8 = messagea41(x);
          x = x +1;
          dstline9 = messagea41(x);
          x = x +1;
          dstline10= messagea41(x);
          x = x +1;
AR027     if %subst(messagea41(x):1:10) <> 'DISP.INFO.';
            dstline11= messagea41(x);
            x = x +1;
AR027     endif;

          if dstla = 90 And (fnlPuDt > *blanks Or fnlPuDt1 > *blanks);
            dstPuDt  = fnlPuDt;
            dstPuTm  = fnlPuTm;
            dstPuDt1 = fnlPuDt1;
            dstPuTm1 = fnlPuTm1;
          endif;
        endsr;

        //-------------------------------------------------------------------
        //get pickup  information from message file
        //-------------------------------------------------------------------
        begsr loadpick;

         stpline1 = messagea42(y);
         y = y +1;
         stpline2 = messagea42(y);
         y = y +1;
         stpline3 = messagea42(y);
         y = y +1;
         stpline4 = messagea42(y);
         y = y +1;
         stpline5 = messagea42(y);
         y = y +1;
         stpline6 = messagea42(y);
         y = y +1;
         stpline7 = messagea42(y);
         y = y +1;
         stpline8 = messagea42(y);
         y = y +1;
         stpline9 = messagea42(y);
         y = y +1;
         stpline10= messagea42(y);
         y = y +1;
         endsr;

        //-------------------------------------------------------------------
        //get delivery    information from message file
        //-------------------------------------------------------------------
AR044   begsr loaddest48;
  |
  |         dstline1 = messagea48(z);
            z +=1;
            dstline2 = messagea48(z);
            z +=1;
            dstline3 = messagea48(z);
            z +=1;
            dstline4 = messagea48(z);
            z +=1;
            dstline5 = messagea48(z);
            z +=1;
            dstline6 = messagea48(z);
            z +=1;
            dstline7 = messagea48(z);
            z +=1;
            dstline8 = messagea48(z);
            z +=1;
            dstline9 = messagea48(z);
            z +=1;
            dstline10= messagea48(z);
            z +=1;
            dstline11= messagea48(z);
            z +=1;
        endsr;

        //-------------------------------------------------------------------
        //get pickup  information from message file
        //-------------------------------------------------------------------
        begsr loadpick48;

         stpline1 = messagea48(z);
         z +=1;
         stpline2 = messagea48(z);
         z +=1;
         stpline3 = messagea48(z);
         z +=1;
         stpline4 = messagea48(z);
         z +=1;
         stpline5 = messagea48(z);
         z +=1;
         stpline6 = messagea48(z);
         z +=1;
         stpline7 = messagea48(z);
         z +=1;
         stpline8 = messagea48(z);
         z +=1;
         stpline9 = messagea48(z);
         z +=1;
  |      stpline10= messagea48(z);
  |      z +=1;
AR044    endsr;

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
        //--get High Value for WF job -------------------------
        //-----------------------------------------------------
AR051   begsr getHighValue;
  |
  |       clear x;
  |       dou %eof(plthivalp) Or x > 16;
  |         read plthivalp;
  |         if not %eof(plthivalp) And x <= 16 And plhvdesc > *blanks;
  |           x +=1;
  |           highValueA(x) = plhvdesc;
  |         endif;
  |       enddo;
AR051   endsr;

        //-----------------------------------------------------
        //--build locations ---------------------------
        //-----------------------------------------------------
        begsr Locations;

AR050     setll (unord#:undisp) plwrkstpp;
  |       dou %eof(plwrkstpp);
  |         reade (unord#:undisp) plwrkstpp;
  |         if not %eof(plwrkstpp);
  |           delete rplwrkstp;
  |         endif;
AR050     enddo;

AR010     routeOnDrv = *off;
  |       clear fuelSequence;
  |       //if Driver Fuel Stops enabled for Driver.
  |       if fuelOnDrv;
  |         //verify Load Stops exist for dispatched route.
CR043       setll unord# rteStopl1;
CR043       if %equal(rteStopl1);
  |           //check for EF fuel & route
  |           chain (requestID:unord#:undisp) ef2Route;
  |           if %found(ef2Route) And seq > *zero;
  |             routeOnDrv = *on;
  |             firstRouteOnDrv = *on;
  |           endif;
  |         endif;
  |       endif;
  |
AR037     //sync Fuel Stops, if required.
  |       if pltFuelReq = '1' And fuelOnDrv And not(routeOnDrv);
  |         //put calling parms into retry queue.
  |         setll (smhunit:smhdate:smhtime) plRetryQl1;
  |         if not %equal(plRetryQl1);
  |           //write out new record in retry queue.
  |           clear rplRetryQ;
  |           plqtype = 'WFJOB';
  |           plcrwju = smhunit;
  |           plcrwjd = smhdate;
  |           plcrwjt = smhtime;
  |           plqsend = %char(%timestamp(ts)
  |                           +%minutes(%int(pltretrymn)):*ISO);
  |           write rplRetryQ;
  |         endif;
  |         //exit pgm with no workflow submit.
  |         *inlr = *on;
  |         return;
AR037     endif;
  |
  |       //process existing Load Route.
  |       if routeOnDrv;
AR043       //this section to prep for stop routes/identifiers, and is
  |         //needed if ICC Route Sync is not populated (ORDROUTEP).
  |         clear rtCty;
  |         clear rtLeg;
  |         clear rtZip;
  |         clear rtSeq;
AR044       clear rtTyp;
  |         svStp# =1;
  |         r# =1;
  |         //retrieve the ICC load route/stop identifiers.
  |         for v# = 1 to 6;
  |           if diCty(v#) <> *blanks;
  |             rtCty(r#) = diCty(v#);
  |             rtLeg(r#) = diLC(v#);
  |             if rtLeg(r#) <> 'E' And
  |                rtLeg(r#) <> 'U' And rtLeg(r#) <> 'A';
  |               if undisp > '01' And r# = 1 And firstPick = *off;
  |                 rtTyp(r#) = 'P';
  |                 firstPick = *on;
  |                 clear orgpudt;
  |                 clear orgputm;
  |                 clear orgpudt1;
  |                 clear orgputm1;
  |               else;
  |                 dou %eof(rteStopl1) Or
  |                    soCtyc + soSt  = rtCty(r#);
  |                   reade unord# rteStopl1;
  |                 enddo;
  |                 if not %eof(rteStopl1) And
  |                    soCtyc + soSt  = rtCty(r#);
  |                   rtZip(r#) = cubZip;
  |                   rtSeq(r#) = soStp#;
AR044                 rtTyp(r#) = soType;
  |                   svStp# = soStp#;
  |                 else;
  |                   if rtCty(r#+1) = *blanks;
  |                     rtTyp(r#) = 'D';
  |                     rtSeq(r#) = 90;
  |                   else;
  |                     rtTyp(r#) = 'V';
  |                   endif;
  |                   setll (unord#:svstp#) rtestopl1;
  |                 endif;
  |               endif;
  |             endif;
  |             r# +=1;
  |           elseif diLC(v#) = *blank;
  |             leave;
  |           endif;
  |         endfor;
  |
  |         //retrieve any route extensions.
  |         v# = 6;
  |         if diLC(v#) <> *blank;
  |           c# = 1;
  |           setll (unord#:undisp) loade;
  |           dou %eof(loade);
  |           reade (unord#:undisp) loade;
  |             if not %eof(loade);
  |               dirout = ldrout + ldlsts;
  |               for v# = 1 to 6;
  |                 if diCty(v#) <> *blanks;
  |                   rtCty(r#) = diCty(v# +1);
  |                   rtLeg(r#) = diLC(v# +1);
  |                   dou %eof(rteStopl1) Or
  |                      soCtyc + soSt  = rtCty(r#);
  |                     reade unord# rteStopl1;
  |                   enddo;
  |                   if not %eof(rteStopl1) And
  |                     soCtyc + soSt  = rtCty(r#);
  |                     rtZip(r#) = cubZip;
  |                     rtSeq(r#) = soStp#;
AR044                   rtTyp(r#) = soType;
  |                     svStp# = soStp#;
  |                   else;
  |                     if rtCty(r#+1) = *blanks;
  |                       rtTyp(r#) = 'D';
  |                       rtSeq(r#) = 90;
  |                     else;
  |                       rtTyp(r#) = 'V';
  |                     endif;
  |                     setll (unord#:svstp#) rtestopl1;
  |                   endif;
  |                   r# +=1;
  |                 elseif diLC(v#) = *blank;
  |                   leave;
  |                 endif;
  |               endfor;
  |             endif;
  |           enddo;
AR043       endif;
  |
  |         //this section for determining lost route continuity, by
  |         //comparing ICC route to EF solution route: causes NAV issues
  |         //appended to determine relay sequence in EF solution route.
AR053       clear fuelstop;
  |         setll (requestID:unord#:undisp) ef2Route;
  |         setll (unord#:undisp) ordRoutep;
  |         for v# =1 to 100;
  |           if rtCty(v#) = *blanks;
  |             leave;
  |           else;
AR065           if v# = 1 And rtLeg(v#) = 'L';
AR065             dou %eof(ordRoutep) Or ouSeq# > *zero;
AR065               reade (unord#:undisp) ordRoutep;
AR065               if not %eof(ordRoutep);
  |                   dou %eof(ef2Route) Or stoptype = 'S';
  |                     reade (requestID:unord#:undisp) ef2Route;
AR053                   if not %eof(ef2Route) And stoptype = 'F';
AR053                     fuelStop = *on;
AR053                   endif;
  |                   enddo;
AR065               endif;
AR065             enddo;
AR054           else;
AR065             reade (unord#:undisp) ordRoutep;
AR065             if not %eof(ordRoutep);
  |                 dou %eof(ef2Route) Or stoptype = 'S';
  |                   reade (requestID:unord#:undisp) ef2Route;
AR053                 if not %eof(ef2Route) And stoptype = 'F';
AR053                   fuelStop = *on;
AR053                 endif;
  |                 enddo;
AR065             endif;
AR065           endif;
AR070           if v# >= 2 And NavOn = *on;
AR054           //DR070  if v# >= 2
AR054             if rtLeg(v#-1) = 'L' And rtCty(v#-1) > *blanks And
AR054                tpCity > *blanks And tpSt > *blanks And plannedStp# = 0;
AR054               clear mileds;
AR054               mdcty1 = rtCty(v#-1);
AR054               mdcty2 = rtCty(v#);
AR054               mditf = 'N';
AR054               mdreqt = 'M';
AR054               mdnmfl = lcmtyp;
AR054               callp rtMiles(mileds);
AR054               rtMls(v#) = mdhgm;
AR054               clear mileds;
AR054               mdcty1 = rtCty(v#-1);
AR054               mdcty2 = tpCity + tpSt;
AR054               mditf = 'N';
AR054               mdreqt = 'M';
AR054               mdnmfl = lcmtyp;
AR054               callp rtMiles(mileds);
AR054               if mdhgm <= rtMls(v#) Or rtSeq(v#) = 90;
AR054                 plannedStp# = rtSeq(v#-1);
                      if plannedStp# = *zeros;
                         plannedStp# = 1;
AR060                 elseif plannedStp# = 90;
AR060                    plannedStp# -= 1;
                      endif;
AR054               endif;
AR054             endif;
AR065           endif;
  |             if not %eof(ef2Route) And stoptype = 'S';
  |               //validate EF solution results based upon ORDROUTEP
  |               if not %eof(ordRoutep) And ouSeq# > *zeros;
  |                 zipL = *hival;
  |                 zipH = *loval;
  |                 if %subst(zip:1:5) > '00000' And
  |                    %subst(zip:1:5) < '99999';
  |                   evalr zipL = %char(%int(%subst(zip:1:5)) -10)    ;
  |                   zipL = %xlate(' ':'0':zipL);
  |                   evalr zipH = %char(%int(%subst(zip:1:5)) +10)    ;
  |                   zipH = %xlate(' ':'0':zipH);
  |                 endif;
  |                 if %eof(ordRoutep) Or (ouLCty = *blanks or ouLSt = *blanks);
  |                   routeOnDrv = *off;
  |                   firstRouteOnDrv = *off;
AR053                 if fuelStop;
AR053                   plfscordr = unord#;
AR053                   plfscdisp = undisp;
AR053                   plfscunit = ununit;
AR053                   plfscdrv1 = undr1;
AR053                   plfscdrv2 = undr2;
AR053                   plfscdate = smhdate;
AR053                   plfsctime = smhtime;
AR053                   write rplfuelcnt;
AR053                 endif;
  |                   leave;
  |                 elseif (ouLCty + ouLSt <> ciCty + ciSt and
  |                    (ouZip < zipL or ouZip > zipH)) Or
  |                    (plannedRelay and rtCty(v#) = tpCity + tpSt) Or
  |                    (ouStp# = 90 and ouLCty + ouLSt <> unDCty + unDSt);
AR054                 if not plannedRelay And not planToRelay;
  |                     routeOnDrv = *off;
  |                     firstRouteOnDrv = *off;
AR053                   if fuelStop;
AR053                     plfscordr = unord#;
AR053                     plfscdisp = undisp;
AR053                     plfscunit = ununit;
AR053                     plfscdrv1 = undr1;
AR053                     plfscdrv2 = undr2;
AR053                     plfscdate = smhdate;
AR053                     plfsctime = smhtime;
AR053                     write rplfuelcnt;
AR053                   endif;
  |                     leave;
AR054                 endif;
  |                 endif;
  |               endif;
  |             endif;
  |           endif;
AR057       endfor;
  |
  |         //this section for workflow generation of ICC/EF route
  |         if routeOnDrv;
  |         //check for EF fuel & route
  |         setll (requestID:unord#:undisp) ef2Route;
AR057       setll (unord#:undisp) ordRoutep;
AR057       if %equal(ef2Route)
AR057          And %equal(ordRoutep);
  |           yajl_beginArray('locations');
  |             x = 1;
AR044           y = 1;
AR044           z = 1;
AR054           clear soStp#;
  |             dou %eof(ef2Route);
  |               reade (requestId:unord#:undisp) ef2Route;
  |               //only process stop and fuel locations
  |               if not %eof(ef2Route) And seq > *zero;
  |                 if stoptype = 'S';
  |                   //process pickup & drop stopoffs
AR057                 reade (unord#:undisp) ordRoutep;
AR057                 if not %eof(ordRoutep) And ouSeq# > *zero;
  |                     chain (ouOdr#:ouStp#) stopoff;
  |                     if %found(stopoff);
  |                       ouStpTyp = sotype;
  |                     endif;
AR043                   cubZip = ouZip;
AR043                   soStp# = ouStp#;
AR044                   soType = ouStpTyp;
AR054                   if (plannedRelay or planToRelay) And
AR054                      soStp# > plannedStp# And not isDisabled;
AR054                     exsr locationRelay;
AR054                   endif;
  |                     select;
  |                     //write corresponding location
  |                     when soStp# = 01 Or (soStp# = 00 and ouSeq# = 1);
  |                       //seq = 01;
  |                       exsr locationStopO;
  |                     when soStp# > 01 and soStp# < 90;
  |                       if messageA42(y) > *blanks And soType = 'P'
AR044                        And %int(%subst(messageA42(y+1):4:2)) = soStp#-1;
  |                         exsr loadPick;
  |                         exsr locationStop;
  |                       elseif messageA41(x) > *blanks And soType = 'D'
AR044                        And %int(%subst(messageA41(x+1):4:2)) = soStp#-1;
  |                         exsr loadDest;
  |                         exsr locationStopD;
  |                       elseif messageA48(z+1) > *blanks And soType = 'P'
AR044                        And %int(%subst(messageA48(z+1):4:2)) = soStp#-1;
  |                         exsr loadPick48;
  |                         exsr locationStop;
  |                       elseif messageA48(z+1) > *blanks And soType = 'D'
AR044                        And %int(%subst(messageA48(z+1):4:2)) = soStp#-1;
  |                           exsr loadDest48;
  |                           exsr locationStopD;
  |                       endif;
  |                     when soStp# = 90;
  |                       //seq = 90;
  |                       dow messageA41(x) > *blanks;
  |                         exsr loadDest;
  |                         exsr locationStopD;
  |                       enddo;
  |                     endsl;
AR057                 endif;
  |                 //write fuel stop locations
  |                 elseif stoptype = 'F';
AR054                 if (plannedRelay or planToRelay)
AR054                    And isDisabled = *off And soStp# >= plannedStp#
AR054                    And soCtyc > *blanks And soSt > *blanks
AR054                    And ciCty > *blanks And ciSt > *blanks;
AR054                   clear mileds;
AR054                   mdcty1 = soCtyc + soSt;
AR054                   mdcty2 = ciCty  + ciSt;
AR054                   mditf = 'N';
AR054                   mdreqt = 'M';
AR054                   mdnmfl = lcmtyp;
AR054                   callp rtMiles(mileds);
AR054                   tmile = mdhgm;
AR054                   clear mileds;
AR054                   mdcty1 = soCtyc + soSt;
AR054                   mdcty2 = tpCity + tpSt;
AR054                   mditf = 'N';
AR054                   mdreqt = 'M';
AR054                   mdnmfl = lcmtyp;
AR054                   callp rtMiles(mileds);
AR054                   if mdhgm < tmile;
AR054                     exsr locationRelay;
AR054                   endif;
AR054                 endif;
  |                   soStp# = 00;
  |                   exsr locationFuel;
  |                 endif;
  |               endif;
  |             enddo;
  |           yajl_endArray();
  |           exsr loadHeaderInfo;
  |         endif;
  |         endif;
  |       endif;
  |
  |       //if Driver Fuel Stops disabled,
  |       //  Or either EF Fuel Route or Load Route missing.
  |       if not(fuelOnDrv) Or not(routeOnDrv)
AR010        Or (routeOnDrv and not %equal(ef2Route));
  |
  |         yajl_beginArray('locations');
  |           //seq = 01;
AR010         exsr locationStopO;

              y = 1;
              dow messageA42(y) <> *blanks And y<=40;
                exsr loadpick;
                exsr locationstop;
              enddo;

AR044         z = 1;
  |           dow messageA48(z+1) <> *blanks And z <= 40;
  |             if %subst(messageA48(z+2):7:7) = 'PICK UP';
  |               exsr loadPick48;
  |               exsr locationStop;
  |             elseif %subst(messageA48(z+2):7:7) = 'DROPOFF';
  |               exsr loadDest48;
  |               exsr locationStopD;
  |             endif;
AR044         enddo;

              x = 1;
              dow messageA41(x) <> *blanks And x<=989;
                exsr loaddest;
                exsr locationstopD;
              enddo;

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

AR039     clear rteSequence;
AR010     //process existing Load Route.
  |       if routeOnDrv;
  |         //check for EF fuel & route
  |         setll (requestID:unord#:undisp) ef2Route;
AR057       setll (unord#:undisp) ordRoutep;
AR057       if %equal(ef2Route)
AR057          And %equal(ordRoutep);
  |           yajl_beginArray('route_legs');
  |             x = 1;
AR044           y = 1;
AR044           z = 1;
AR054           clear soStp#;
AR054           clear isDisabled;
  |             dou %eof(ef2Route);
  |               reade (requestId:unord#:undisp) ef2Route;
  |               //only process stop and fuel locations
  |               if not %eof(ef2Route) And seq > *zero;
  |                 if stoptype = 'S';
  |                   //process pickup & drop stopoffs
AR057                 reade (unord#:undisp) ordRoutep;
AR057                 if not %eof(ordRoutep) And ouSeq# > *zero;
  |                     chain (ouOdr#:ouStp#) stopoff;
  |                     if %found(stopoff);
  |                       ouStpTyp = sotype;
  |                     endif;
AR043                   cubZip = ouZip;
AR043                   soStp# = ouStp#;
AR044                   soType = ouStpTyp;
AR054                   if (plannedRelay or planToRelay) And
AR054                     soStp# > plannedStp# And not isDisabled;
AR054                     exsr locationsRouteR;
AR054                   endif;
  |                     select;
  |                     //write corresponding location
  |                     when soStp# = 01 Or (soStp# = 00 and ouseq# = 1);
  |                       //seq = 01;
  |                       exsr addOriginRoute;
  |                     when soStp# > 01 and soStp# < 90;
  |                       if messageA42(y) > *blanks And soType = 'P'
AR044                        And %int(%subst(messageA42(y+1):4:2)) = soStp#-1;
  |                         exsr loadPick;
  |                         exsr locationsRoute;
  |                       elseif messageA41(x) > *blanks And soType = 'D'
AR044                        And %int(%subst(messageA41(x+1):4:2)) = soStp#-1;
  |                         exsr loadDest;
  |                         exsr locationsRouteD;
  |                       elseif messageA48(z+1) > *blanks And soType = 'P'
AR044                        And %int(%subst(messageA48(z+1):4:2)) = soStp#-1;
  |                         exsr loadPick48;
  |                         exsr locationsRoute;
  |                       elseif messageA48(z+1) > *blanks And soType = 'D'
AR044                        And %int(%subst(messageA48(z+1):4:2)) = soStp#-1;
  |                         exsr loadDest48;
  |                         exsr locationsRouteD;
  |                       endif;
  |                     when soStp# = 90;
  |                       //seq = 90;
  |                       dow messageA41(x) > *blanks;
  |                         exsr loadDest;
  |                         exsr locationsRouteD;
  |                       enddo;
  |                     endsl;
  |                   endif;
  |                 //write fuel stop locations
  |                 elseif stoptype = 'F';
AR054                 if (plannedRelay or planToRelay)
AR054                    And isDisabled = *off And soStp# >= plannedStp#
AR054                    And soSt > *blanks And soCtyc > *blanks
AR054                    And ciSt > *blanks And ciCty > *blanks;
AR054                   clear mileds;
AR054                   mdcty1 = soCtyc + soSt;
AR054                   mdcty2 = ciCty  + ciSt;
AR054                   mditf = 'N';
AR054                   mdreqt = 'M';
AR054                   mdnmfl = lcmtyp;
AR054                   callp rtMiles(mileds);
AR054                   tmile = mdhgm;
AR054                   clear mileds;
AR054                   mdcty1 = soCtyc + soSt;
AR054                   mdcty2 = tpCity + tpSt;
AR054                   mditf = 'N';
AR054                   mdreqt = 'M';
AR054                   mdnmfl = lcmtyp;
AR054                   callp rtMiles(mileds);
AR054                   if mdhgm < tmile;
AR054                     exsr locationsRouteR;
AR054                   endif;
AR054                 endif;
  |                   soStp# = 00;
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
AR032        Or (routeOnDrv and not %equal(ef2Route));

AR016       fuelSequence =1;
            if requestId <> *zeros;
              yajl_beginArray('route_legs');
                //seq = 01;
                exsr addoriginroute;

                y = 1;
                dow messageA42(y) <> *blanks And y <= 40;
                  exsr loadpick;
                  exsr locationsRoute;
                enddo;

AR044           z = 1;
  |             dow messageA48(z+1) <> *blanks And z <= 40;
  |               if %subst(messageA48(z+2):7:7) = 'PICK UP';
  |                 exsr loadPick48;
  |                 exsr locationsRoute;
  |               elseif %subst(messageA48(z+2):7:7) = 'DROPOFF';
  |                 exsr loadDest48;
  |                 exsr locationsRouteD;
  |               endif;
AR044           enddo;

                x = 1;
                dow messageA41(x) <> *blanks And x <= 989;
                  exsr loaddest;
                  exsr locationsRouteD;
                enddo;
              yajl_endArray();
            endif;
AR032     endif;
        endsr;

        //-----------------------------------------------------
        //--add origin route segments   ------------
        //-----------------------------------------------------
        begsr addoriginroute;

          yajl_beginObj();
            yajl_addChar('external_id':%trim(JobID) +
CR052                    '-'+ %trim(orgcust) + '-' + %trim(orgcty));
AR032       rteStop = 1;
DR039       //clear rteSequence;
            yajl_beginArray('segments');
AR034       clear savLatitude;
AR034       clear savLongitude;
AR032       setll (requestId:rteStop) ef2rtepPS;
AR032       reade (requestId:rteStop) ef2rtepPS;
            exsr findRouteSegments;
              if foundSegment = *off;
                checkname = orgcust;
                checkadr  = orgaddr;
                checkcty  = orgcty;
                checkst   = orgst;
                exsr getcust#;
                //if no segments found in the route file use stop location
DR025           //chain cust#  mccstllp;
DR025           //if %found(mccstllp) = *on;
AR025           if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
                  yajl_beginObj();
                    rteSequence += 1;
                    yajl_addNum('latitude':%char(C#DECLATD));
                    yajl_addNum('longitude':%char(C#DECLOND));
                    yajl_addChar('sequence':%char(rteSequence));
                  yajl_endObj();
AR023           elseif %found(citypsl0);
  |               yajl_beginObj();
  |                 rteSequence += 1;
  |                 orgLat = (CiLat/3600);
  |                 orgLon = (CiLong/3600);
  |                 yajl_addNum('latitude':%char(orgLat));
  |                 yajl_addNum('longitude':'-' + %char(orgLon));
  |                 yajl_addChar('sequence':%char(rteSequence));
AR023             yajl_endObj();
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
DR032       //rteStop += 1;
            yajl_addChar('external_id':%trim(JobID) +
CR052                    '-'+ %trim(stpcust) + '-' + %trim(stpcty));

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
DR025           //chain cust#  mccstllp;
DR025           //if %found(mccstllp) = *on;
AR025           if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
                  yajl_beginObj();
                    rteSequence += 1;
                    yajl_addNum('latitude':%char(C#DECLATD));
                    yajl_addNum('longitude':%char(C#DECLOND));
                    yajl_addChar('sequence':%char(rteSequence));
                  yajl_endObj();
AR023           elseif %found(citypsl0);
  |               yajl_beginObj();
  |                 rteSequence += 1;
  |                 stpLat = (CiLat/3600);
  |                 stpLon = (CiLong/3600);
  |                 yajl_addNum('latitude':%char(stpLat));
  |                 yajl_addNum('longitude':'-' + %char(stpLon));
  |                 yajl_addChar('sequence':%char(rteSequence));
AR023             yajl_endObj();
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
DR032       //rteStop += 1;
            yajl_addChar('external_id':%trim(JobID) +
CR052                    '-'+ %trim(dstcust) + '-' + %trim(dstcty));

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
DR025           //chain cust#  mccstllp;
DR025           //if %found(mccstllp) = *on;
AR025           if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
                  yajl_beginObj();
                    rteSequence += 1;
                    yajl_addNum('latitude':%char(C#DECLATD));
                    yajl_addNum('longitude':%char(C#DECLOND));
                    yajl_addChar('sequence':%char(rteSequence));
                  yajl_endObj();
AR023           elseif %found(citypsl0);
  |               yajl_beginObj();
  |                 rteSequence += 1;
  |                 dstLat = (CiLat/3600);
  |                 dstLon = (CiLong/3600);
  |                 yajl_addNum('latitude':%char(dstLat));
  |                 yajl_addNum('longitude':'-' + %char(dstLon));
  |                 yajl_addChar('sequence':%char(rteSequence));
AR023             yajl_endObj();
                endif;
              endif;
            yajl_endArray();
          yajl_endObj();
        endsr;

        //-----------------------------------------------------
        //--add location fuel/via segments  ----------
        //-----------------------------------------------------
AR010   begsr locationsRouteF;
  |
AR054     wkcity = city;
  |       citySt = %subst(wkcity:1:15) + ',' + state;
  |       citySt = %xlate(' ':'_':citySt);
  |       clear w_purGal;
AR042     clear w_intChg;
DR038     //setgt (mhunit) mcmsgh;
AR038     setgt (smhunit) mcmsgh;
DR041     //dou %eof(mcmsgh) Or (mhdate = smhdate
DR041       //and mhtime < smhtime) Or (mhdate < smhdate)
DR041       //Or mhpmid = 'T00' and %subst(mdmsgs:1:9) = 'IDSC/FUEL';
AR041     dou %eof(mcmsgh) Or (mhdate = ixdate and mhtime <
AR041        %int(ixtime + '00')) Or (mhdate < ixdate)
AR041        Or mhpmid = 'T00' and %subst(mdmsgs:1:9) = 'IDSC/FUEL';
DR038       //readpe (mhunit) mcmsgh;
AR038       readpe (smhunit) mcmsgh;
  |         chain (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |       enddo;
  |       if not %eof(mcmsgh) And mhpmid = 'T00'
DR041        //And (mhdate > smhdate or
DR041        //     mhdate = smhdate and mhtime > smhtime)
AR041        And (mhdate > ixdate or mhdate = ixdate
AR041        and mhtime > %int(ixtime + '00'))
  |          And %subst(mdmsgs:1:9) = 'IDSC/FUEL';
  |         setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |         dou %eof(mcmsgd) Or %subst(mdmsgs:20:18)=citySt;
  |           reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |           if not %eof(mcmsgd) And %subst(mdmsgs:20:18)=citySt;
  |             reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |             if not %eof(mcmsgd);
AR042             w_intchg = %subst(mdmsgs:1:18);
  |               if %subst(mdmsgs:32:3) = 'QTY';
  |                 w_purGal = %subst(mdmsgs:35:3);
  |               elseif %subst(mdmsgs:33:4) = 'FILL';
  |                 w_purGal = %subst(mdmsgs:33:4);
  |               endif;
  |               leave;
  |             endif;
  |           endif;
  |         enddo;
  |       endif;
  |
  |       yajl_beginObj();
  |         yajl_addChar('external_id':%trim(JobID) +
  |                      '-'+ %trim(name) +'/'+ %trim(w_intchg));
  |         yajl_beginArray('segments');
  |           exsr findRouteSegments;
  |           if foundSegment = *off;
  |             rteStopf = 1;
  |             rteSequence += 1;
  |             latitude#  = lat * .0001;
  |             longitude# = lon * .0001;
  |             yajl_beginObj();
  |               yajl_addNum('latitude':%char(latitude#));
  |               yajl_addNum('longitude':'-' + %char(longitude#));
  |               yajl_addChar('sequence':%char(rteSequence));
  |             yajl_endObj();
  |             rteStopf += 1;
DR039           //rteSequence += 1;
  |           endif;
  |         yajl_endArray();
  |       yajl_endObj();
AR010   endsr;

        //-----------------------------------------------------
        //--add location relay segments  ----------
        //-----------------------------------------------------
AR054   begsr locationsRouteR;
  |
  |     if not(plannedRelay) Or plannedRelay And not(isDisabled);
  |
  |       chain tpCust custmast;
  |       if %found(custmast);
  |         chain tpCust mccstllp;
  |         if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |           chain (tpSt:tpCity) cities;
  |         if %found(cities);
  |           ciname = %xlate(lower:upper:ciname);
  |
  |           isDisabled = *on;
  |
  |           yajl_beginObj();
  |             yajl_addChar('external_id':%trim(JobID) +
  |                          '-'+ %trim(cuname) + '-' + %trim(ciname));
  |             yajl_beginArray('segments');
  |             //exsr findRouteSegments;
  |             //if foundSegment = *off;
  |                 rteStopf = 1;
  |                 rteSequence += 1;
  |                 latitude#  = lat * .0001;
  |                 longitude# = lon * .0001;
  |                 yajl_beginObj();
  |                   yajl_addNum('latitude':%char(C#DECLATD));
  |                   yajl_addNum('longitude':%char(C#DECLOND));
  |                   yajl_addChar('sequence':%char(rteSequence));
  |                 yajl_endObj();
  |                 rteStopf += 1;
  |             //endif;
  |             yajl_endArray();
  |           yajl_endObj();
  |           endif;
  |           endif;
  |         endif;
  |       endif;
AR054   endsr;

AR010   //-----------------------------------------------------
  |     //--add fuel locations  ------------
  |     //-----------------------------------------------------
  |     begsr locationFuel;
  |
AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);
  |
AR054     if isDisabled;
AR054       seq += 1;
AR054     endif;
  |
AR054     wkcity = city;
  |       citySt = %subst(wkcity:1:15) + ',' + state;
  |       citySt = %xlate(' ':'_':citySt);
  |       clear w_purGal;
AR042     clear w_intChg;
DR038     //setgt (mhunit) mcmsgh;
AR038     setgt (smhunit) mcmsgh;
DR041     //dou %eof(mcmsgh) Or (mhdate = smhdate
DR041       //and mhtime < smhtime) Or (mhdate < smhdate)
DR041       //Or mhpmid = 'T00' and %subst(mdmsgs:1:9) = 'IDSC/FUEL';
AR041     dou %eof(mcmsgh) Or (mhdate = ixdate and mhtime <
AR041        %int(ixtime + '00')) Or (mhdate < ixdate)
AR041        Or mhpmid = 'T00' and %subst(mdmsgs:1:9) = 'IDSC/FUEL';
DR038       //readpe (mhunit) mcmsgh;
AR038       readpe (smhunit) mcmsgh;
  |         chain (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |       enddo;
  |       if not %eof(mcmsgh) And mhpmid = 'T00'
DR041        //And (mhdate > smhdate or
DR041        //     mhdate = smhdate and mhtime > smhtime)
AR041        And (mhdate > ixdate or mhdate = ixdate
AR041        and mhtime > %int(ixtime + '00'))
  |          And %subst(mdmsgs:1:9) = 'IDSC/FUEL';
  |         setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |         dou %eof(mcmsgd) Or %subst(mdmsgs:20:18)=citySt;
  |           reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |           if not %eof(mcmsgd) And %subst(mdmsgs:20:18)=citySt;
  |             reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |             if not %eof(mcmsgd);
AR042             w_intchg = %subst(mdmsgs:1:18);
  |               if %subst(mdmsgs:32:3) = 'QTY';
  |                 w_purGal = %subst(mdmsgs:35:3);
  |               elseif %subst(mdmsgs:33:4) = 'FILL';
  |                 w_purGal = %subst(mdmsgs:33:4);
  |               endif;
  |               leave;
  |             endif;
  |           endif;
  |         enddo;
  |       endif;
  |
  |       yajl_beginObj();
  |         yajl_addNum('id':%char(seq));
  |         yajl_addChar('external_id':%trim(JobID)
  |                       +'-'+ %trim(name) +'/'+ %trim(w_intchg));
  |         yajl_addChar('type':'job');
  |         yajl_addChar('name':%trim(name) +'/'+ %trim(w_intchg));
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
  |         fuelSequence += 1;
  |
  |         //exsr hours;
  |         TS = %timestamp();
  |         timestampChar = %char(%timestamp(TS):*ISO);
  |         exsr timeSr;
  |         exsr externalCrtUpd;
  |       yajl_endObj();
  |
AR050     plstpordr = unord#;
  |       plstpdisp = undisp;
  |       plstpunit = ununit;
  |       plstpdrv1 = undr1;
  |       plstpdrv2 = undr2;
  |       plstpnumb = seq;
  |       plstpcust = *blanks;
  |       plstpname = name;
  |       plstplatd = latitude#;
  |       plstplond = longitude# * -1;
  |       plstpdate = smhdate;
  |       plstptime = smhtime;
AR050     write rplwrkstp;
AR054   endif;

AR010   endsr;

        //-----------------------------------------------------
        //--find route from Expert Fuel  ------------
        //-----------------------------------------------------
        begsr findRouteId;

AR046     setgt  (ununit:unord#:undisp:'R') contactps;
  |       readpe (ununit:unord#:undisp:'R') contactps;
  |       if not %eof(contactps);
  |         ixdate = cndate;
  |         ixtime = cntime;
  |       else;
  |         ixdate = didate;
  |         ixtime = ditime;
AR046     endif;

          navon = *off;
          ef2truck = mhunit;
DR010     //if navOnDrv = *on;
DR010     if navOnDrv = *on Or fuelOnDrv;
AR041       clear dispDate;
  |         clear w_grgdat;
  |         //convert julian date to gregorian format.
  |         datCon(ixdate:w_grgdat);
  |         if w_grgdat > *blanks;
  |           diccyy = %subst(%char(ixdate):1:4);
  |           dimm   = %subst(w_grgdat:1:2);
  |           didd   = %subst(w_grgdat:3:2);
  |           dihh   = %subst(ixtime:1:2);
  |           dimin  = %subst(ixtime:3:2);
  |           dispDate = %timestamp(%char(dispUTC):*ISO);
AR041       endif;
            setgt ef2truck ef2reql2;
            readpe ef2truck ef2reql2;
            if %eof(ef2reql2) = *off;
DR041         //if rteChkOrd# = reqload;
AR041         if rteChkOrd# = reqload And reqDate >= dispDate;
                requestId = REQID#;
              endif;
            endif;
          endif;
          if navOnDrv = *on;
            navOn = *on;
          endif;
        endsr;

        //-----------------------------------------------------
        //--find route segments Expert Fuel  ------------
        //-----------------------------------------------------
        begsr findRouteSegments;

           foundSegment = *off;
DR016      //rteSequence = 0;
DR032      //setll (requestId:rteStop) ef2rtepPS;
DR032      //reade (requestId:rteStop) ef2rtepPS;
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

RD008        if rtemiles < 3;
  |          skipSeg = *on;
RD008        endif;

AR034        if savLatitude > *zero Or savLongitude > *zero;
  |            rteSequence += 1;
  |            yajl_beginObj();
  |              latitude#  = savLatitude  * .0001;
  |              longitude# = savLongitude * .0001;
  |              yajl_addNum('latitude':%char(latitude#));
  |              yajl_addNum('longitude':'-' + %char(longitude#));
  |              yajl_addChar('sequence':%char(rteSequence));
  |            yajl_endObj();
  |            clear savLatitude;
  |            clear savLongitude;
AR034        endif;

DR034          //if skipSeg= *off;
AR034          if skipSeg= *off Or rtePoint > *blanks;
RA016            rteSequence += 1;
RA016            foundSegment = *on;
  |              yajl_beginObj();
  |                latitude#  = rtebeglat * .0001;
  |                longitude# = rtebeglon * .0001;
  |                yajl_addNum('latitude':%char(latitude#));
  |                yajl_addNum('longitude':'-' + %char(longitude#));
  |                yajl_addChar('sequence':%char(rteSequence));
  |              yajl_endObj();
  |
AR032            //if Driver Fuel Stops enabled, split fuel location.
  |              if (fuelOnDrv and routeOnDrv and %equal(ef2Route)
  |                 And rteFuelNow = 'Y');
AR034              savLatitude  = rteendlat;
  |                savLongitude = rteendlon;
  |                rteSequence += 1;
  |                foundSegment = *on;
  |                yajl_beginObj();
  |                  latitude#  = lat * .0001;
  |                  longitude# = lon * .0001;
  |                  yajl_addNum('latitude':%char(latitude#));
  |                  yajl_addNum('longitude':'-' + %char(longitude#));
  |                  yajl_addChar('sequence':%char(rteSequence));
  |                yajl_endObj();
  |                reade (requestId:rteStop) ef2rtepPS;
AR034              leave;
AR032            endif;

AR035           if rteBegLat <> rteEndLat Or rteBegLon <> rteEndLon;
AR034            if rtePoint > *blanks And rteIntChg > *blanks;
  |                retocc = %scan(',':rteIntChg);
  |                if retocc > 0 And %subst(rteIntChg:1:1) > '0'
  |                                And %subst(rteIntChg:1:1) < '9';
  |                  bgn = retocc+1;
  |                  latitude# = %dec(%subst(rteIntChg:1:retocc-2):9:6);
  |                  retocc = %scan(',':rteIntChg);
  |                  if retocc > 0 And %subst(rteIntChg:1:1) > '0'
  |                                And %subst(rteIntChg:1:1) < '9';
  |                    longitude# = %dec(%subst(rteIntChg:bgn:retocc-2):9:6);
  |                  endif;
  |                else;
  |                  latitude#  = rteendlat * .0001;
  |                  longitude# = rteendlon * .0001;
  |                endif;
AR034            else;
  |                latitude#  = rteendlat * .0001;
  |                longitude# = rteendlon * .0001;
AR034            endif;
AR016            rteSequence += 1;
AR010            yajl_beginObj();
  |                yajl_addNum('latitude':%char(latitude#));
  |                yajl_addNum('longitude':'-' + %char(longitude#));
  |                yajl_addChar('sequence':%char(rteSequence));
  |              yajl_endObj();
AR035           endif;
AR010          endif;
             reade (requestId:rteStop) ef2rtepPS;
           enddo;
AR032      if %eof(ef2rtepPS);
  |          rteStop +=1;
AR034        clear savLatitude;
AR034        clear savLongitude;
  |          setll (requestId:rteStop) ef2rtepPS;
  |          reade (requestId:rteStop) ef2rtepPS;
AR032      endif;
        endsr;

        //-----------------------------------------------------
        //--add location stops deliveries ------------
        //-----------------------------------------------------
        begsr locationstopD;

AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);

AR054     if isDisabled;
AR054       dstla += 1;
AR054       seq   += 1;
AR054     endif;

AR010     clear dstZip;
  |       clear dstLat;
  |       clear dstLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
AR033      if sostp# < 90;
  |         dstla = seq -1;
AR033      endif;
  |         dstZip = zip;
  |         dstLat = lat;
  |         dstLon = lon;
AR010     endif;

AR026     if dstaddr = *blanks;
  |         dstaddr = 'NO ADDRESS PROVIDED';
  |       endif;
  |
  |       clear country;
  |       if dstst > *blanks;
  |         chain dstst ftstate;
  |         if %found(ftstate);
  |           select;
  |           when fsCnty = 'CAN';
  |             country = 'CN';
  |           when fsCnty = 'MEX';
  |             country = 'MX';
  |           when fsCnty = 'USA';
  |             country = 'US';
  |           endsl;
  |         endif;
AR026     endif;

          yajl_beginObj();
AR014       if dstla < 90;
              yajl_addNum('id':%char(dstla+1));
AR014       else;
AR014         yajl_addNum('id':%char(dstla));
AR014       endif;
            yajl_addChar('external_id':%trim(JobID) +
CR052                    '-'+ %trim(dstcust) + '-' + %trim(dstcty));
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
DR025         //chain cust#  mccstllp;
DR025         //if %found(mccstllp) = *on;
AR025         if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
                yajl_addNum('latitude':%char(C#DECLATD));
                yajl_addNum('longitude':%char(C#DECLOND));
AR025         elseif %found(citypsl0);
  |             dstLat = (CiLat/3600);
  |             dstLon = (CiLong/3600);
  |             yajl_addNum('latitude':%char(dstLat));
  |             yajl_addNum('longitude':'-' + %char(dstLon));
  |           endif;
  |         else;
  |           latitude#  = dstLat * .0001;
  |           longitude# = dstLon * .0001;
  |           yajl_addNum('latitude':%char(latitude#));
  |           yajl_addNum('longitude':'-' + %char(longitude#));
AR025       endif;

            //exsr hours;
            exsr externalcrtupd;
          yajl_endObj();

AR050     plstpordr = unord#;
  |       plstpdisp = undisp;
  |       plstpunit = ununit;
  |       plstpdrv1 = undr1;
  |       plstpdrv2 = undr2;
  |       if dstla < 90;
  |         plstpnumb = dstla+1;
  |       else;
  |         plstpnumb = dstla;
  |       endif;
  |       plstpcust = cust#;
  |       plstpname = dstcust;
AR025     if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |         plstplatd = c#declatd;
  |         plstplond = c#declond;
AR025     elseif %found(citypsl0) And dstlat >0 And dstlon <0;
  |         plstplatd = dstlat;
  |         plstplond = dstlon;
AR025     else;
  |         plstplatd = latitude#;
  |         plstplond = longitude# * -1;
AR025     endif;
  |       plstpdate = smhdate;
  |       plstptime = smhtime;
AR050     write rplwrkstp;
AR054   endif;

        endsr;

        //-----------------------------------------------------
        //--write load origin location  --------------
        //-----------------------------------------------------
AR010   begsr locationStopO;
  |
  |       if (orgla = 00 or orgla = 01) And
  |          (fstPuDt > *blanks Or fstPuDt1 > *blanks);
  |         orgPuDt  = fstPuDt;
  |         orgPuTm  = fstPuTm;
  |         orgPuDt1 = fstPuDt1;
  |         orgPuTm1 = fstPuTm1;
  |       endif;
  |
  |       clear orgZip;
  |       clear orgLat;
  |       clear orgLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         orgla = seq - 1;
  |         orgZip = zip;
  |         orgLat = lat;
  |         orgLon = lon;
  |       endif;
  |
AR010     yajl_beginObj();
  |         yajl_addNum('id':%char(orgla +1));
  |         yajl_addChar('external_id':%trim(JobID) +
CR052                    '-'+ %trim(orgcust) + '-' + %trim(orgcty));
  |         yajl_addChar('type':'job');
  |         yajl_addChar('name':%trim(orgcust));
  |
  |         if orgaddr = *blanks;
  |           orgaddr = 'NO ADDRESS PROVIDED';
  |         endif;
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
  |           clear checkname;
  |           clear checkadr;
  |           clear checkcty;
  |           clear checkst;
  |           checkname = orgcust;
  |           checkadr  = orgaddr;
  |           checkcty  = orgcty;
  |           checkst   = orgst;
  |           exsr getCust#;
DR025         //chain cust#  mccstllp;
DR025         //if %found(mccstllp) = *on;
AR025         if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |             yajl_addNum('latitude':%char(C#DECLATD));
  |             yajl_addNum('longitude':%char(C#DECLOND));
  |           elseif %found(citypsl0);
  |             orgLat = (CiLat/3600);
  |             orgLon = (CiLong/3600);
  |             yajl_addNum('latitude':%char(orgLat));
  |             yajl_addNum('longitude':'-' + %char(orgLon));
  |           endif;
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
  |
  |       plstpordr = unord#;
  |       plstpdisp = undisp;
  |       plstpunit = ununit;
  |       plstpdrv1 = undr1;
  |       plstpdrv2 = undr2;
  |       plstpnumb = orgla+1;
  |       plstpcust = cust#;
  |       plstpname = orgcust;
AR025     if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |         plstplatd = c#declatd;
  |         plstplond = c#declond;
AR025     elseif %found(citypsl0) And orglat >0 And orglon <0;
  |         plstplatd = orglat;
  |         plstplond = orglon;
AR025     else;
  |         plstplatd = latitude#;
  |         plstplond = longitude# * -1;
AR025     endif;
  |       plstpdate = smhdate;
  |       plstptime = smhtime;
AR050     write rplwrkstp;
AR010   endsr;

        //-----------------------------------------------------
        //--write load relay location  --------------
        //-----------------------------------------------------
AR054   begsr locationRelay;

AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);
  |
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         rlyla = seq;
  |       else;
  |         rlyla = soStp#;
  |       endif;
  |
  |       chain tpCust custmast;
  |       if %found(custmast);
  |         chain (tpSt:tpCity) cities;
  |         if %found(cities);
  |           ciname = %xlate(lower:upper:ciname);
  |
  |           isDisabled = *on;
  |
  |           yajl_beginObj();
  |             yajl_addNum('id':%char(rlyla));
  |             yajl_addChar('external_id':%trim(JobID) +
  |                          '-'+ %trim(cuname) + '-' + %trim(ciname));
  |             yajl_addChar('type':'job');
  |             yajl_addChar('name':%trim(cuname));
  |
  |             if cubad1 = *blanks;
  |               cubad1 = 'NO ADDRESS PROVIDED';
  |             endif;
  |
  |             clear country;
  |             if tpst > *blanks;
  |               chain tpst ftstate;
  |               if %found(ftstate);
  |                 select;
  |                 when fsCnty = 'CAN';
  |                   country = 'CN';
  |                 when fsCnty = 'MEX';
  |                   country = 'MX';
  |                 when fsCnty = 'USA';
  |                   country = 'US';
  |                 endsl;
  |               endif;
  |             endif;
  |
  |             yajl_addChar('address':%trim(cubad1));
  |             yajl_addChar('city':%trim(ciname));
  |             yajl_addChar('state':%trim(tpst));
  |             yajl_addChar('postal_code':%trim(cizip1));
  |             yajl_addChar('country_code':%trim(country));
  |             yajl_addChar('time_zone':'');
  |
  |             clear checkname;
  |             clear checkadr;
  |             clear checkcty;
  |             clear checkst;
  |             checkname = cuname;
  |             checkadr  = cubad1;
  |             checkcty  = ciname;
  |             checkst   = tpst;
  |             exsr getCust#;
  |             if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |               yajl_addNum('latitude':%char(C#DECLATD));
  |               yajl_addNum('longitude':%char(C#DECLOND));
  |             elseif %found(citypsl0);
  |               orgLat = (CiLat/3600);
  |               orgLon = (CiLong/3600);
  |               yajl_addNum('latitude':%char(orgLat));
  |               yajl_addNum('longitude':'-' + %char(orgLon));
  |             endif;
  |
  |             //exsr hours;
  |             TS = %timestamp();
  |             timestampChar = %char(%timestamp(TS):*ISO);
  |             exsr timeSr;
  |             exsr externalCrtUpd;
  |           yajl_endObj();
  |
  |           plstpordr = unord#;
  |           plstpdisp = undisp;
  |           plstpunit = ununit;
  |           plstpdrv1 = undr1;
  |           plstpdrv2 = undr2;
  |           plstpnumb = plannedStp# + 1;
  |           plstpcust = cust#;
  |           plstpname = cuname;
  |           if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |             plstplatd = c#declatd;
  |             plstplond = c#declond;
  |           elseif %found(citypsl0) And orglat >0 And orglon <0;
  |             plstplatd = orglat;
  |             plstplond = orglon;
  |           else;
  |             plstplatd = latitude#;
  |             plstplond = longitude# * -1;
  |           endif;
  |           plstpdate = smhdate;
  |           plstptime = smhtime;
  |           write rplwrkstp;
  |         endif;
  |       endif;
AR054   endif;

AR054   endsr;

        //-----------------------------------------------------
        //--add location stops pickups ------------
        //-----------------------------------------------------
        begsr locationStop;

AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);

AR054     if isDisabled;
AR054       stpla += 1;
AR054       seq   += 1;
AR054     endif;

AR010     clear stpZip;
  |       clear stpLat;
  |       clear stpLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         stpla = seq - 1;
  |         stpZip = zip;
  |         stpLat = lat;
  |         stpLon = lon;
AR010     endif;

AR026     if stpaddr = *blanks;
  |         stpaddr = 'NO ADDRESS PROVIDED';
AR026     endif;
  |
  |       clear country;
  |       if stpst > *blanks;
  |         chain stpst ftstate;
  |         if %found(ftstate);
  |           select;
  |           when fsCnty = 'CAN';
  |             country = 'CN';
  |           when fsCnty = 'MEX';
  |             country = 'MX';
  |           when fsCnty = 'USA';
  |             country = 'US';
  |           endsl;
  |         endif;
AR010     endif;

          yajl_beginObj();
            yajl_addNum('id':%char(stpla+1));
            yajl_addChar('external_id':%trim(JobID) +
CR052                    '-'+ %trim(stpcust) + '-' + %trim(stpcty));
            yajl_addChar('type':'job');
            yajl_addChar('name':%trim(stpcust));
            yajl_addChar('address':%trim(stpaddr));
            yajl_addChar('city':%trim(stpcty));
            yajl_addChar('state':%trim(stpst));
            yajl_addChar('postal_code':%trim(stpZip));
            yajl_addChar('country_code':%trim(country));
            yajl_addChar('time_zone':'');

AR025       if stpLat = *zeros and stpLon = *zeros;
  |           clear checkname;
  |           clear checkadr;
  |           clear checkcty;
  |           clear checkst;
  |           checkname = stpcust;
  |           checkadr  = stpaddr;
  |           checkcty  = stpcty;
  |           checkst   = stpst;
  |           exsr getcust#;
DR025         //chain cust#  mccstllp;
DR025         //if %found(mccstllp) = *on;
AR025         if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |             yajl_addNum('latitude':%char(C#DECLATD));
  |             yajl_addNum('longitude':%char(C#DECLOND));
  |           elseif %found(citypsl0);
  |             stpLat = (CiLat/3600);
  |             stpLon = (CiLong/3600);
  |             yajl_addNum('latitude':%char(stpLat));
AR025           yajl_addNum('longitude':'-' + %char(stpLon));
              endif;
AR025       else;
  |           latitude#  = stpLat * .0001;
  |           longitude# = stpLon * .0001;
  |           yajl_addNum('latitude':%char(latitude#));
  |           yajl_addNum('longitude':'-' + %char(longitude#));
AR025       endif;

            //exsr hours;
            exsr externalcrtupd;
          yajl_endObj();

AR050     plstpordr = unord#;
  |       plstpdisp = undisp;
  |       plstpunit = ununit;
  |       plstpdrv1 = undr1;
  |       plstpdrv2 = undr2;
  |       plstpnumb = stpla;
  |       plstpcust = cust#;
  |       plstpname = stpcust;
AR025     if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |         plstplatd = c#declatd;
  |         plstplond = c#declond;
AR025     elseif %found(citypsl0) And stplat >0 And stplon <0;
  |         plstplatd = stplat;
  |         plstplond = stplon;
AR025     else;
  |         plstplatd = latitude#;
  |         plstplond = longitude# * -1;
AR025     endif;
  |       plstpdate = smhdate;
  |       plstptime = smhtime;
AR050     write rplwrkstp;
AR054   endif;

        endsr;

         //-----------------------------------------------------
         //--load header information to display to driver----
         //-----------------------------------------------------
         begsr loadheaderinfo;

          yajl_beginArray('customers');
          yajl_endArray();

          yajl_beginArray('external_data');

            yajl_beginObj();
              yajl_addChar('label':'Trailers');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
CR021         yajl_addChar('label':'Current Trailer');
              yajl_addChar('value':%trim(ditrlr));
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
AR021         yajl_addChar('label':'Pickup Trailer');
AR021         if orgtrl <> *blanks and orgtrl <> ditrlr;
                yajl_addChar('value':%trim(orgtrl));
              else;
                yajl_addChar('value':'');
              endif;
              yajl_addNum('order':'30');
              yajl_addBool('isLabel':'0');
            yajl_endObj();

            yajl_beginObj();
              yajl_addChar('label':'Shipping Documents');
              yajl_addChar('value':'');
              yajl_addNum('order':'1000');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Bill Of Lading');
              if orcsh# <> *blanks;
                yajl_addChar('value':%trim(orcsh#));
              else;
                yajl_addChar('value':'NA');
              endif;
              yajl_addNum('order':'2000');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Seal #');
              if orsel1 <> *blanks;
                yajl_addChar('value':%trim(orsel1));
              else;
                yajl_addChar('value':'NA');
              endif;
              yajl_addNum('order':'3000');
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
              yajl_addNum('order':'200');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Live UnLoad/Drop');
              if orduld = 'Y';
                yajl_addChar('value':'Live Unload');
              else;
                yajl_addChar('value':'Drop');
              endif;
              yajl_addNum('order':'300');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

AR071       yajl_beginObj();
  |           yajl_addChar('label':'Consignee Code');
  |           yajl_addChar('value':%trim(orcons));
  |           yajl_addNum('order':'400');
  |           yajl_addBool('isLabel':'0');
  |           yajl_addBool('isHidden':'1');
AR071       yajl_EndObj();

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
  |         //check for EF fuel & route
  |         setll (requestID:unord#:undisp) ef2Route;
AR057       setll (unord#:undisp) ordRoutep;
AR057       if %equal(ef2Route)
AR057          And %equal(ordRoutep);
  |           yajl_beginArray('steps');
  |             x = 1;
AR044           y = 1;
AR044           z = 1;
AR054           clear v#;
AR054           clear soStp#;
AR054           clear isDisabled;
AR044           dou %eof(ef2Route);
  |               reade (requestId:unord#:undisp) ef2Route;
  |               //only process stop and fuel locations
  |               if not %eof(ef2Route) And seq > *zero;
AR044               if stoptype = 'S';
AR054                 v# += 1;
  |                   //process pickup & drop stopoffs
AR057                 reade (unord#:undisp) ordRoutep;
AR057                 if not %eof(ordRoutep) And ouSeq# > *zero;
  |                     chain (ouOdr#:ouStp#) stopoff;
  |                     if %found(stopoff);
  |                       ouStpTyp = sotype;
  |                     endif;
AR043                   cubZip = ouZip;
AR043                   soStp# = ouStp#;
AR044                   soType = ouStpTyp;
AR054                   if (plannedRelay or planToRelay) And
AR054                     soStp# > plannedStp# And not isDisabled;
AR054                     exsr AddRelayStop;
AR054                   endif;
AR044                   select;
  |                     //write corresponding location
  |                     when soStp# = 01 Or (soStp# = 00 and ouSeq# = 1);
  |                       //seq = 01;
  |                       exsr addOrigin;
  |                     when soStp# > 01 and soStp# < 90;
  |                       if messageA42(y) > *blanks And soType = 'P'
AR044                        And %int(%subst(messageA42(y+1):4:2)) = soStp#-1;
  |                         exsr loadPick;
  |                         exsr addStop;
  |                       elseif messageA41(x) > *blanks And soType = 'D'
AR044                        And %int(%subst(messageA41(x+1):4:2)) = soStp#-1;
  |                         exsr loadDest;
  |                         exsr addStopD;
  |                       elseif messageA48(z+1) > *blanks And soType = 'P'
AR044                        And %int(%subst(messageA48(z+1):4:2)) = soStp#-1;
  |                         exsr loadPick48;
  |                         exsr addStop;
  |                       elseif messageA48(z+1) > *blanks And soType = 'D'
AR044                        And %int(%subst(messageA48(z+1):4:2)) = soStp#-1;
  |                         exsr loadDest48;
  |                         exsr addStopD;
  |                       endif;
  |                     when soStp# = 90;
  |                       //seq = 90;
  |                       dow messageA41(x) > *blanks;
  |                         exsr loadDest;
  |                         exsr addStopD;
  |                       enddo;
  |                     endsl;
AR057                 endif;
  |                 //write fuel stop locations
  |                 elseif stoptype = 'F';
AR054                 if (plannedRelay or planToRelay)
AR054                    And isDisabled = *off And soStp# >= plannedStp#
AR054                    And soSt > *blanks And soCtyc > *blanks
AR054                    And ciSt > *blanks And ciCty > *blanks;
AR054                   clear mileds;
AR054                   mdcty1 = soCtyc + soSt;
AR054                   mdcty2 = ciCty  + ciSt;
AR054                   mditf = 'N';
AR054                   mdreqt = 'M';
AR054                   mdnmfl = lcmtyp;
AR054                   callp rtMiles(mileds);
AR054                   tmile = mdhgm;
AR054                   clear mileds;
AR054                   mdcty1 = soCtyc + soSt;
AR054                   mdcty2 = tpCity + tpSt;
AR054                   mditf = 'N';
AR054                   mdreqt = 'M';
AR054                   mdnmfl = lcmtyp;
AR054                   callp rtMiles(mileds);
AR054                   if mdhgm < tmile;
AR054                     exsr addRelayStop;
AR054                   endif;
AR054                 endif;
  |                   soStp# = 00;
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
              //seq = 01;
              exsr addOrigin;

              y = 1;
              dow messageA42(y) <> *blanks And y <= 40;
                exsr loadpick;
                exsr addStop;
              enddo;

AR044         z = 1;
  |           dow messageA48(z+1) <> *blanks And z <= 40;
  |             if %subst(messageA48(z+2):7:7) = 'PICK UP';
  |               exsr loadPick48;
  |               exsr addStop;
  |             elseif %subst(messageA48(z+2):7:7) = 'DROPOFF';
  |               exsr loadDest48;
  |               exsr addStopD;
  |             endif;
AR044         enddo;

              x = 1;
              dow messageA41(x) <> *blanks And x <= 989;
                exsr loaddest;
                exsr addStopD;
              enddo;

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
  |           setll unord# rtestopl1;
  |           firstRouteOnDrv = *on;
AR009       endif;

AR005       dou %eof(rteStopl1);
  |           reade unord# rteStopl1;
  |           if not %eof(rteStopl1) and sostp# > *zero
  |              and socust = cust# and sotype = checkType;
  |             leave;
  |           endif;
AR005       enddo;

AR005       if %eof(rteStopl1);
  |           clear soeda;
AR005         clear soeta;
DR007         //clear sostp#;
DR009         //clear oustp#;
DR014         //oustp# = checkla;
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
                  latitude#  = geoLat * .0001;
                  longitude# = geoLon * .0001;
                  yajl_addNum('latitude':%char(latitude#));
                  yajl_addNum('longitude':'-' + %char(longitude#));
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
  |           yajl_addNum('radius':'250');
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
        //
        //-----------------------------------------------
AR054   begsr addRelayGeofence;
  |
  |       yajl_beginObj('geofence');
  |         yajl_beginObj('circle');
  |           yajl_beginObj('center');
  |             yajl_addNum('latitude':%char(C#DECLATD));
  |             yajl_addNum('longitude':%char(C#DECLOND));
  |           yajl_endObj();
  |           yajl_addNum('radius':'250');
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
  |           yajl_addChar('message':'You have Departed!');
  |         endif;
  |       yajl_endObj();
AR010   endsr;

        //-----------------------------------------------
        //      addorigin;
        //-----------------------------------------------
        begsr addorigin;

AR010     clear orgZip;
  |       clear orgLat;
  |       clear orgLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         orgla = seq - 1;
  |         orgZip = zip;
  |         orgLat = lat;
  |         orgLon = lon;
  |       endif;
AR010
          yajl_beginObj();
            yajl_addChar('id':%char(orgla +1));
            yajl_addChar('external_id':%trim(JobId) +
                         '-'+ %char(orgla +1));
            yajl_addChar('name':%trim(orgcust));
            yajl_addBool('completed':'0');
            yajl_addChar('completed_at':'');
            yajl_addChar('type':%trim(orgtype));
            yajl_addNum('order':%char(orgla +1));
            yajl_addChar('location_external_id':%trim(JobId) +
CR052                    '-'+ %trim(orgcust) + '-' + %trim(orgcty));
            yajl_addChar('customer_external_id':%trim(JobId) +
CR052                    '-'+ %trim(orgcust) + '-' + %trim(orgcty));
            if NavOn = *on;
              yajl_addChar('route_leg_external_id':%trim(JobID) +
CR052                      '-'+ %trim(orgcust) + '-' + %trim(orgcty));
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

AR011         if soeda > *zero And soeta > *zero;
                dateconv = soeda;
                timeconv = soeta;
                exsr Convert_Dt;
                exsr timeSr;
                yajl_addChar('eta':UTCFormat);
AR011         endif;

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
DR020             yajl_addBool('is_required':'1');
AR020           //yajl_addBool('is_required':'0');
                  geoarrive = *on;
                  autocomplete = *on;
                  geoLat = orgLat;
                  geoLon = orgLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
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
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

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
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();
            yajl_endArray();
          yajl_endObj();
        endsr;

        //-----------------------------------------------
        //--use stop customer code to match name on stop
        //-----------------------------------------------
        begsr getcust#;

          clear cust#;
DR025     //chain (checkname:checkadr:checkcty:checkst) custpp;
DR025     //if %found(custmaspp) = *on;
AR025     setll (checkname:checkadr:checkcty:checkst) custmaspp;
AR025     dou %eof(custmaspp) Or
AR025        (%found(mccstllp) And (c#decLatd > 0 and c#decLond < 0));
AR025       reade (checkname:checkadr:checkcty:checkst) custmaspp;
AR025       if not %eof(custmaspp);
AR025         chain cucode mccstllp;
AR025       endif;
AR025     enddo;
AR025     if not %eof(custmaspp);
            cust# = cucode;
AR026     else;
CR069       chain PLTSCI mccstllp;
AR025     endif;
          //derive timezone for setting gmt offset
AR025     chain (checkSt:CheckCty) citypsl0;
AR025     if not %found(citypsl0);
AR025       chain (checkSt:CheckCty) citypsl1;
AR025       if %found(citypsl1);
AR025         chain (cist:ciname) citypsl0;
AR025       endif;
AR025     endif;
AR068     if not %found(citypsl0);
AR068       chain (cubst:cubctc) cities;
AR068       if %found(cities);
AR068         ciname = %xlate(lower:upper:ciname);
AR068         chain (ciSt:ciName) citypsl0;
AR068       endif;
AR068     endif;
AR025       if %found(citypsl0);
              select;
              when citime = '01';
DR028           //custTZ = '10'; dst
AR028           evalr custTZ = %char(%int(offset) +4);
              when citime = '02';
DR028           //custTZ = '09'; dst
AR028           evalr custTZ = %char(%int(offset) +3);
              when citime = '03';
DR028           //custTZ = '08'; dst
AR028           evalr custTZ = %char(%int(offset) +2);
              when citime = '04';
DR028           //custTZ = '07'; dst
AR028           evalr custTZ = %char(%int(offset) +1);
              when citime = '05';
DR028           //custTZ = '06'; dst=6; else=7
AR028           custTZ = offset;
              when citime = '06';
DR028           //custTZ = '05'; dst
AR028           evalr custTZ = %char(%int(offset) -1);
              when citime = '07';
DR028           //custTZ = '04'; dst
AR028           evalr custTZ = %char(%int(offset) -2);
              when citime = '08';
DR028           //custTZ = '03'; dst
AR028           evalr custTZ = %char(%int(offset) -3);
              when citime = '09';
DR028           //custTZ = '02'; dst
AR028           evalr custTZ = %char(%int(offset) -4);
              other;
AR005           //default to EPTX timezone on unknown.
DR028           //custTZ = '06'; (dst=6; else=7)
AR028           custTZ = offset;
              endsl;
AR055         if ciday = 'N';
AR055           //need to corral DST to time periods.
AR055           evalr custTZ = %char(%int(custTZ) +1);
AR055         endif;
AR005       else;
  |           //default to EPTX timezone on error.
DR028         //custTZ = '06';  (dst=6; else=7)
AR028         custTZ = offset;
AR005       endif;
DR025     //endif;
AR028       custTZ = %xlate(' ':'0':custTZ);

DR025     //if cust# = *blanks;
  |         //need to get t-call location
  |         //cust# = 'MVTEP';
AR005       //custTZ = '06';
DR025     //endif;
        endsr;

        //-----------------------------------------------
        //      addStop;
        //-----------------------------------------------
        begsr addStop;

AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);

AR054     if isDisabled;
AR054       stpla += 1;
AR054       seq   += 1;
AR054     endif;

AR010     clear stpZip;
  |       clear stpLat;
  |       clear stpLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
  |         stpla = seq - 1;
  |         stpZip = zip;
  |         stpLat = lat;
  |         stpLon = lon;
  |       endif;
AR010
          yajl_beginObj();
            yajl_addNum('id':%char(stpla+1));
            yajl_addChar('external_id':%trim(JobId) +
                         '-'+ %char(stpla+1));
            yajl_addChar('name':%trim(stpcust));
AR054       if isDisabled;
AR054         yajl_addChar('is_disabled':'1');
AR054       endif;
            yajl_addBool('completed':'0');
            yajl_addChar('completed_at':'');
            yajl_addChar('type':%trim(stptype));
            yajl_addNum('order':%char(stpla+1));
            yajl_addChar('location_external_id':%trim(JobId) +
CR052                    '-'+ %trim(stpcust) + '-' + %trim(stpcty));
            yajl_addChar('customer_external_id':%trim(JobId) +
CR052                    '-'+ %trim(stpcust) + '-' + %trim(stpcty));
            if NavOn = *on;
              yajl_addChar('route_leg_external_id':%trim(JobID) +
CR052                      '-'+ %trim(stpcust) + '-' + %trim(stpcty));
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
AR014         if stptype = 'PICK UP';
  |             checktype = 'P';
  |           else;
  |             checktype = 'D';
AR014         endif;
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

              if stppudt1<> *blanks;
                if stppudm1< curmonth;
                  curyear = curyear +1;
                endif;
                ccyy = %char(curyear);
                mm   = %editc(stppudm1:'X');
                dd   = %editc(stppudd1:'X');
                hh   = %editc(stppuh1:'X');
                min  = %editc(stppum1:'X');
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
DR020             yajl_addBool('is_required':'1');
AR020           //yajl_addBool('is_required':'0');
                  geoarrive = *on ;
                  autocomplete = *on;
                  geoLat = stpLat;
                  geoLon = stpLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
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
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

              //new task
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
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();
            yajl_endArray();
          yajl_endObj();
AR054   endif;

        endsr;

        //-----------------------------------------------
        // add relay stop location   --------------------
        //-----------------------------------------------
AR054   begsr addRelayStop;
  |
  |     if not(plannedRelay) Or plannedRelay And not(isDisabled);
  |
  |       chain tpCust custmast;
  |       if %found(custmast);
DR025       chain tpCust mccstllp;
AR025       if %found(mccstllp) And c#DecLatd >0 And c#DecLond <0;
  |           chain (tpSt:tpCity) cities;
  |         if %found(cities);
  |           ciname = %xlate(lower:upper:ciname);
  |
  |           isDisabled = *on;
  |
  |           //if Load Route exists, use route stop sequence.
  |           if routeOnDrv;
  |             rlyla = seq;
  |           else;
  |             rlyla = soStp#;
  |           endif;
  |
  |           yajl_beginObj();
  |             yajl_addNum('id':%char(rlyla));
  |             yajl_addChar('external_id':%trim(JobId) +
  |                          '-'+ %char(rlyla));
  |             yajl_addChar('name':%trim(cuname));
  |             yajl_addChar('type':'T-CALL');
  |             yajl_addBool('completed':'0');
  |             yajl_addChar('completed_at':'');
  |             yajl_addNum('order':%char(rlyla));
  |             yajl_addChar('location_external_id':%trim(JobId) +
  |                          '-'+ %trim(cuname) + '-' + %trim(ciname));
  |             yajl_addChar('customer_external_id':%trim(JobId) +
  |                          '-'+ %trim(cuname) + '-' + %trim(ciname));
  |             if NavOn = *on;
  |               yajl_addChar('route_leg_external_id':%trim(JobID) +
  |                          '-'+ %trim(cuname) + '-' + %trim(ciname));
  |             endif;
  |
  |             exsr externalStopR;  // relay details tab
  |             yajl_beginObj('appointment');
  |
  |               clear w_grgdat;
  |               datCon(tpdate:w_grgdat);
  |               if w_grgdat <> *blanks And w_grgdat <> *zeros;
  |                 ccyy = %subst(%char(tpdate):1:4);
  |                 mm   = %subst(w_grgdat:1:2);
  |                 dd   = %subst(w_grgdat:3:2);
AR058               monitor;
  |                   hh   = %subst(%char(tptime):1:2);
AR058               on-error;
AR058                 hh   = '00';
AR058               endmon;
AR058               monitor;
  |                   min  = %subst(%char(tptime):3:2);
AR058               on-error;
AR058                 min  = '00';
AR058               endmon;
  |                 UTCEndHH = custTZ;
  |                 sec = '00';
  |                 timestampChar = timeUTC;
  |                 exsr timeSrNoUTC1;
  |                 UTCEndHH = offset;
  |               else;
  |                 TS = %timestamp();
  |                 timestampChar = %char(%timestamp(TS):*ISO);
  |                 exsr timeSr;
  |               endif;
  |               yajl_addChar('start_time':UTCFormat);
  |               //yajl_addChar('end_time':UTCFormat);
  |             yajl_endObj();
  |             //yajl_addChar('eta':UTCFormat);
  |
  |             TS = %timestamp();
  |             timestampChar = %char(%timestamp(TS):*ISO);
  |             exsr timeSr;
  |             yajl_addChar('created_at':UTCFormat);
  |             yajl_addChar('updated_at':UTCFormat);
  |
  |             yajl_beginArray('tasks');
  |               yajl_beginObj();
  |                 orderBy = orderBy + 1;
  |                 yajl_addNum('id':%char(orderBy));
  |                 yajl_addChar('external_id':%trim(JobID)
  |                               +'-'+ %char(orderBy));
  |
  |                 yajl_addChar('name':'Arrived at T-Call');
  |                 yajl_addChar('order':%char(orderBy));
  |                 yajl_addChar('type':'arrivedRelay');
  |                 yajl_addBool('completed':'0');
  |                 TS = %timestamp();
  |                 timestampChar = %char(%timestamp(TS):*ISO);
  |                 exsr timeSr;
  |                 yajl_addChar('created_at':UTCFormat);
  |                 yajl_addChar('updated_at':UTCFormat);
  |
  |                 yajl_beginObj('external_data');
  |                   yajl_addBool('is_prompt_repeats':'0');
  |                   yajl_addBool('is_allow_repeats':'0');
  |                   geoarrive = *on;
  |                   autocomplete = *on;
  |                   yajl_addBool('is_required':'1');
  |                   exsr addRelayGeofence;
  |                 yajl_endObj();
  |                 yajl_beginObj('fields');
  |                   svstp# = 00;
  |                   exsr addInfo;
  |                 yajl_endObj();
  |               yajl_endObj();
  |
  |               yajl_beginObj();
  |                 orderBy = orderBy + 1;
  |                 yajl_addNum('id':%char(orderBy));
  |                 yajl_addChar('external_id':%trim(JobID)
  |                               +'-'+ %char(orderBy));
  |                 yajl_addChar('name':'T-Call Drop');
  |                 yajl_addChar('order':%char(orderBy));
  |                 yajl_addChar('type':'tCall');
  |                 yajl_addBool('completed':'0');
  |                 TS = %timestamp();
  |                 timestampChar = %char(%timestamp(TS):*ISO);
  |                 exsr timeSr;
  |                 yajl_addChar('created_at':UTCFormat);
  |                 yajl_addChar('updated_at':UTCFormat);
  |
  |                 yajl_beginObj('external_data');
  |                   yajl_addBool('is_prompt_repeats':'0');
  |                   yajl_addBool('is_allow_repeats':'1');
  |                   geoarrive = *off;
  |                   autocomplete = *off;
  |                   yajl_addBool('is_required':'1');
  |                   //exsr addRelayGeofence;
  |                 yajl_endObj();
  |                 yajl_beginObj('fields');
  |                   svstp# = 00;
  |                   exsr addInfo;
  |                 yajl_endObj();
  |               yajl_endObj();
  |
  |               yajl_beginObj();
  |                 orderBy = orderBy + 1;
  |                 yajl_addNum('id':%char(orderBy));
  |                 yajl_addChar('external_id':%trim(JobID)
  |                               +'-'+ %char(orderBy));
  |
  |                 yajl_addChar('name':'Depart from T-Call');
  |                 yajl_addChar('order':%char(orderBy));
  |                 yajl_addChar('type':'departRelay');
  |                 yajl_addBool('completed':'0');
  |                 TS = %timestamp();
  |                 timestampChar = %char(%timestamp(TS):*ISO);
  |                 exsr timeSr;
  |                 yajl_addChar('created_at':UTCFormat);
  |                 yajl_addChar('updated_at':UTCFormat);
  |
  |                 yajl_beginObj('external_data');
  |                   yajl_addBool('is_prompt_repeats':'0');
  |                   yajl_addBool('is_allow_repeats':'0');
  |                   geoarrive = *off;
  |                   autocomplete = *on;
  |                   yajl_addBool('is_required':'1');
  |                   exsr addRelayGeofence;
  |                 yajl_endObj();
  |                 yajl_beginObj('fields');
  |                   svstp# = 00;
  |                   exsr addInfo;
  |                 yajl_endObj();
  |               yajl_endObj();
  |             yajl_endArray();
  |           yajl_endObj();
  |         endif;
  |         endif;
  |       endif;
  |     endif;
  |
AR054   endsr;

        //-----------------------------------------------
        // add fuel stop location   ---------------------
        //-----------------------------------------------
AR010   begsr addFuelStop;

AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);
  |
AR054     wkcity = city;
  |       citySt = %subst(wkcity:1:15) + ',' + state;
  |       citySt = %xlate(' ':'_':citySt);
  |       clear w_purGal;
AR042     clear w_intChg;
DR038     //setgt (mhunit) mcmsgh;
AR038     setgt (smhunit) mcmsgh;
DR041     //dou %eof(mcmsgh) Or (mhdate = smhdate
DR041       //and mhtime < smhtime) Or (mhdate < smhdate)
DR041       //Or mhpmid = 'T00' and %subst(mdmsgs:1:9) = 'IDSC/FUEL';
AR041     dou %eof(mcmsgh) Or (mhdate = ixdate and mhtime <
AR041        %int(ixtime + '00')) Or (mhdate < ixdate)
AR041        Or mhpmid = 'T00' and %subst(mdmsgs:1:9) = 'IDSC/FUEL';
DR038       //readpe (mhunit) mcmsgh;
AR038       readpe (smhunit) mcmsgh;
  |         chain (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |       enddo;
  |       if not %eof(mcmsgh) And mhpmid = 'T00'
DR041        //And (mhdate > smhdate or
DR041        //     mhdate = smhdate and mhtime > smhtime)
AR041        And (mhdate > ixdate or mhdate = ixdate
AR041        and mhtime > %int(ixtime + '00'))
  |          And %subst(mdmsgs:1:9) = 'IDSC/FUEL';
  |         setll (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |         dou %eof(mcmsgd) Or %subst(mdmsgs:20:18)=citySt;
  |           reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |           if not %eof(mcmsgd) And %subst(mdmsgs:20:18)=citySt;
  |             reade (mhunit:mhdate:mhtime:mhdir) mcmsgd;
  |             if not %eof(mcmsgd);
AR042             w_intchg = %subst(mdmsgs:1:18);
  |               if %subst(mdmsgs:32:3) = 'QTY';
  |                 w_purGal = %subst(mdmsgs:35:3);
  |               elseif %subst(mdmsgs:33:4) = 'FILL';
  |                 w_purGal = %subst(mdmsgs:33:4);
  |               endif;
  |               leave;
  |             endif;
  |           endif;
  |         enddo;
  |       endif;
  |
AR054     if isDisabled;
AR054       seq   += 1;
AR054     endif;
  |
  |       yajl_beginObj();
  |         yajl_addNum('id':%char(seq));
  |         yajl_addChar('external_id':%trim(JobId) +
  |                      '-'+ %char(seq));
  |         yajl_addChar('name':%trim(name) +'/'+ w_intchg);
AR054       if isDisabled;
AR054         yajl_addChar('is_disabled':'1');
AR054       endif;
  |         yajl_addBool('completed':'0');
  |         yajl_addChar('completed_at':'');
  |         yajl_addChar('type':'FUEL');
  |         yajl_addNum('order':%char(seq));
  |         yajl_addChar('location_external_id':%trim(JobId)
  |                       +'-'+ %trim(name) +'/'+ %trim(w_intchg));
  |         yajl_addChar('customer_external_id':%trim(JobId)
  |                       +'-'+ %trim(name) +'/'+ %trim(w_intchg));
  |         if NavOn = *on;
  |           yajl_addChar('route_leg_external_id':%trim(JobID)
  |                     +'-'+ %trim(name) +'/'+ %trim(w_intchg));
  |         endif;
  |
  |         TS = %timestamp();
  |         timestampChar = %char(%timestamp(TS):*ISO);
  |         exsr timeSr;
  |         yajl_addChar('created_at':UTCFormat);
  |         yajl_addChar('updated_at':UTCFormat);
  |
CR022       yajl_beginArray('external_data');
  |           yajl_beginObj();
  |              //orderBy = orderBy + 1;
  |              yajl_addChar('label':'Fuel Stop Information');
  |              yajl_addChar('value':'');
  |              yajl_addNum('order':'150');
  |              yajl_addBool('isLabel':'1');
  |           yajl_EndObj();
  |
  |           yajl_beginObj();
  |              yajl_addChar('label':'Phone Number');
  |              yajl_addChar('value':%char(phone));
  |              yajl_addNum('order':'155');
  |              yajl_addBool('isLabel':'0');
  |            yajl_EndObj();
  |
  |           if w_purGal <> *blanks;
  |             yajl_beginObj();
  |                //orderBy = orderBy + 1;
  |                yajl_addChar('label':'Purchase Gallons');
  |                yajl_addChar('value':%char(w_purGal));
  |                yajl_addNum('order':'160');
  |                yajl_addBool('isLabel':'0');
  |              yajl_EndObj();
  |           endif;
CR022       yajl_EndArray();
  |
  |         yajl_beginArray('tasks');
  |           yajl_beginObj();
  |             orderBy = orderBy + 1;
  |             yajl_addNum('id':%char(orderBy));
  |             yajl_addChar('external_id':%trim(JobID)
  |                           +'-'+ %char(orderBy));
AR022           yajl_addChar('name':'Fuel Stop Gallons: '
AR022                               + %char(w_purGal));
DR022           //yajl_addChar('name':'Arrival At Fuel Stop');
CR022           yajl_addChar('order':%char(orderBy));
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
  |               geoarrive = *on;
AR036             if unown > *blanks;
AR036               autocomplete = *off;
AR036               yajl_addBool('is_required':'0');
AR036             else;
  |                 autocomplete = *on;
  |                 yajl_addBool('is_required':'1');
AR036             endif;
  |               exsr addFuelGeofence;
  |             yajl_endObj();
  |
  |             yajl_beginObj('fields');
AR031             svstp# = 00;
  |               exsr addInfo;
FUEL              yajl_addChar('fuelstopname':%trim(name));
FUEL              yajl_addNum('fuelstoplatitude':%char(latitude#));
FUEL              yajl_addNum('fuelstoplongitude':'-' + %char(longitude#));
FUEL              yajl_addChar('gallonstopurchase':%trim(w_purgal));
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
  |
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
AR031       //    svstp# = 00;
  |         //    exsr addInfo;
  |         //  yajl_endObj();
CR022       //yajl_endObj();
  |         yajl_endArray();
  |       yajl_endObj();
AR054   endif;

AR010   endsr;

        //-----------------------------------------------
        // addStopD;
        //-----------------------------------------------
        begsr addStopD;

AR054   if not(plannedRelay) Or plannedRelay And not(isDisabled);

AR054     if isDisabled;
AR054       seq += 1;
AR054       if soStp# < 90;
AR054         dstla += 1;
AR054       endif;
AR054     endif;

AR010     clear dstZip;
  |       clear dstLat;
  |       clear dstLon;
  |       //if Load Route exists, use route stop sequence.
  |       if routeOnDrv;
AR033      if sostp# < 90;
  |         dstla = seq - 1;
AR033      endif;
  |         dstZip = zip;
  |         dstLat = lat;
  |         dstLon = lon;
  |       endif;
AR010
          yajl_beginObj();
AR014       if dstla < 90;
              yajl_addNum('id':%char(dstla+1));
              yajl_addChar('external_id':%trim(JobId) +
                           '-'+ %char(dstla+1));
AR014       else;
AR014         yajl_addNum('id':%char(dstla));
AR014         yajl_addChar('external_id':%trim(JobId) +
AR014                      '-'+ %char(dstla));
AR014       endif;
            yajl_addChar('name':%trim(dstcust));
AR054       if isDisabled;
AR054         yajl_addChar('is_disabled':'1');
AR054       endif;
            yajl_addBool('completed':'0');
            yajl_addChar('completed_at':'');
            if dstla < 90;
              yajl_addChar('type':%trim(dsttype));
            else;
              yajl_addChar('type':'FINAL DELIVERY');
            endif;
AR014       if dstla < 90;
              yajl_addNum('order':%char(dstla+1));
AR014       else;
AR014         yajl_addNum('order':%char(dstla));
AR014       endif;
            yajl_addChar('location_external_id':%trim(JobId) +
CR052                    '-'+ %trim(dstcust) + '-' + %trim(dstcty));
            yajl_addChar('customer_external_id':%trim(JobId) +
CR052                    '-'+ %trim(dstcust) + '-' + %trim(dstcty));
            if NavOn = *on;
              yajl_addChar('route_leg_external_id':%trim(JobID) +
CR052                      '-'+ %trim(dstcust) + '-' + %trim(dstcty));
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
DR020             yajl_addBool('is_required':'1');
AR020           //yajl_addBool('is_required':'0');
                  geoarrive = *on ;
                  autocomplete = *on;
                  geoLat = dstLat;
                  geoLon = dstLon;
                  exsr addgeofence;
                yajl_endObj();

                yajl_beginObj('fields');
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
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
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();

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
AR059             if soArdt > *zero Or soLuDt > *zero;
AR059               svStp# = *zeros;
AR059             else;
AR056               svstp# = sostp#;
AR059             endif;
                  exsr addinfo;
                yajl_endObj();
              yajl_endObj();
            yajl_endArray();
          yajl_endObj();
AR054   endif;

        endsr;

        //---------------------------------------------------------------------
        //egsr addinfo;
        //-----------------------------------------------
        begsr addinfo;

          yajl_addChar('Unit':%trim(ununit));
          yajl_addChar('Driver1':%trim(undr1));
          yajl_addChar('Driver2':%trim(undr2));
DR007     //yajl_addChar('StopOffId':%char(sostp#));
AR007     yajl_addChar('StopOffId':%char(svstp#));
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

AR066       yajl_beginObj();
  |           yajl_addChar('label':'Shipper');
  |           yajl_addChar('value':shipName + shipLocn);
  |           yajl_addChar('order':'20');
  |           yajl_addBool('isLabel':'0');
  |         yajl_endObj();
  |
  |         yajl_beginObj();
  |           yajl_addChar('label':'Consignee');
  |           yajl_addChar('value':consName + consLocn);
  |           yajl_addChar('order':'30');
  |           yajl_addBool('isLabel':'0');
AR066       yajl_endObj();

            yajl_beginObj();
              yajl_addChar('label':'Unload');
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
               yajl_addChar('label':'Unload');
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

        //---------------------------------------------------------------------
        //        externalstopR;
        //---------------------------------------------------------------------
        begsr externalstopR;

          yajl_beginArray('external_data');
            yajl_beginObj();
              yajl_addChar('label':'Relay Information');
              yajl_addChar('value':'');
              yajl_addNum('order':'10');
              yajl_addBool('isLabel':'1');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Appointment Type');
              yajl_addChar('value':'Relay');
              yajl_addNum('order':'20');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Unload');
              yajl_addChar('value':'Drop');
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
AR045C     *dtaara       define                  lcinfo
AR045C                   in        lcinfo
A002      monitor;
A002      open pltintp;
A002      read pltintp;
A002      on-error;
A002      // disable driver team interface
A002      pltteamflg = '0';
AR010     // disable fuel stops interface
AR010     pltfuelflg = '0';
AR037     pltfuelreq = '0';
AR037     pltretrymn = '00';
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

           chain scope plscope;
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
