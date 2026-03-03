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
      * Send Preplan jobs using message file.                       *
      *                                                               *
      *  Program Modification Index                                   *
      *                                                               *
      *    Date    Mod    Who    Description                          *
      *  --------  -----  -----  ------------------------------------ *
      *  11/11/19  001    JB/PS  Added Preplanned Trailer.            *
      *  04/02/20  R002   JB/PS  Send preplan to team drivers.        *
      *  07/06/20  R003   JB/PS  Output High-Value information.       *
      *****************************************************************
      //
     H DftActGrp(*No) ActGrp(*New) BndDir('LIBHTTP/HTTPAPI')
     H FixNbr(*Zoned) Option(*NoDebugIo:*Srcstmt) Debug(*Yes)
     H BNDDIR('YAJL') DECEDIT('0.')
     H alwnull(*USRCTL)
     Funits     if   e           k disk
     Fmcmsgh    if   e           k disk
     Fmcmsgd    if   e           k disk
     Fplscope   iF   E           k DISK
AR002Fpltintp   if   E           k DISK    usropn
A001 Fopopcpl7  iF   E           k DISK
AR003Forder     if   e           k disk
AR003Fplthivalp if   e           k disk

      /include yajl_h
      /copy libhttp/qrpglesrc,httpapi_h

      * This program's Procedure Prototype
     Dpltppjobr        PR
     d                                6a
     d                                7s 0
     d                                6s 0

      * This program's Procedure Interface
     Dpltppjobr        PI
     d mhunit                         6a
     d mhdate                         7s 0
     d mhtime                         6s 0

     D incoming        PR            10I 0
     D                               10I 0 value
     D                             8192A   options(*varsize)
     D                               10I 0 value
       //?procedure prototypes
      *-----------------------------------------------------------
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
     dDLYJOB           pr                  extpgm('QCMDEXC')                    execute command
     d                             3000a   const options(*varsize)
     d                               15p 5 const

      // Constants/Variables to Delay the Job
     d dlycmd          s             50a   inz(*blanks)                         delay job cmd
     d dlycmd11        c                   const('DLYJOB (')                    delay job cmd
     d dlycmd12        c                   const(')')                           delay job cmd


      * load origing
     D ppline1         DS            40
     D ppline2         DS            40
     D info                    1     40A
     D ppline3         DS            40
     D ppord#                  9     15a
     D ppline4         DS            40
     D ppship                 12     36A
     D ppline5         DS            40
     D ppscty                  7     21A
     D ppsstate               27     28A
     D ppsdrld                37     37A
     D ppline6         DS            40
     d ppstotd                15     38
     D ppsudd                 18     19  0
     D ppsudm                 15     16  0
     D ppsudt                 15     19A
     D ppsutm                 21     25A
     D ppsuh                  21     22  0
     D ppsum                  24     25  0
     D ppsudt1                28     32A
     D ppsudd1                31     32  0
     D ppsudm1                28     29  0
     D ppsutm1                34     38A
     D ppsuh1                 34     35  0
     D ppsum1                 37     38  0
     D ppline7         DS            40
     D pppals                 12     13A
     D ppstops                29     30A
     D ppline8         DS            40
     D ppchip                 12     36A
     D ppline9         DS            40
     D ppccty                  7     21A
     D ppcstate               27     28A
     D ppcdrld                37     37A
     D ppline10        DS            40
     d ppctotd                15     38
     D ppcudd                 18     19  0
     D ppcudm                 15     16  0
     D ppcudt                 15     19A
     D ppcutm                 21     25A
     D ppcuh                  21     22  0
     D ppcum                  24     25  0
     D ppcudt1                28     32A
     D ppcudd1                31     32  0
     D ppcudm1                28     29  0
     D ppcutm1                34     38A
     D ppcuh1                 34     35  0
     D ppcum1                 37     38  0
     D ppline11        DS            40
     D pplodml                15     19


     D errMsg          s            500a   varying
     D jsonString      s          65535a
     D myJSON          S          65535a   varying
     D offset          S              2a
     D filename        s             10a
     D RC              S             10I 0
CR002d Server          S            256a   Inz(*blanks)
     d UsrAgent        S             64A   Inz(*blanks)
     D nextpos         S             10I 0 inz(1)
     D retdata         S          32766A
     D retlen          S             10I 0
     d ErrDta          S          32766a
     D @endUrl         s             45a
     d orderBy         s              4  0
     d SavDta          S                   Like(ErrDta)
     D StartPos        S              7  0 INZ(*ZEROS)
     D EndPos          S              7  0 INZ(*ZEROS)
     d JobId           s             10a
     d JobId1          s             17a
     D   ResultStr     s               a   len(16000000) varying
     D   SendStr       s               a   len(16000000) varying
     D  message        s           5000a
     D  messageA       s             40a   dim(50)
AR003D highValueA      s             90    dim(16)
AR003D highValue       s           1440a
     D cust#           s              6a
     D checkname       s             25a
     d curmonth        s              2  0
     d curyear         s              4  0
     dsmhunit          s              6a
     dsmhdate          s              7  0
     dsmhtime          s              6  0
     dmarktest         s              1a
     dskip401          s              1a   inz(*on)
A001 dpptrlr           s              6a
AR002dpltfuelflg       s              1a
AR003D x               s              5  0

TEMP     //mhunit = ' ABAG1';
TEMP     //mhdate = 2020188;
TEMP     //mhtime = 131949;
         rtvtimz(offset);
         curmonth =  %subdt(%date():*MONTHS);
         curyear  =  %subdt(%date():*YEARS);
         orderby = 1;
         smhunit = mhunit;
         smhdate = mhdate;
         smhtime = mhtime;

            exsr delayjob;
         chain mhunit units;
         if %found(units) = *on;
         // get all T45 information
         exsr loadPPlan;

         exsr BuildWfJob;
           myJSON = jsonString;

        //  Once you have it in a string, you can send it to the HTTP server.
        //  Use HTTP_setCCSIDs to tell HTTPAPI to trasnlate it to UTF-8 (CCSID 1208),
        //  and then use HTTPAPI's http_post() routine to do the POST operation:

        http_setCCSIDs( 1208: 0 );
        HTTP_debug(*on);
        HTTP_SetFileCCSID(1208);

        // Also need code here to set up 'additional headers'
          http_xproc( HTTP_POINT_ADDL_HEADER
                      : %paddr(add_headers) );

AR002   //Execute Team Drivers only if interface enabled.
AR002   if pltteamflg = '1' and undr2 <> *blanks;
AR002     Server = %trim('https://mvt.pltsci.com/api/preplans/teams');
AR002   else;
          @endUrl = %trim(undr1) + '/preplans';
          //Server = %trim('https://mvt.pltsci.com/api/drivers/'+@endUrl)
AR040     Server = %trim(pltinturl) + %trim(pltitwfep) + @endUrl;
AR002   endif;

       //?Send web service request to PlatForm Science
       rc=http_url_post_raw(%trim(Server)
                      : %addr( myJSON : *data )
                      : %len( myJSON )
                      : 1
                      : %paddr('INCOMING')
                      : HTTP_TIMEOUT
                      : HTTP_USERAGENT
                      : 'application/json' );

       //?If no error, Convert the data we just received to EBCDIC
       select;
       //On error, call api to generate hard error.
       when rc = -1;
     C                   CALL      'PLERRORC'                                   Text format
       when rc = 201;
       other;
         filename = %trim(ppord#) + 'PP';
         monitor;
         cpylnk(filename);
         on-error;
         endmon;
        //     Translate(retlen: retdata: 'QTCPEBC');
        endsl;

        endif;
        *inlr = *on;
       //--------------------------------------------------------------------
       //in here we are building a json for WF job      ------------------
       //--------------------------------------------------------------------
        begsr buildWfJob;

         yajl_genOpen(*ON);  // use *ON for easier to read JSON
                              //    *OFF for more compact JSON

         yajl_beginObj();
           yajl_addChar('preplan');
              yajl_beginObj();
               yajl_addChar('external_id':ppord#);
               yajl_addChar('is_declinable':'1');
              yajl_beginObj('plan_data');

         yajl_beginArray('fields');
           // insert fields

            yajl_beginObj();
              yajl_addChar('label':'Order #');
              yajl_addChar('value':ppord#);
              yajl_addNum('order':'1');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Shipper Name');
              yajl_addChar('value':ppship);
              yajl_addNum('order':'2');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'City');
              yajl_addChar('value':ppscty);
              yajl_addNum('order':'3');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'State');
              yajl_addChar('value':ppsstate);
              yajl_addNum('order':'4');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

A001        yajl_beginObj();
A001          yajl_addChar('label':'Preplanned Trailer');
A001          yajl_addChar('value':pptrlr);
A001          yajl_addNum('order':'5');
A001          yajl_addBool('isLabel':'0');
A001        yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Driver Load');
              yajl_addChar('value':ppsdrld);
C001          yajl_addNum('order':'6');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Pick Up Date/Time');
              yajl_addChar('value':%trim(ppstotd));
C001          yajl_addNum('order':'7');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Pallets Required');
              yajl_addChar('value':pppals);
C001          yajl_addNum('order':'8');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Number of Pickup or Dropoffs');
              yajl_addChar('value':ppstops);
C001          yajl_addNum('order':'9');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Consignee Name');
              yajl_addChar('value':ppchip);
C001          yajl_addNum('order':'10');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'City');
              yajl_addChar('value':ppccty);
C001          yajl_addNum('order':'11');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'State');
              yajl_addChar('value':ppcstate);
C001          yajl_addNum('order':'12');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Driver Load');
              yajl_addChar('value':ppcdrld);
C001          yajl_addNum('order':'13');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Delivery Date/Time');
              yajl_addChar('value':%trim(ppctotd));
C001          yajl_addNum('order':'14');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

            yajl_beginObj();
              yajl_addChar('label':'Loaded Miles');
              yajl_addChar('value':pplodml);
C001          yajl_addNum('order':'15');
              yajl_addBool('isLabel':'0');
            yajl_EndObj();

AR003       chain (ppord#) order;
  |         if %found(order) And orten = 'Y';
  |           clear x;
  |           dou %eof(plthivalp) Or x > 16;
  |             read plthivalp;
  |             if not %eof(plthivalp) And x <= 16 And plhvdesc > *blanks;
  |               x +=1;
  |               highValueA(x) = plhvdesc;
  |             endif;
  |           enddo;
  |           if highValueA(1) > *blanks;
  |  C                   movea     highValueA    highValue
  |             yajl_beginObj();
  |               yajl_addChar('label':'High-Value Info');
  |               yajl_addChar('value':' ');
  |               yajl_addChar('order':'16');
  |               yajl_addBool('isLabel':'1');
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
  |               yajl_addChar('value':%trim(highValueA(3)));
  |               yajl_addNum('order':'19');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(4)));
  |               yajl_addNum('order':'20');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(5)));
  |               yajl_addNum('order':'21');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(6)));
  |               yajl_addNum('order':'22');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(7)));
  |               yajl_addNum('order':'23');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(8)));
  |               yajl_addNum('order':'24');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(9)));
  |               yajl_addNum('order':'25');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(10)));
  |               yajl_addNum('order':'26');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(11)));
  |               yajl_addNum('order':'27');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(12)));
  |               yajl_addNum('order':'28');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(13)));
  |               yajl_addNum('order':'29');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(14)));
  |               yajl_addNum('order':'30');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(15)));
  |               yajl_addNum('order':'31');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |             yajl_beginObj();
  |               yajl_addChar('value':%trim(highValueA(16)));
  |               yajl_addNum('order':'32');
  |               yajl_addBool('isLabel':'0');
  |             yajl_endObj();
  |           //yajl_beginObj();
  |             //yajl_addChar('label':'High-Value Info');
  |             //yajl_addChar('value':%trim(highValue));
  |             //yajl_addNum('order':'16');
  |             //yajl_addBool('isLabel':'0');
  |           //yajl_endObj();
  |           endif;
AR003       endif;
          yajl_endArray();
          yajl_endObj();

            //Execute Team Drivers only if interface enabled.
AR002       if pltteamflg = '1' and undr2 <> *blanks;
  |           yajl_beginArray('teams');
  |             yajl_beginObj();
  |               yajl_addChar('external_id':ppord#+'_'+%trim(ununit));
  |               yajl_beginArray('drivers');
  |                 yajl_addChar(%trim(undr1));
  |                 yajl_addChar(%trim(undr2));
  |               yajl_endArray();
  |             yajl_endObj();
  |           yajl_endArray();
AR002       endif;
          yajl_endObj();
          yajl_endObj();

       jsonString = yajl_copyBufStr();
         // yajl_saveBuf('/tmp/example.json': errMsg);

          yajl_genClose();
        endsr;

       //--------------------------------------------------------------------
       //get pplann information from message file
       //--------------------------------------------------------------------
        begsr loadPPlan;
         clear messageA;
         chain (mhunit:mhdate:mhtime) mcmsgh;
         if %found(mcmsgh) = *on;
         if mhpmid = 'T45';
         setll (mhunit
               :mhdate
               :mhtime
               :mhdir) mcmsgd;
         reade (mhunit
               :mhdate
               :mhtime
               :mhdir) mcmsgd;
         dow %eof(mcmsgd) = *off;
         messageA(mdrec#) = mdmsgs;
         reade (mhunit
               :mhdate
               :mhtime
               :mhdir) mcmsgd;
         enddo;
         endif;
         endif;

         ppline1 = messagea(1);
         ppline2 = messagea(2);
         ppline3 = messagea(3);
         ppline4 = messagea(4);
         ppline5 = messagea(5);
         ppline6 = messagea(6);
         ppline7 = messagea(7);
         ppline8 = messagea(8);
         ppline9 = messagea(9);
         ppline10= messagea(10);
         ppline11= messagea(11);

A001     clear pptrlr;
A001     chain (ppord#:mhunit) opopcpl7;
A001       if %found(opopcpl7) and opqucd > *blanks;
A001          pptrlr = opqucd;
A001       endif;

         endsr;
       //----------------------------------------------------------------------
       //----------------------------------------------------------------------
        begsr delayjob;

          // "DLYJOB(" + variable from file + ")"
          dlycmd = %trim(dlycmd11) + ('1') + dlycmd12;

          // Issue the DLYJOB command
          Callp DLYJOB(dlycmd:%size(dlycmd));
        endsr;

        //---------------------------------------------------------------------
        //     *inzsr;
        //---------------------------------------------------------------------
AR002   begsr *inzsr;
  |       monitor;
  |       open pltintp;
  |       read pltintp;
  |       on-error;
  |       // disable driver team interface
  |       pltteamflg = '0';
  |       // disable fuel stops interface
  |       pltfuelflg = '0';
  |       close pltintp;
  |       endmon;
AR002   endsr;

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
      /END-FREE
     P                 E
